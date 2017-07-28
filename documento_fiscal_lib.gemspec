$:.push File.expand_path("../lib", __FILE__)

require 'documento_fiscal_lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'documento_fiscal_lib'
  spec.version       = DocumentoFiscalLib::VERSION
  spec.authors       = ['Bruno Porto']
  spec.email         = ['brunotporto@gmail.com']
  spec.summary       = 'Biblioteca Documento Fiscal'
  spec.description   = 'Biblioteca Documento Fiscal'
  spec.homepage      = 'https://github.com/taxweb/documento_fiscal_lib/'
  # spec.files = Dir["lib/**/*"]

  spec.add_development_dependency 'rspec', '~> 3.4'
end
