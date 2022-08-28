package com.mrkirby153.taskscheduler.task.ampq

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.serializer

internal object AmpqMessageRegistry {
    val messageMappings = mutableMapOf<Class<out AmpqMessage>, Int>()

    init {

    }

    /**
     * Registers the given [clazz] as a message with the provided [id]
     */
    fun register(clazz: Class<out AmpqMessage>, id: Int) {
        messageMappings[clazz] = id
    }

    /**
     * Deserializes the provided [data] into [T]
     */
    @Suppress("UNCHECKED_CAST")
    @OptIn(ExperimentalSerializationApi::class)
    fun <T : AmpqMessage> deserialize(data: String): T? {
        val msgData = Json.decodeFromString<AmpqMessageData>(data)
        val body = msgData.body
        val (clazz, id) = messageMappings.entries.firstOrNull { (_, id) -> id == msgData.id }
            ?: return null
        val serializer = serializer(clazz)
        return Json.decodeFromString(serializer, body) as T
    }

    /**
     * Serializes the provided [msg] into json
     */
    inline fun <reified T : AmpqMessage> serialize(msg: T): String {
        val id = messageMappings[msg::class.java] ?: error("Unregistered message $msg")
        val serialized = Json.encodeToString(msg)
        return Json.encodeToString(AmpqMessageData(id, serialized))
    }
}

/**
 * A message sent over AMPQ
 */
@Serializable
internal data class AmpqMessageData(
    val id: Int,
    val body: String
)

/**
 * An abstract AMPQ message to send
 */
@Serializable
internal open class AmpqMessage