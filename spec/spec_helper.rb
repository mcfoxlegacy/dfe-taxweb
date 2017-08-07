# ~~~~ PARA ENVIAR A COBERTURA DE TESTE DO CODACY DESCOMENTE AS DUAS LINHAS ABAIXO
# require 'codacy-coverage'
# Codacy::Reporter.start
# ~~~~ E EXECUTE NO TERMINAL O COMANDO ABAIXO:
# CODACY_PROJECT_TOKEN=777f4d2ca8794cb485439289ceb35303 CODACY_RUN_LOCAL=true rspec

require 'simplecov'
SimpleCov.start
SimpleCov.start do
  SimpleCov.start do
    add_group 'Arquivos', ['dfe_taxweb', 'lib/dfe_taxweb']
    add_filter 'spec'
  end
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "dfe_taxweb"

Dir["spec/support/**/*.rb"].each { |f| load f }
Dir["spec/shared_examples/**/*.rb"].each { |f| load f }

RSpec.configure do |config|
  config.mock_with :rspec
end
