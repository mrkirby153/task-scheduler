defmodule TaskScheduler.Queue.Registry do
  @queue_registry_module Registry.TaskQueue

  @spec lookup(String.t()) :: {:error, :not_found} | {:ok, pid}
  def lookup(queue_name) do
    case Registry.lookup(@queue_registry_module, queue_name) do
      [] -> {:error, :not_found}
      [{pid, _}] -> {:ok, pid}
    end
  end

  def lookup_or_start(queue_name) do
    case lookup(queue_name) do
      {:ok, pid} -> {:ok, pid}
      {:error, :not_found} -> start(queue_name)
    end
  end

  def start(queue_name) do
    process_name = {:via, Registry, {@queue_registry_module, queue_name}}

    DynamicSupervisor.start_child(
      TaskScheduler.QueueSupervisor,
      {TaskScheduler.Queue, [name: queue_name, GenServer: [name: process_name]]}
    )
  end

  def stop(pid) when is_pid(pid) do
    DynamicSupervisor.terminate_child(TaskScheduler.QueueSupervisor, pid)
  end

  def stop(queue_name) do
    with {:ok, pid} <- lookup(queue_name) do
      stop(pid)
    else
      _ -> :ok
    end
  end
end
