require 'bunnyrun/consumer'
require 'bunnyrun/options'
require 'bunnyrun/runner'

module BunnyRun
  class CLI
    attr_reader :options

    def self.run(argv = [])
      new.run(argv)
    end

    def run(argv = [])
      options = Options.parse(argv)
      require_files(options.paths)
      consumers = Consumer.children

      runner = Runner.new(options, consumers)
      runner.run
    end

    private

    def require_files(paths)
      paths.each do |path|
        require File.join(Dir.pwd, path)
      end
    end
  end
end
