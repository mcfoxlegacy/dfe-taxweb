require 'spec_helper'

describe DfeTaxweb do

  it 'possui um número de versão' do
    expect(DfeTaxweb::VERSION).not_to be_nil
  end

  describe ".nfe" do
    let(:nfe_xml_string){File.read("spec/fixtures/files/nfe.xml")}
    subject { described_class.nfe(nfe_xml_string) }

    it "retorna uma nova instância de DfeTaxweb::Nfe" do
      expect(subject).to be_a(DfeTaxweb::Nfe)
    end
  end

end