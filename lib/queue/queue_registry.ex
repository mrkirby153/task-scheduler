defmodule TaskScheduler.Queue.QueueRegistry do

  @doc """
  Looks up a queue by name, if it exists, returns the pid, otherwise returns `:not_found`
  """
  @spec lookup(any) :: {:error, :not_found} | {:ok, pid}
  def lookup(queue_name) do
    case Registry.lookup(__MODULE__, queue_name) do
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
    process_name = {:via, Registry, {__MODULE__, queue_name}}
    DynamicSupervisor.start_child(TaskScheduler.QueueSupervisor, {TaskScheduler.Queue, [queue_name: queue_name, name: process_name]})
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
    Registry.select(__MODULE__, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}]) |> Enum.map(fn {name, pid, _} -> {pid, name} end)
  end
end
