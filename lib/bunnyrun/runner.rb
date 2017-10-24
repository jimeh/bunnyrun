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
      @logger ||= create_logger(options.log_target, options.log_level)
    end

    def bunny_logger
      @bunny_logger ||= create_logger(
        options.bunny_log_target,
        options.bunny_log_level
      )
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
        options: options,
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
        pass: options.pass,
        logger: bunny_logger
      }
    end

    def create_logger(target, level)
      Logger.new(normalize_log_target(target)).tap do |l|
        l.level = Kernel.const_get("::Logger::#{level.upcase}")
      end
    end

    def normalize_log_target(input)
      if input.casecmp('stdout').zero?
        STDOUT
      else
        input
      end
    end
  end
end
