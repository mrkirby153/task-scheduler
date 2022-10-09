defmodule TaskScheduler.Queue do
  use GenServer
  require Logger

  @type t :: %{
          trigger_ref: reference(),
          tasks: [task()],
          name: String.t()
        }

  @type task :: %{
          id: String.t(),
          data: String.t(),
          run_at: integer(),
          queue: String.t(),
        }

  defstruct trigger_ref: nil,
            tasks: [],
            queue: nil,
            name: nil

  ## Client Callbacks

  def schedule(pid, data, reply_queue, run_at) do
    GenServer.call(pid, {:schedule, %{data: data, run_at: run_at, queue: reply_queue}})
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
    # TODO: Load tasks and scheudle queue
    state = state |> schedule_next_invocation()
    {:noreply, state}
  end

  def handle_info(:trigger, %__MODULE__{} = state) do
    Logger.debug("Triggered, calling outstanding tasks")

    now = :os.system_time(:millisecond)
    to_execute = Enum.filter(state.tasks, &(&1.run_at <= now))

    run_tasks(to_execute)

    state = %{state | tasks: state.tasks -- to_execute} |> schedule_next_invocation()
    {:noreply, state}
  end

  def handle_call({:schedule, %{data: data, run_at: run_at, queue: queue}}, _from, %__MODULE__{} = state) do
    task_id = generate_task_id()
    new_tasks = [
      %{
        id: task_id,
        data: data,
        run_at: run_at,
        queue: queue
      }
      | state.tasks
    ]

    state = %{state | tasks: new_tasks} |> schedule_next_invocation()

    {:reply, {:ok, task_id}, state}
  end

  def handle_call({:cancel, ref}, _from, %__MODULE__{} = state) do
    Logger.debug("Canceling task #{inspect(ref)}")

    new_tasks = Enum.filter(state.tasks, &(&1.id != ref))

    state = %{state | tasks: new_tasks} |> schedule_next_invocation()

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

  defp run_task(task) do
    Logger.debug("Calling task #{inspect(task.id)}")
    queue = task.queue
    {:ok, chan} = AMQP.Application.get_channel(:main)
    AMQP.Queue.declare(chan, queue, [auto_delete: true])

    {:ok, data} = JSON.encode(%{
      id: task.id,
      data: task.data
    })

    case AMQP.Basic.publish(chan, "", queue, data) do
      :ok ->
        true
      error ->
        Logger.error("Unable to publish data, error: #{inspect(error)}")
    end
  end

  defp generate_task_id() do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower) |> :binary.copy()
  end
end
