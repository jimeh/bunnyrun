# frozen_string_literal: true

require 'foobar/version'

module Foobar
  class Application < BunnyRun::Application
    name 'foobar'
    usage '<options> [<path>]'
    version Foobar::VERSION

    option :success_message, 'Message to log after success',
           type: :string, default: ENV['MESSAGE']
  end
end
