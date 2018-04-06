# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BunnyRun do
  it 'has a version number' do
    expect(BunnyRun::VERSION).not_to be nil
  end
end
