defmodule TaskScheduler.AMQPMapper.Heartbeater do
  use GenServer
  require Logger

  alias TaskScheduler.AMQPMapper

  @heartbeat_grace_period 5_000

  @type t :: %{
          queue: String.t(),
          amqp_queue: String.t(),
          interval: integer(),
          heartbeat_ref: reference()
        }

  defstruct queue: nil, amqp_queue: nil, interval: Enum.random(30_000..45_000), heartbeat_ref: nil

  def heartbeat(pid) do
    GenServer.call(pid, :heartbeat)
  end

  def start_link(opts) do
    amqp_queue = Keyword.fetch!(opts, :amqp_queue)
    queue = Keyword.fetch!(opts, :queue)
    interval = Keyword.get(opts, :interval, Enum.random(30_000..45_000))
    genserver_opts = Keyword.get(opts, :GenServer, [])
    GenServer.start_link(__MODULE__, {queue, amqp_queue, interval}, genserver_opts)
  end

  def init({queue, amqp_queue, interval}) do
    heartbeat_ref = Process.send_after(self(), :terminate, interval + @heartbeat_grace_period)
    AMQPMapper.map(queue, amqp_queue, self())

    {:ok,
     %__MODULE__{
       queue: queue,
       amqp_queue: amqp_queue,
       interval: interval,
       heartbeat_ref: heartbeat_ref
     }}
  end

  def handle_info(:terminate, %__MODULE__{} = state) do
    Logger.info("Heartbeat timed out for #{state.queue} -> #{state.amqp_queue}")
    {:stop, :normal, state}
  end

  def handle_call(:heartbeat, _from, %__MODULE__{} = state) do
    state = reschedule(state)
    {:reply, :ok, state}
  end

  defp reschedule(%__MODULE__{} = state) do
    if state.heartbeat_ref != nil do
      Process.cancel_timer(state.heartbeat_ref)
    end

    heartbeat_ref =
      Process.send_after(self(), :terminate, state.interval + @heartbeat_grace_period)

    %{state | heartbeat_ref: heartbeat_ref}
  end
end
