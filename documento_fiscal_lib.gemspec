require 'documento_fiscal_lib/version'

Gem::Specification.new do |spec|
  spec.name          = 'Biblioteca Documento Fiscal'
  spec.version       = DocumentoFiscalLib::VERSION
  spec.authors       = ['Bruno Porto']
  spec.email         = ['brunotporto@gmail.com']
  spec.summary       = 'Biblioteca Documento Fiscal'
  spec.description   = 'Biblioteca Documento Fiscal'
  spec.homepage      = 'https://github.com/taxweb/documento_fiscal_lib/'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.4'
end
