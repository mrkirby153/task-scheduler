defmodule TaskScheduler.Queue.QueueRegistry do
  use GenServer
  require Logger

  defstruct table: nil

  ## Client Callbacks

  def lookup(queue_name) do
    case :ets.lookup(:queue_registry, queue_name) do
      [] -> nil
      [{^queue_name, pid}] -> pid
    end
  end

  def lookup_or_start(queue_name) do
    case lookup(queue_name) do
      nil ->
        start(queue_name)
      pid -> pid
    end
  end

  def start(queue_name) do
    GenServer.call(__MODULE__, {:start, queue_name})
  end

  def stop(queue_name) do
    GenServer.call(__MODULE__, {:stop, queue_name})
  end


  ## Server Callbacks

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    state = %__MODULE__{table: :ets.new(:queue_registry, [:named_table, read_concurrency: true])}
    {:ok, state}
  end

  def handle_call({:start, queue_name}, _from, state) do
    case lookup(queue_name) do
      nil ->
        {:ok, pid} = DynamicSupervisor.start_child(TaskScheduler.QueueSupervisor, {TaskScheduler.Queue, [queue_name: queue_name]})
        :ets.insert(:queue_registry, {queue_name, pid})
        {:reply, {:ok, pid}, state}
      _pid -> {:reply, {:error, :already_started}, state}
      end
  end

  def handle_call({:stop, queue_name}, _from, state) do
    case lookup(queue_name) do
      nil -> {:reply, {:error, :not_found}, state}
      pid ->
        DynamicSupervisor.terminate_child(TaskScheduler.QueueSupervisor, pid)
        :ets.delete(:queue_registry, queue_name)
        {:reply, :ok, state}
    end
  end
end
