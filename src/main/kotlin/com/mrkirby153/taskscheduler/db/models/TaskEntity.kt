package com.mrkirby153.taskscheduler.db.models

import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.UUIDTable
import java.util.UUID

/**
 * The tasks table storing all tasks that need to be run
 */
object Tasks : UUIDTable("tasks") {
    val taskClass = varchar("task_class", 255)
    val data = text("data").nullable()
    val state = enumeration<State>("state").default(State.SCHEDULED)
    val shardKey = varchar("shard_key", 255).nullable().default(null)
}

/**
 * A task in the database
 */
class TaskEntity(id: EntityID<UUID>) : UUIDEntity(id) {
    companion object : UUIDEntityClass<TaskEntity>(Tasks)

    var data by Tasks.data
    var taskClass by Tasks.taskClass
    var state by Tasks.state
    var shardingKey by Tasks.shardKey
}

enum class State {
    SCHEDULED,
    RUNNING,
    COMPLETED,
    FAILED
}