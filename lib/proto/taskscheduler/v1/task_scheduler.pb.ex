defmodule Taskscheduler.V1.Task do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :id, 1, type: :uint64
  field :data, 2, type: :string
  field :queue, 3, type: :string
  field :run_at, 4, type: :uint64, json_name: "runAt"
end