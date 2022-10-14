defmodule TaskScheduler.AMQPMapper do
  use GenServer

  defstruct table: nil

  ## Client API

  def map(queue, amqp_queue) do
    GenServer.call(__MODULE__, {:register, queue, amqp_queue})
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

  def handle_call({:register, queue, amqp_queue}, _from, state) do
    :ets.insert(:amqp_map, {queue, amqp_queue})
    {:reply, :ok, state}
  end

  def handle_call({:unregister, queue, amqp_queue}, _from, state) do
    :ets.delete_object(:amqp_map, {queue, amqp_queue})
    {:reply, :ok, state}
  end
end
