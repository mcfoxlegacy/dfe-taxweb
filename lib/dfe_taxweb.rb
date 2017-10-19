# http://guides.rubyonrails.org/active_support_core_extensions.html
require 'active_support/core_ext/hash'
require 'active_support/core_ext/enumerable'

require 'dfe_taxweb/atributo'
require 'dfe_taxweb/atributos'
require 'dfe_taxweb/conjunto'
require 'dfe_taxweb/nfe'

module DfeTaxweb

  def self.nfe(xml_or_hash)
    DfeTaxweb::Nfe.new xml_or_hash
  end

  def self.atributo(path, hash=nil)
    DfeTaxweb::Atributos.instance.atributo(path, hash)
  end

  def self.atributos
    DfeTaxweb::Atributos.instance
  end

end