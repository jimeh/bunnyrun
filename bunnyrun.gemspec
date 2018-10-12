# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bunnyrun/version'

Gem::Specification.new do |spec|
  spec.name          = 'bunnyrun'
  spec.version       = BunnyRun::VERSION
  spec.authors       = ['Jim Myhrberg']
  spec.email         = ['contact@jimeh.me']

  spec.summary       = 'Easy to use runtime for bunny-based AMQP consumers.'
  spec.description   = 'Easy to use runtime for bunny-based AMQP consumers.'
  spec.homepage      = 'https://github.com/jimeh/bunnyrun'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(bin|test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.51'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.24'

  spec.add_runtime_dependency 'bunny', '~> 2.6'
  spec.add_runtime_dependency 'trollop', '~> 2.1.2'
end
