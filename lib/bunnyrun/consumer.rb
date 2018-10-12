# frozen_string_literal: true

require 'bunnyrun/message'

module BunnyRun
  class Consumer
    attr_reader :connection
    attr_reader :publish_channel
    attr_reader :default_prefetch
    attr_reader :options
    attr_reader :logger

    class << self
      def inherited(klass)
        children << klass
      end

      def children
        @children ||= []
      end

      def queue(name = nil, attrs = {})
        return @queue if name.nil?

        @queue = { name: name, attrs: attrs }
      end

      def exchange(name, attrs = {})
        exchanges[name] = attrs
      end

      def bind(exchange_name, attrs = {})
        bindings << [exchange_name, attrs]
      end

      def manual_ack(value = nil)
        return @manual_ack || false if value.nil?

        @manual_ack = value
      end

      def prefetch(count = nil)
        return @prefetch if count.nil?

        @prefetch = count
      end

      def exchanges
        @exchanges ||= {}
      end

      def bindings
        @bindings ||= []
      end
    end

    def initialize(opts = {})
      @connection = opts[:connection]
      @publish_channel = opts[:publish_channel]
      @default_prefetch = opts[:default_prefetch]
      @options = opts[:options]
      @logger = opts[:logger]
    end

    def channel
      @channel ||= connection.create_channel
    end

    def start
      perform_bindings
      set_prefetch
      subscribe
    end

    def subscribe
      logger.info("#{self.class}: subscribing to queue \"#{queue.name}\"...")

      opts = { manual_ack: self.class.manual_ack }
      queue.subscribe(opts) do |delivery_info, properties, payload|
        message = Message.new(delivery_info, properties, payload)

        logger.debug("#{self.class}: received message #{message}")
        perform(message)
      end
    end

    def publish(exchange_name, payload, attrs = {})
      exch = publish_exchange(exchange_name)
      exch.publish(payload, attrs)
    end

    def queue
      @queue ||= begin
        opts = self.class.queue
        channel.queue(opts[:name], opts[:attrs])
      end
    end

    def exchange(name)
      exchanges[name] ||= begin
        return unless self.class.exchanges.key?(name)

        attrs = self.class.exchanges[name]
        channel.exchange(name, attrs)
      end
    end

    def publish_exchange(name)
      publish_exchanges[name] ||= begin
        return unless self.class.exchanges.key?(name)

        attrs = self.class.exchanges[name]
        publish_channel.exchange(name, attrs)
      end
    end

    private

    def perform_bindings
      self.class.bindings.each do |(exchange_name, attrs)|
        exch = exchange(exchange_name)
        queue.bind(exch, attrs)
      end
    end

    def set_prefetch
      count = self.class.prefetch || default_prefetch
      channel.prefetch(count, true)
    end

    def exchanges
      @exchanges ||= {}
    end

    def publish_exchanges
      @publish_exchanges ||= {}
    end
  end
end
