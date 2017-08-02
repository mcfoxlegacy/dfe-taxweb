require 'spec_helper'

describe DocumentoFiscalLib do

  it 'possui um número de versão' do
    expect(DocumentoFiscalLib::VERSION).not_to be_nil
  end

  describe ".nfe" do
    let(:nfe_xml_string){File.read("spec/fixtures/files/nfe.xml")}
    subject { described_class.nfe(nfe_xml_string) }

    it "retorna uma nova instância de DocumentoFiscalLib::Nfe" do
      expect(subject).to be_a(DocumentoFiscalLib::Nfe)
    end
  end

end