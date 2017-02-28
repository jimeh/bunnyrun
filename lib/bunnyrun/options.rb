require 'trollop'

require 'bunnyrun/core_ext/string'

module BunnyRun
  class Options
    class << self
      def parse(argv = [])
        args = argv.clone

        opts = parse_args(args)
        opts[:paths] = args

        validate_paths(opts)

        opts.each_with_object(new) do |(key, value), memo|
          memo.send("#{key}=", value) if memo.respond_to?("#{key}=")
        end
      end

      private

      def parse_args(args)
        Trollop.with_standard_exception_handling(parser) do
          parser.parse(args)
        end
      end

      def validate_paths(opts)
        parser.die('One or more paths to consumers required', nil) \
          if opts[:paths].empty?
      end

      def parser
        return @parser if @parser

        defaults = new
        @parser = Trollop::Parser.new do
          banner <<-EOF.undent
            Usage: bunnyrun [options] [path ...]

            Options:
          EOF

          version "bunnyrun #{BunnyRun::VERSION}"
          opt :url, 'Connection string ' \
                    '(example: "amqp://guest:guest@127.0.0.1:5672/vhost")',
              short: 'U', type: :string, default: defaults.url
          opt :host, 'Host',
              short: 'H', type: :string, default: defaults.host
          opt :port, 'Port',
              short: 'P', type: :int, default: defaults.port
          opt :ssl, 'Connect using SSL',
              short: 's', type: :bool, default: defaults.ssl
          opt :vhost, 'Virtual host',
              short: 'V', type: :string, default: defaults.vhost
          opt :user, 'Username',
              short: 'u', type: :string, default: defaults.user
          opt :pass, 'Password',
              short: 'p', type: :string, default: defaults.pass
          opt :prefetch, 'Default prefetch count',
              short: :none, type: :int, default: defaults.prefetch

          banner ''

          opt :log_target, 'Log target, file path or STDOUT',
              short: 't', type: :string, default: defaults.log_target
          opt :log_level, 'Log level (debug, info, warn, error, fatal)',
              short: 'l', type: :string, default: defaults.log_level
          opt :bunny_log_target, 'Log target used by Bunny',
              short: :none, type: :string, default: defaults.bunny_log_target
          opt :bunny_log_level, 'Log level used by Bunny',
              short: :none, type: :string, default: defaults.bunny_log_level

          conflicts :url, :host
          conflicts :url, :port
          conflicts :url, :ssl
          conflicts :url, :vhost
          conflicts :url, :user
          conflicts :url, :pass

          banner ''
        end
      end
    end

    def url
      @url ||= nil
    end
    attr_writer :url

    def host
      @host ||= '127.0.0.1'
    end
    attr_writer :host

    def port
      @port ||= 5672
    end
    attr_writer :port

    def ssl
      @ssl ||= false
    end
    attr_writer :ssl

    def vhost
      @vhost ||= '/'
    end
    attr_writer :vhost

    def user
      @user ||= 'guest'
    end
    attr_writer :user

    def pass
      @pass ||= 'guest'
    end
    attr_writer :pass

    def prefetch
      @prefetch ||= 1
    end
    attr_writer :prefetch

    def log_target
      @log_target ||= 'STDOUT'
    end
    attr_writer :log_target

    def log_level
      @log_level ||= 'info'
    end
    attr_writer :log_level

    def bunny_log_target
      @bunny_log_target ||= 'STDOUT'
    end
    attr_writer :bunny_log_target

    def bunny_log_level
      @bunny_log_level ||= 'warn'
    end
    attr_writer :bunny_log_level

    def paths
      @paths ||= []
    end
    attr_writer :paths
  end
end
