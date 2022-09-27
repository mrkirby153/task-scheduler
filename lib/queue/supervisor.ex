defmodule TaskScheduler.Queue.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = [
      {Registry, keys: :unique, name: Registry.Queue},
      {DynamicSupervisor, name: TaskScheduler.QueueSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
