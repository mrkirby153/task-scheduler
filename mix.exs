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
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amqp, "~> 3.1"},
      {:myxql, "~> 0.6.2"},
      {:distillery, "~> 2.1"},
      {:toml, "~> 0.6.1"}
    ]
  end
end
