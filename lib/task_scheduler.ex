defmodule TaskScheduler do
  @moduledoc """
  `TaskScheduler` main entrypoint
  """

  use Application


  def start(_type, _args) do
    children = [
      TaskScheduler.Queue.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TaskScheduler)
  end
end
