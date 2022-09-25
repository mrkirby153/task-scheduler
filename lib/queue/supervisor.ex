defmodule TaskScheduler.Queue.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = [
      {DynamicSupervisor, name: TaskScheduler.QueueSupervisor, strategy: :one_for_one},
      {TaskScheduler.Queue.QueueRegistry, name: TaskScheduler.Queue.QueueRegistry}
    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end
