defmodule TaskScheduler.DB.Tasks do
  alias TaskScheduler.DB.Utils, as: DBUtils
  alias TaskScheduler.Queue.Task, as: QueueTask

  @doc """
  Gets all the queues that should be running
  """
  @spec get_all_queues :: list
  def get_all_queues() do
    case MyXQL.query(:myxql, "SELECT DISTINCT queue FROM `tasks`") do
      {:ok, result} ->
        with {:ok, rows} <- DBUtils.to_map(result) do
          rows |> Enum.map(& &1.queue)
        else
          _ -> []
        end

      _ ->
        []
    end
  end

  @doc """
  Loads a task with the given ID
  """
  @spec load_task(any) :: :ok | {L, any}
  def load_task(id) do
    case MyXQL.query(:myxql, "SELECT * FROM `tasks` WHERE id = ?", [id]) do
      {:ok, result} ->
        with {:ok, rows} <- DBUtils.to_map(result) do
          List.first(rows) |> parse_task()
        end

      {:error, term} ->
        {:error, term}
    end
  end

  def create_task(%QueueTask{} = task) do
    MyXQL.query(
      :myxql,
      "INSERT INTO `tasks` (`id`, `queue`, `reply_to`, `data`, `run_at`) VALUES (?, ?, ?, ?, ?)",
      [
        task.id,
        task.queue,
        task.reply_to,
        task.data,
        task.run_at
        |> DateTime.from_unix!(:millisecond)
        |> DateTime.to_naive()
        |> NaiveDateTime.to_string()
      ]
    )
    |> DBUtils.to_map()
  end

  defp parse_task(row) when length(row) > 1 do
    {:error, :duplicate_result}
  end

  defp parse_task(row) do
    {:ok, QueueTask.from_database(row)}
  end
end
