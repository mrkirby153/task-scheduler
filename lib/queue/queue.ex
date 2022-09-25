defmodule TaskScheduler.Queue do
  use GenServer
  require Logger

  @type t :: %{
    trigger_ref: reference(),
    tasks: [task()],
    queue: String.t()
  }

  @type task :: %{
    id: reference(),
    data: String.t(),
    run_at: integer()
  }

  defstruct trigger_ref: nil,
    tasks: [],
    queue: nil

  ## Client Callbacks

  def schedule(pid, data, run_at) do
    GenServer.call(pid, {:schedule, %{data: data, run_at: run_at}})
  end

  def cancel(pid, task_ref) do
    GenServer.call(pid, {:cancel, task_ref})
  end

  ## Server Callbacks

  def start_link(start_opts \\ [], opts \\ []) do
    queue_name = Keyword.fetch!(start_opts, :queue_name)
    GenServer.start_link(__MODULE__, queue_name, opts)
  end

  def init(queue_name) do
    Logger.info("Starting qeueu #{queue_name}")
    state = %__MODULE__{}
    {:ok, state, {:continue, :init}}
  end

  def handle_continue(:init, %__MODULE__{} = state) do
    Logger.info("Initial schedule")
    # TODO: Load tasks and scheudle queue
    state = state |> schedule_next_invocation()
    {:noreply, state}
  end

  def handle_info(:trigger, %__MODULE__{} = state) do
    Logger.info("Triggered, calling outstanding tasks!")

    now = :os.system_time(:millisecond)
    to_execute = Enum.filter(state.tasks, &(&1.run_at <= now))

    run_tasks(to_execute)

    state = %{state | tasks: state.tasks -- to_execute} |> schedule_next_invocation()
    {:noreply, state}
  end

  def handle_call({:schedule, %{data: data, run_at: run_at}}, _from, %__MODULE__{} = state) do
    Logger.info("Scheduling task!")
    task_ref = make_ref()

    new_tasks = [%{
      id: task_ref,
      data: data,
      run_at: run_at
    } | state.tasks]

    state = %{state | tasks: new_tasks} |> schedule_next_invocation()

    {:reply, {:ok, task_ref}, state}
  end

  def handle_call({:cancel, ref}, _from, %__MODULE__{} = state) do
    Logger.info("Canceling task #{inspect(ref)}")

    new_tasks = Enum.filter(state.tasks, &(&1.id != ref))

    state = %{state | tasks: new_tasks} |> schedule_next_invocation()

    {:reply, :ok, state}
  end

  defp schedule_next_invocation(%__MODULE__{} = state) do
    Logger.info("Scheduling next invocation")
    current_time = :os.system_time(:millisecond)
    sorted_tasks = Enum.sort_by(state.tasks, &(&1.run_at))

    if state.trigger_ref != nil do
      Process.cancel_timer(state.trigger_ref)
    end

    case Enum.at(sorted_tasks, 0) do
      nil ->
        Logger.info("No tasks to execute!")
        %{state | trigger_ref: nil}
      task ->
        run_in = max(task.run_at - current_time, 0)
        Logger.info("Scheduling task in #{run_in} milliseconds")
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
    Logger.info("Running task #{inspect(task.id)}")
  end
end
