# frozen_string_literal: true

require 'bunnyrun'

module Foobar
  class PingConsumer < BunnyRun::Consumer
    queue 'ping'

    exchange 'ping-pong', type: :direct
    bind 'ping-pong', routing_key: 'ping'

    manual_ack true # default is false

    def perform(message)
      logger.info "#{self.class} received: #{message.payload}"
      sleep 1

      publish('ping-pong', 'PONG', routing_key: 'pong')
      message.ack

      return unless options.success_message
      logger.info("#{self.class}: #{options.success_message}")
    end
  end
end
