defmodule TaskScheduler.Queue do
  use GenServer
  require Logger

  @self_stop_delay 60_000..120_000

  @type t :: %{
          trigger_ref: reference(),
          self_stop_ref: reference(),
          tasks: [TaskScheduler.Queue.Task.t()],
          name: String.t()
        }

  defstruct trigger_ref: nil,
            tasks: [],
            name: nil,
            self_stop_ref: nil

  ## Client Callbacks

  def schedule(pid, data, reply_to, run_at) do
    GenServer.call(pid, {:schedule, %{data: data, run_at: run_at, reply_to: reply_to}})
  end

  def cancel(pid, task_ref) do
    GenServer.call(pid, {:cancel, task_ref})
  end

  ## Server Callbacks

  def start_link(opts \\ []) do
    queue_name = Keyword.fetch!(opts, :queue_name)
    gen_server_opts = Keyword.get(opts, :GenServer, [])
    GenServer.start_link(__MODULE__, queue_name, gen_server_opts)
  end

  def init(queue_name) do
    state = %__MODULE__{
      name: queue_name
    }

    {:ok, state, {:continue, :init}}
  end

  def handle_continue(:init, %__MODULE__{} = state) do
    tasks = TaskScheduler.DB.Tasks.load_tasks_for_queue(state.name)
    state = %{state | tasks: tasks} |> schedule_next_invocation() |> schedule_self_stop()
    {:noreply, state}
  end

  def handle_info(:trigger, %__MODULE__{} = state) do
    Logger.debug("Triggered, calling outstanding tasks")

    now = :os.system_time(:millisecond)
    to_execute = Enum.filter(state.tasks, &(&1.run_at <= now))

    run_tasks(to_execute)

    state =
      %{state | tasks: state.tasks -- to_execute}
      |> schedule_next_invocation()
      |> schedule_self_stop()

    {:noreply, state}
  end

  def handle_info(:self_stop, %__MODULE__{} = state) do
    if length(state.tasks) != 0 do
      Logger.debug("Not stopping while there are outstanding tasks")
      {:noreply, state}
    else
      Logger.debug("Self-stopping for #{state.name} due to inactivity")
      TaskScheduler.Queue.QueueRegistry.stop(self())
      {:stop, :normal, state}
    end
  end

  def handle_call(
        {:schedule, %{data: data, run_at: run_at, reply_to: reply_to}},
        _from,
        %__MODULE__{} = state
      ) do
    task_id = generate_task_id()

    new_task = %TaskScheduler.Queue.Task{
      id: task_id,
      data: data,
      run_at: run_at,
      reply_to: reply_to,
      queue: state.name
    }

    TaskScheduler.DB.Tasks.create_task(new_task)

    new_tasks = [new_task | state.tasks]

    state = %{state | tasks: new_tasks} |> schedule_next_invocation() |> schedule_self_stop()

    {:reply, {:ok, task_id}, state}
  end

  def handle_call({:cancel, ref}, _from, %__MODULE__{} = state) do
    Logger.debug("Canceling task #{inspect(ref)}")

    TaskScheduler.DB.Tasks.delete_task(ref)

    new_tasks = Enum.filter(state.tasks, &(&1.id != ref))

    state = %{state | tasks: new_tasks} |> schedule_next_invocation() |> schedule_self_stop()

    {:reply, :ok, state}
  end

  defp schedule_next_invocation(%__MODULE__{} = state) do
    Logger.debug("Scheduling next invocation")
    current_time = :os.system_time(:millisecond)
    sorted_tasks = Enum.sort_by(state.tasks, & &1.run_at)

    if state.trigger_ref != nil do
      Process.cancel_timer(state.trigger_ref)
    end

    case Enum.at(sorted_tasks, 0) do
      nil ->
        Logger.debug("No tasks to execute!")
        %{state | trigger_ref: nil}

      task ->
        run_in = max(task.run_at - current_time, 0)
        Logger.debug("Scheduling task in #{run_in} milliseconds")
        ref = Process.send_after(self(), :trigger, run_in)
        %{state | trigger_ref: ref}
    end
  end

  defp run_tasks(tasks) when length(tasks) == 0 do
    # Do nothing, no work to do
  end

  defp run_tasks([head | tail]) do
    run_task(head)
    run_tasks(tail)
  end

  defp run_task(%TaskScheduler.Queue.Task{reply_to: reply_to, id: id} = task)
       when is_binary(reply_to) do
    Logger.debug("Calling task #{inspect(task.id)} over AMQP queue #{inspect(reply_to)}")
    {:ok, chan} = AMQP.Application.get_channel(:main)
    AMQP.Queue.declare(chan, reply_to, auto_delete: true)

    TaskScheduler.DB.Tasks.delete_task(id)

    {:ok, data} =
      JSON.encode(%{
        id: task.id,
        data: task.data
      })

    case AMQP.Basic.publish(chan, "", reply_to, data) do
      :ok ->
        true

      error ->
        Logger.error("Unable to publish data, error: #{inspect(error)}")
        false
    end
  end

  defp generate_task_id() do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower) |> :binary.copy()
  end

  defp schedule_self_stop(%__MODULE__{self_stop_ref: ref, name: name} = state) do
    if ref != nil do
      Process.cancel_timer(ref)
    end

    if length(state.tasks) == 0 do
      send_after = Enum.random(@self_stop_delay)
      Logger.debug("[#{name}] Scheduling self-stop for #{send_after} milliseconds")
      ref = Process.send_after(self(), :self_stop, send_after)
      %{state | self_stop_ref: ref}
    else
      %{state | self_stop_ref: nil}
    end
  end
end
