import Config

config :amqp,
  connections: [
    main: [url: "amqp://guest:guest@172.17.0.2:5672"]
  ],
  channels: [
    main: [
      connection: :main
    ]
  ]

config :task_scheduler,
  db_username: "root",
  db_password: "root",
  db_host: "localhost",
  db_port: 3306,
  db_database: "task_scheduler"
