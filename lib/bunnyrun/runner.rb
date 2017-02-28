require 'bunny'
require 'logger'

require 'bunnyrun/consumer'

module BunnyRun
  class Runner
    attr_reader :options
    attr_reader :consumer_classes

    def initialize(options = {}, consumer_classes)
      @options = options
      @consumer_classes = consumer_classes
    end

    def run
      consumer_classes.each do |consumer_class|
        launch_consumer(consumer_class)
      end

      block
    end

    def connection
      @connection ||= begin
        conn = Bunny.new(connection_opts)
        conn.start
        conn
      end
    end

    def publish_channel
      @publish_channel ||= connection.create_channel
    end

    def logger
      @logger ||= begin
        logger = Logger.new(log_target)
        logger.level = log_level
        logger
      end
    end

    private

    def block
      loop { sleep 1 }
    end

    def launch_consumer(consumer_class)
      consumer = consumer_class.new(
        connection: connection,
        publish_channel: publish_channel,
        default_prefetch: options.prefetch,
        logger: logger
      )
      consumer.start
    end

    def connection_opts
      return options.url if options.url

      {
        host: options.host,
        port: options.port,
        ssl: options.ssl,
        vhost: options.vhost,
        user: options.user,
        pass: options.pass
      }
    end

    def log_target
      if options.log_target.casecmp('stdout').zero?
        STDOUT
      else
        options.log_target
      end
    end

    def log_level
      Kernel.const_get("::Logger::#{options.log_level.upcase}")
    end
  end
end
