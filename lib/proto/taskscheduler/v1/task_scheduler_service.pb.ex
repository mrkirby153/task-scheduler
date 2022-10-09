defmodule Taskscheduler.V1.GetTaskRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :id, 1, type: :uint64
end

defmodule Taskscheduler.V1.GetTaskResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :task, 1, type: Taskscheduler.V1.Task
end

defmodule Taskscheduler.V1.CancelTaskRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :id, 1, type: :uint64
end

defmodule Taskscheduler.V1.CancelTaskResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :success, 1, type: :bool
end

defmodule Taskscheduler.V1.RescheduleTaskRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  oneof :task_id, 0

  field :id, 1, type: :uint64, oneof: 0
  field :task, 2, type: Taskscheduler.V1.Task, oneof: 0
  field :new_time, 3, type: :uint64, json_name: "newTime"
end

defmodule Taskscheduler.V1.RescheduleTaskResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :task, 1, type: Taskscheduler.V1.Task
end

defmodule Taskscheduler.V1.ScheduleTaskRequest do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :time, 1, type: :uint64
  field :queue, 2, type: :string
  field :data, 3, type: :string
  field :topic, 4, type: :string
end

defmodule Taskscheduler.V1.ScheduleTaskResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :task, 1, type: Taskscheduler.V1.Task
end

defmodule Taskscheduler.V1.TaskSchedulerService.Service do
  @moduledoc false

  use GRPC.Service,
    name: "taskscheduler.v1.TaskSchedulerService",
    protoc_gen_elixir_version: "0.11.0"

  rpc :GetTask, Taskscheduler.V1.GetTaskRequest, Taskscheduler.V1.GetTaskResponse

  rpc :CancelTask, Taskscheduler.V1.CancelTaskRequest, Taskscheduler.V1.CancelTaskResponse

  rpc :RescheduleTask,
      Taskscheduler.V1.RescheduleTaskRequest,
      Taskscheduler.V1.RescheduleTaskResponse
end

defmodule Taskscheduler.V1.TaskSchedulerService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Taskscheduler.V1.TaskSchedulerService.Service
end