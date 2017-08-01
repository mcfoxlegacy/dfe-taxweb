require "spec_helper"

describe DocumentoFiscalLib::Nfe do
  let(:nfe_xml_string){File.read("spec/fixtures/files/nfe.xml")}
  subject { described_class.new(nfe_xml_string) }

  describe "#to_docfiscal" do
    it "returns an hash" do
      # expect(subject.to_docfiscal).to be_a(Hash)
      expect(subject.to_docfiscal).to eq(2)
    end
  end

  describe "#atributo" do
    it "returns an hash" do
      # expect(subject.nfe.atributo('nfeProc.NFe.infNFe.versao')).to eq('2.00')
    end
  end

end