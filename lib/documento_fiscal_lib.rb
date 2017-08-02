require 'active_support/core_ext/hash'

require 'documento_fiscal_lib/conjunto'
require 'documento_fiscal_lib/nfe'

module DocumentoFiscalLib

  def self.nfe(xml_or_hash)
    DocumentoFiscalLib::Nfe.new xml_or_hash
  end

end