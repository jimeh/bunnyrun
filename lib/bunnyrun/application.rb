# frozen_string_literal: true

require 'trollop'

require 'bunnyrun/consumer'
require 'bunnyrun/runner'
require 'bunnyrun/version'

module BunnyRun
  class Application
    class << self
      def run(*args)
        new.run(*args)
      end

      def name(input = nil)
        @name = input unless input.nil?
        @name
      end

      def usage(input = nil)
        @usage = input unless input.nil?
        @usage
      end

      def version(input = nil)
        @version = input unless input.nil?
        @version
      end

      def option(name, description, opts)
        options << [name, description, opts]
      end

      def options
        @options ||= []
      end
    end

    def name
      self.class.name
    end

    def usage
      self.class.usage
    end

    def version
      self.class.version
    end

    def run(opts = {})
      argv = opts.delete(:argv)
      options = parse_args(argv)
      options.merge!(opts)

      require_files(options[:paths]) if options[:paths].any?
      consumers = Consumer.children

      runner = Runner.new(options, consumers)
      runner.run
    end

    private

    def parse_args(args)
      args = args.clone

      opts = Trollop.with_standard_exception_handling(parser) do
        parser.parse(args)
      end
      opts[:paths] = args

      opts
    end

    def parser
      @parser ||= begin
        parser = Trollop::Parser.new
        define_version(parser)
        define_usage(parser)

        define_connection_options(parser)
        define_logging_options(parser)
        define_application_options(parser)

        parser.banner "\nHelp/Version:"
        parser
      end
    end

    def define_usage(parser)
      parser.banner "Usage: #{name} #{usage}"
    end

    def define_version(parser)
      parser.version "#{name} #{version}"
    end

    def define_connection_options(parser)
      parser.banner "\nRabbitMQ Options:"

      parser.opt :url, 'Connection string ' \
                       '(example: "amqp://guest:guest@127.0.0.1:5672/vhost")',
                 short: 'U', type: :string,
                 default: ENV.fetch('RABBITMQ_URL', nil)

      parser.opt :host, 'Host',
                 short: 'H', type: :string,
                 default: ENV.fetch('RABBITMQ_HOST', '127.0.0.1')

      parser.opt :port, 'Port',
                 short: 'P', type: :int,
                 default: ENV.fetch('RABBITMQ_PORT', '5672').to_i

      parser.opt :ssl, 'Connect using SSL',
                 short: 's', type: :bool,
                 default: trufy?(ENV.fetch('RABBITMQ_SSL', false))

      parser.opt :vhost, 'Virtual host',
                 short: 'V', type: :string,
                 default: ENV.fetch('RABBITMQ_VHOST', '/')

      parser.opt :user, 'Username',
                 short: 'u', type: :string,
                 default: ENV.fetch('RABBITMQ_USER', 'guest')

      parser.opt :pass, 'Password',
                 short: 'p', type: :string,
                 default: ENV.fetch('RABBITMQ_PASS', 'guest')

      parser.opt :prefetch, 'Default prefetch count',
                 short: :none, type: :int,
                 default: ENV.fetch('RABBITMQ_PREFETCH', 1).to_i

      parser.conflicts :url, :host
      parser.conflicts :url, :port
      parser.conflicts :url, :ssl
      parser.conflicts :url, :vhost
      parser.conflicts :url, :user
      parser.conflicts :url, :pass
    end

    def define_logging_options(parser)
      parser.banner "\nLogging Options:"

      parser.opt :log_target, 'Log target, file path or STDOUT',
                 short: 't', type: :string,
                 default: ENV.fetch('LOG_TARGET', 'STDOUT')

      parser.opt :log_level, 'Log level (debug, info, warn, error, fatal)',
                 short: 'l', type: :string,
                 default: ENV.fetch('LOG_LEVEL', 'info')

      parser.opt :bunny_log_target, 'Log target used by Bunny',
                 short: :none, type: :string,
                 default: ENV.fetch('BUNNY_LOG_TARGET', 'STDOUT')

      parser.opt :bunny_log_level, 'Log level used by Bunny',
                 short: :none, type: :string,
                 default: ENV.fetch('BUNNY_LOG_LEVEL', 'warn')
    end

    def define_application_options(parser)
      return if self.class.options.empty?

      parser.banner "\nApplication Options:"
      self.class.options.each do |opt_args|
        parser.opt(*opt_args)
      end
    end

    def trufy?(input)
      %w[true 1 y yes].include?(input)
    end

    def require_files(paths)
      paths.each do |path|
        require File.expand_path(path)
      end
    end
  end
end
