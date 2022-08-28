package com.mrkirby153.taskscheduler.task

/**
 * An abstract task
 */
abstract class AbstractTask(
    val type: String
) {
    /**
     * Runs the task
     */
    abstract fun run()
}

/**
 * A task that has data associated with it. The data class must be [kotlinx.serialization.Serializable]
 */
abstract class TaskWithData<T : Any>(
    type: String
) : AbstractTask(type) {
    lateinit var data: T
}

/**
 * A task that does not contain any data
 */
abstract class Task(
    type: String
) : AbstractTask(type)