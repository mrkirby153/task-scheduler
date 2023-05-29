defmodule TaskScheduler do
  use Application

  def start(_type, _args) do
    children = [
      TaskScheduler.Queue.Supervisor
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: TsakScheduler)
  end
end
