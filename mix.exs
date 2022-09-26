defmodule TaskScheduler.MixProject do
  use Mix.Project

  def project do
    [
      app: :task_scheduler,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TaskScheduler, []},
      extra_applications: [:logger, :grpc]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amqp, "~> 3.1"},
      {:myxql, "~> 0.6.2"},
      {:distillery, "~> 2.1"},
      {:toml, "~> 0.6.1"},
      {:grpc,
       git: "https://github.com/elixir-grpc/grpc.git",
       ref: "c7ee0c11ad9eb95a8925a342af8e2d5b1f082fee"},
      {:protobuf, "~> 0.11.0"},
      {:google_protos, "~> 0.3"}
    ]
  end
end
