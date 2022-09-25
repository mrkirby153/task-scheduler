defmodule TaskScheduler do
  @moduledoc """
  `TaskScheduler` main entrypoint
  """

  use Application


  def start(_type, _args) do
    children = [
      # {GRPC.Server.Supervisor, endpoint: Helloworld.Endpoint, port: 50051, start_server: true}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TaskScheduler)
  end
end
