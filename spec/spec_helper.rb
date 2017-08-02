require 'simplecov'
SimpleCov.start
SimpleCov.start do
  SimpleCov.start do
    add_group 'Arquivos', ['documento_fiscal_lib', 'lib/documento_fiscal_lib']
    add_filter 'spec'
  end
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "documento_fiscal_lib"

Dir["spec/support/**/*.rb"].each { |f| load f }
Dir["spec/shared_examples/**/*.rb"].each { |f| load f }

RSpec.configure do |config|
  config.mock_with :rspec
end
