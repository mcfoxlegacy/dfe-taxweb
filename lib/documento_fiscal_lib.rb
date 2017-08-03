# http://guides.rubyonrails.org/active_support_core_extensions.html
require 'active_support/core_ext/hash'
require 'active_support/core_ext/enumerable'

require 'documento_fiscal_lib/conjunto'
require 'documento_fiscal_lib/nfe'

module DocumentoFiscalLib

  def self.nfe(xml_or_hash)
    DocumentoFiscalLib::Nfe.new xml_or_hash
  end

end