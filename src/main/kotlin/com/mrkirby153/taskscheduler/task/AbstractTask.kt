package com.mrkirby153.taskscheduler.task

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.serializer

/**
 * An abstract task
 */
abstract class Task<T : Any?> {

    private lateinit var dataClass: Class<T>
    private var rawData: String? = null

    @OptIn(ExperimentalSerializationApi::class)
    var data: T
        @Suppress("UNCHECKED_CAST")
        get() {
            return if (rawData != null) {
                val serializer = serializer(dataClass)
                Json.decodeFromString(serializer, rawData!!)
            } else {
                null
            } as T
        }
        set(data) {
            rawData = if (data != null) {
                val serializer = serializer(data!!::class.java)
                Json.encodeToString(serializer, data)
            } else {
                null
            }
        }

    /**
     * Runs the task
     */
    abstract fun run()
}