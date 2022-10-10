defmodule TaskScheduler.DB do
  def to_map(record, as_atom \\ true)

  def to_map({:ok, %MyXQL.Result{last_insert_id: id, columns: nil, rows: nil}}, _as_atom)
      when id > 0 do
    {:ok, %{id: id}}
  end

  def to_map({:ok, %MyXQL.Result{last_insert_id: 0, columns: nil, rows: nil}}, _as_atom) do
    :ok
  end

  def to_map({:ok, %MyXQL.Result{columns: columns, rows: rows}}, as_atom) do
    columns =
      if as_atom do
        for col <- columns, into: [], do: String.to_atom(col)
      else
        columns
      end

    {:ok, Enum.map(rows, &(columns |> Enum.zip(&1) |> Enum.into(%{})))}
  end

  def to_map({term, msg}, _as_atom) do
    # Catches non-maps-based outcomes
    {term, msg}
  end
end
