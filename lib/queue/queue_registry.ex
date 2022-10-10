defmodule TaskScheduler.Queue.QueueRegistry do
  @doc """
  Looks up a queue by name, if it exists, returns the pid, otherwise returns `:not_found`
  """
  @spec lookup(any) :: {:error, :not_found} | {:ok, pid}
  def lookup(queue_name) do
    case Registry.lookup(Registry.Queue, queue_name) do
      [] -> {:error, :not_found}
      [{pid, _any}] -> {:ok, pid}
    end
  end

  @doc """
  Looks up a queue by name, if it exists, returns the pid, otherwise starts a new queue
  """
  @spec lookup_or_start(any) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def lookup_or_start(queue_name) do
    case lookup(queue_name) do
      {:ok, pid} -> {:ok, pid}
      {:error, :not_found} -> start(queue_name)
    end
  end

  @doc """
  Starts a new queue with the given `queue_name`
  """
  @spec start(any) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start(queue_name) do
    process_name = {:via, Registry, {Registry.Queue, queue_name}}

    DynamicSupervisor.start_child(
      TaskScheduler.QueueSupervisor,
      {TaskScheduler.Queue, [queue_name: queue_name, GenServer: [name: process_name]]}
    )
  end

  @doc """
  Stops a queue by pid or name
  """
  @spec stop(pid()) :: :ok
  def stop(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(TaskScheduler.QueueSupervisor, pid)
  end

  @spec stop(String.t()) :: :ok
  def stop(queue_name) do
    with {:ok, pid} <- lookup(queue_name) do
      DynamicSupervisor.terminate_child(TaskScheduler.QueueSupervisor, pid)
    else
      {:error, :not_found} -> :ok
    end
  end

  @doc """
  Returns a list of all queues and their pids
  """
  @spec all :: [{pid(), String.t()}]
  def all() do
    Registry.select(Registry.Queue, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])
    |> Enum.map(fn {name, pid, _} -> {pid, name} end)
  end

  defmodule LoadQueues do
    use GenServer, restart: :transient
    require Logger

    def start_link(opts \\ []) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
      {:ok, nil, {:continue, :load}}
    end

    def handle_continue(:load, state) do
      queues = TaskScheduler.DB.Tasks.get_all_queues()
      Logger.info("Loading #{length(queues)} queues from database.")
      queues |> Enum.map(&TaskScheduler.Queue.QueueRegistry.lookup_or_start/1)
      {:stop, :normal, state}
    end
  end
end
