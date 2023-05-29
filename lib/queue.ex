defmodule TaskScheduler.Queue do
  use GenServer
  require Logger

  @self_stop_delay 60_000..120_000

  @type t :: %{
          trigger_ref: reference(),
          self_stop_ref: reference(),
          tasks: List.t(),
          name: String.t()
        }

  defstruct trigger_ref: nil, tasks: [], name: nil, self_stop_ref: nil

  # Client Methods

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  # Server Callbacks
  def start_link(opts \\ []) do
    queue_name = Keyword.fetch!(opts, :name)
    gen_server_opts = Keyword.get(opts, :GenServer, [])
    GenServer.start_link(__MODULE__, queue_name, gen_server_opts)
  end

  def init(queue_name) do
    Logger.debug("[#{queue_name}] Initializing...")

    state = %__MODULE__{
      name: queue_name
    }

    {:ok, state, {:continue, :init}}
  end

  def handle_continue(:init, %__MODULE__{} = state) do
    Logger.info("[#{state.name}] Started")
    state = state |> schedule_self_stop()
    {:noreply, state}
  end

  def handle_call(:stop, _from, %__MODULE__{} = state) do
    do_stop()
    {:stop, :normal, state}
  end

  def handle_info(:self_stop, %__MODULE__{tasks: tasks} = state) when length(tasks) == 0 do
    Logger.info("[#{state.name}] Stopping")
    do_stop()
    {:stop, :normal, state}
  end

  def handle_info(:self_stop, %__MODULE__{} = state) do
    # There are tasks in the queue, re-schedule self stop
    Logger.debug("#{state.name} Received self_stop but has outstanding tasks, not stopping")
    {:noreply, state}
  end

  defp schedule_self_stop(%__MODULE__{} = state) do
    ref = state.self_stop_ref

    if ref != nil do
      Process.cancel_timer(ref)
    end

    if length(state.tasks) == 0 do
      send_after = Enum.random(@self_stop_delay)
      Logger.debug("[#{state.name}] Scheduling self stop in #{inspect(send_after)}")
      ref = Process.send_after(self(), :self_stop, send_after)
      %{state | self_stop_ref: ref}
    else
      if ref != nil do
        Logger.debug("[#{state.name}] Cancelling self stop")
      end

      %{state | self_stop_ref: nil}
    end
  end

  defp do_stop() do
    TaskScheduler.Queue.Registry.stop(self())
  end
end
