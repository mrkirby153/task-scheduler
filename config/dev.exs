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
