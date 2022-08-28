package com.mrkirby153.taskscheduler

import com.mrkirby153.taskscheduler.task.TaskWithData
import kotlinx.serialization.Serializable

@Serializable
data class TaskData(val name: String, val startTime: String)

class TestTask : TaskWithData<TaskData>("test") {
    override fun run() {
        println("Running task: $data")
    }
}