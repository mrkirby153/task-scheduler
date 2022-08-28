package com.mrkirby153.taskscheduler.db

import com.mrkirby153.taskscheduler.db.models.Tasks
import com.mrkirby153.taskscheduler.db.models.Triggers
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.SqlLogger
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.Transaction
import org.jetbrains.exposed.sql.addLogger

val TABLES = mutableListOf<Table>(Tasks, Triggers)

/**
 * The database configuration
 */
object DB {
    lateinit var db: Database

    private var loggers = mutableListOf<SqlLogger>()

    fun logQueriesToStdout() {
        loggers.add(StdOutSqlLogger)
    }

    fun initialize() {
        this.transaction {
            SchemaUtils.createMissingTablesAndColumns(*TABLES.toTypedArray())
        }
    }


    /**
     * Wrapper for [org.jetbrains.exposed.sql.transactions.transaction] but populated with
     * the [db]
     */
    internal fun transaction(body: Transaction.() -> Unit) {
        org.jetbrains.exposed.sql.transactions.transaction(db) {
            loggers.forEach {
                addLogger(it)
            }
            body(this)
        }
    }
}