package com.mrkirby153.taskscheduler.task

import com.rabbitmq.client.BuiltinExchangeType
import com.rabbitmq.client.Channel
import com.rabbitmq.client.Connection
import com.rabbitmq.client.ConnectionFactory
import mu.KotlinLogging
import java.util.UUID
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.ThreadFactory


private val logger = KotlinLogging.logger { }
const val EXECUTOR_EXCHANGE_NAME = "task_executor_incoming"

/**
 * A task executor
 */
class TaskExecutor(
    private val rabbitMqConnectionFactory: ConnectionFactory,
    threadFactory: ThreadFactory? = null,
    vararg queues: String,
) {
    private val executorId = UUID.randomUUID().toString().replace("-", "")
    private val threadPool: ExecutorService
    private val queues = mutableListOf<String>()

    private lateinit var connection: Connection
    private lateinit var channel: Channel
    private lateinit var ephemeralQueue: String

    private var initialized = false

    init {
        val factory = threadFactory ?: ThreadFactory {
            return@ThreadFactory Thread().apply {
                isDaemon = false
                name = "TaskSchedulerExecutor"
            }
        }
        threadPool = Executors.newCachedThreadPool(factory)
        this.queues.addAll(queues)
    }

    /**
     * Initializes the task executor
     */
    fun init() {
        check(!initialized) { "This executor has already been initialized" }
        logger.debug { "Initializing Task Executor $executorId" }
        connection = rabbitMqConnectionFactory.newConnection()
        channel = connection.createChannel()
        ephemeralQueue = channel.queueDeclare().queue

        withRabbitMqChannel(true) { channel ->
            logger.debug { "Creating exchange $EXECUTOR_EXCHANGE_NAME" }
            channel.exchangeDeclare(
                EXECUTOR_EXCHANGE_NAME,
                BuiltinExchangeType.DIRECT,
                true,
                true,
                null
            )

            logger.debug { "Binding to queues $queues" }
            channel.queueBind(ephemeralQueue, EXECUTOR_EXCHANGE_NAME, "")
            queues.forEach {
                channel.queueBind(ephemeralQueue, EXECUTOR_EXCHANGE_NAME, it)
            }
        }

        initialized = true
    }

    /**
     * Waits for all running tasks to finish and then stops the executor
     */
    fun stop() {
        check(initialized) { "Can't shut down an uninitialized executor" }
        logger.info { "Shutting Down" }
        channel.close()
        connection.close()
    }

    /**
     * Adds the given [name] as a queue to watch
     */
    fun addQueue(name: String) {
        withRabbitMqChannel(true) {
            logger.debug { "Adding binding for queue $name" }
            channel.queueBindNoWait(ephemeralQueue, EXECUTOR_EXCHANGE_NAME, name, null)
        }
    }

    /**
     * Removes the given [name] as a queue to watch
     */
    fun removeQueue(name: String) {
        if (name == "") {
            error("Can't unbind the default queue")
        }
        withRabbitMqChannel(true) {
            logger.debug { "Removing binding for queue $name" }
            channel.queueUnbind(ephemeralQueue, EXECUTOR_EXCHANGE_NAME, name)
        }
    }

    private fun withRabbitMqConnection(global: Boolean = false, runnable: (Connection) -> Unit) {
        if (global) {
            runnable(connection)
        } else {
            rabbitMqConnectionFactory.newConnection().use(runnable)
        }
    }

    private fun withRabbitMqChannel(global: Boolean = false, runnable: (Channel) -> Unit) {
        if (global) {
            runnable(channel)
        } else {
            withRabbitMqConnection(true) {
                it.createChannel().use(runnable)
            }
        }
    }

}