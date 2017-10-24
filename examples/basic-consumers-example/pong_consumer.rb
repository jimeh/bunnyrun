# frozen_string_literal: true

require 'bunnyrun'

class PongConsumer < BunnyRun::Consumer
  queue 'pong'

  exchange 'ping-pong', type: :direct
  bind 'ping-pong', routing_key: 'pong'

  manual_ack true # default is false

  def perform(message)
    logger.info "#{self.class} received: #{message.payload}"
    sleep 1

    publish('ping-pong', 'PING', routing_key: 'ping')
    message.ack
  end
end
