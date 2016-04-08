ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require File.expand_path '../../my_app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() MyApp end
end

RSpec.configure do |config|
  config.include RSpecMixin
end
