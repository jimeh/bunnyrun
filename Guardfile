# frozen_string_literal: true

group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: 'bundle exec rspec' do
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^spec/.+_spec\.rb$})
    watch('spec/spec_helper.rb') { 'spec' }
  end

  guard :rubocop do
    watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
    watch('Gemfile')
    watch('Guardfile')
    watch('Rakefile')
    watch(/.+\.gemspec$/)
    watch(/.+\.rb$/)
  end
end
