require 'bunnyrun/consumer'
require 'bunnyrun/cli'
require 'bunnyrun/runner'
require 'bunnyrun/version'

module BunnyRun
  class << self
    def publish(exchange_name, payload, attrs = {}); end

    def after_start(&block)
      callbacks[:after_start] ||= []
      callbacks[:after_start] << block
    end

    private

    def callbacks
      @callbacks ||= {}
    end
  end
end
