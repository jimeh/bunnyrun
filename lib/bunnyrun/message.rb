module BunnyRun
  class Message
    attr_reader :delivery_info
    attr_reader :properties
    attr_reader :payload

    def initialize(delivery_info, properties, payload)
      @delivery_info = delivery_info
      @properties = properties
      @payload = payload
      @acked = false
    end

    def channel
      delivery_info.channel
    end

    def ack
      channel.ack(delivery_tag)
      @acked = true
    end

    def reject
      channel.reject(delivery_tag, false)
      @acked = true
    end

    def requeue
      channel.reject(delivery_tag, true)
      @acked = true
    end

    def manual_ack?
      !delivery_info.consumer.no_ack
    end

    def routing_key
      delivery_info.routing_key
    end

    def delivery_mode
      properties.delivery_mode
    end

    def delivery_tag
      delivery_info.delivery_tag
    end
  end
end
