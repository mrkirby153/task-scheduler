defmodule TaskScheduler.Queue.Task do
  @type reply :: String.t() | pid()
  @type t :: %{
          id: String.t(),
          data: String.t(),
          queue: String.t(),
          run_at: integer(),
          reply_to: reply()
        }

  defstruct id: nil, data: "", run_at: nil, reply_to: nil, queue: nil

  def from_database(row) do
    %__MODULE__{
      id: row[:id],
      data: row[:data],
      queue: row[:queue],
      run_at: row[:run_at] |> DateTime.to_unix(:millisecond),
      reply_to: row[:reply_to]
    }
  end
end
