require 'rails'
require 'documento_fiscal_lib/concerns/hash_find'
require 'documento_fiscal_lib/engine'
require 'documento_fiscal_lib/nfe'

module DocumentoFiscalLib

  def self.nfe(xml_or_hash)
    DocumentoFiscalLib::Nfe.new xml_or_hash
  end

end