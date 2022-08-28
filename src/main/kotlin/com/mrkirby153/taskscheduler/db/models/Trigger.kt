package com.mrkirby153.taskscheduler.db.models

import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.timestamp
import java.util.UUID

object Triggers : UUIDTable("triggers") {
    val task = reference("task", Tasks, onDelete = ReferenceOption.CASCADE)
    val nextRunAt = timestamp("next_run")
    val lastRunAt = timestamp("last_ran").nullable().default(null)
    val type = enumerationByName<TriggerType>("type", 255).default(TriggerType.ONE_SHOT)
    val priority = integer("priority").default(0)
}

class Trigger(id: EntityID<UUID>) : UUIDEntity(id) {
    companion object : UUIDEntityClass<Trigger>(Triggers)

    var task by Task referencedOn Triggers.task
    var nextRunAt by Triggers.nextRunAt
    var lastRunAt by Triggers.lastRunAt
    var type by Triggers.type
    var priority by Triggers.priority
}

enum class TriggerType {
    ONE_SHOT,
    REPEATING
}