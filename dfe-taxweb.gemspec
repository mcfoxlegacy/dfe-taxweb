lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'dfe_taxweb/version'

Gem::Specification.new do |spec|
  spec.name          = 'dfe-taxweb'
  spec.version       = DfeTaxweb::VERSION
  spec.authors       = ['Bruno Porto']
  spec.email         = ['brunotporto@gmail.com']
  spec.summary       = 'Biblioteca Documento Fiscal TaxWeb'
  spec.description   = 'Biblioteca Documento Fiscal TaxWeb. Conversão de NFe para DFe-TaxWeb'
  spec.homepage      = 'https://github.com/taxweb/dfe-taxweb/'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.license = 'MIT'
  spec.files = Dir["lib/**/*"]
  spec.test_files = Dir["spec/**/*"]

  spec.add_dependency 'activesupport', ['>= 4', '<= 6']

  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'simplecov', '~> 0.14'
  spec.add_development_dependency 'codacy-coverage', '~> 1.1'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.1'
end
