defmodule TaskScheduler.AMQPMapper do
  use GenServer

  defstruct table: nil, monitors: %{}

  ## Client API

  def map(queue, amqp_queue, pid \\ nil) do
    GenServer.call(__MODULE__, {:register, queue, amqp_queue, pid})
  end

  def unmap(queue, amqp_queue) do
    GenServer.call(__MODULE__, {:unregister, queue, amqp_queue})
  end

  def get_mappings(queue) do
    :ets.lookup(:amqp_map, queue) |> Enum.uniq() |> Enum.map(fn {_k, v} -> v end)
  end

  ## Server Callbacks

  def start_link(opts \\ []) do
    opts = Keyword.put(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    table = :ets.new(:amqp_map, [:named_table, :duplicate_bag, read_concurrency: true])

    {:ok,
     %__MODULE__{
       table: table
     }}
  end

  def handle_call({:register, queue, amqp_queue, monitor_pid}, _from, %__MODULE__{} = state) do
    :ets.insert(:amqp_map, {queue, amqp_queue})

    if monitor_pid != nil do
      ref = Process.monitor(monitor_pid)
      monitors = Map.put(state.monitors, ref, {queue, amqp_queue})
      state = %{state | monitors: monitors}
      {:reply, :ok, state}
    else
      {:reply, :ok, state}
    end
  end

  def handle_call({:unregister, queue, amqp_queue}, _from, state) do
    :ets.delete_object(:amqp_map, {queue, amqp_queue})
    {:reply, :ok, state}
  end

  def handle_info({:DOWN, ref, :process, _obj, _reason}, %__MODULE__{} = state) do
    case Map.get(state.monitors, ref) do
      nil ->
        {:noreply, state}

      {queue, amqp_queue} ->
        :ets.delete_object(:amqp_map, {queue, amqp_queue})
        monitors = Map.delete(state.monitors, ref)
        {:noreply, %{state | monitors: monitors}}
    end
  end
end
