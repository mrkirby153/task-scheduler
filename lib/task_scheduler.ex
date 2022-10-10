defmodule TaskScheduler do
  @moduledoc """
  `TaskScheduler` main entrypoint
  """

  use Application

  def get_queue(name) do
    TaskScheduler.Queue.QueueRegistry.lookup_or_start(name)
  end

  def start(_type, _args) do
    database_username = Application.get_env(:task_scheduler, :db_username)
    database_password = Application.get_env(:task_scheduler, :db_password)
    database_host = Application.get_env(:task_scheduler, :db_host)
    database_port = Application.get_env(:task_scheduler, :db_port)
    database_database = Application.get_env(:task_scheduler, :db_database)

    children = [
      {MyXQL,
       username: database_username,
       password: database_password,
       hostname: database_host,
       port: database_port,
       database: database_database,
       name: :myxql},
      TaskScheduler.Queue.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TaskScheduler)
  end
end
