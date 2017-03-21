require 'trollop'

require 'bunnyrun/consumer'
require 'bunnyrun/runner'
require 'bunnyrun/version'

module BunnyRun
  class CLI
    def self.run(argv = [])
      new.run(argv)
    end

    def initialize(name: nil, version: nil, usage: nil)
      @name = name
      @version = version
      @usage = usage
    end

    def name
      @name ||= 'bunnyrun'
    end

    def version
      @version ||= BunnyRun::VERSION
    end

    def usage
      @usage ||= '[options] [path ...]'
    end

    def run(args = [])
      options = parse_args(args)

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

        parser.banner "\nOptions:"
        define_connection_options(parser)
        define_logging_options(parser)
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
      parser.opt :url, 'Connection string ' \
                       '(example: "amqp://guest:guest@127.0.0.1:5672/vhost")',
                 short: 'U', type: :string
      parser.opt :host, 'Host',
                 short: 'H', type: :string, default: '127.0.0.1'
      parser.opt :port, 'Port',
                 short: 'P', type: :int, default: 5672
      parser.opt :ssl, 'Connect using SSL',
                 short: 's', type: :bool, default: false
      parser.opt :vhost, 'Virtual host',
                 short: 'V', type: :string, default: '/'
      parser.opt :user, 'Username',
                 short: 'u', type: :string, default: 'guest'
      parser.opt :pass, 'Password',
                 short: 'p', type: :string, default: 'guest'
      parser.opt :prefetch, 'Default prefetch count',
                 short: :none, type: :int, default: 1

      parser.conflicts :url, :host
      parser.conflicts :url, :port
      parser.conflicts :url, :ssl
      parser.conflicts :url, :vhost
      parser.conflicts :url, :user
      parser.conflicts :url, :pass
    end

    def define_logging_options(parser)
      parser.opt :log_target, 'Log target, file path or STDOUT',
                 short: 't', type: :string, default: 'STDOUT'
      parser.opt :log_level, 'Log level (debug, info, warn, error, fatal)',
                 short: 'l', type: :string, default: 'info'
      parser.opt :bunny_log_target, 'Log target used by Bunny',
                 short: :none, type: :string, default: 'STDOUT'
      parser.opt :bunny_log_level, 'Log level used by Bunny',
                 short: :none, type: :string, default: 'warn'
    end

    def require_files(paths)
      paths.each do |path|
        require File.expand_path(path)
      end
    end
  end
end
