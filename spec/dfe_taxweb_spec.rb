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

  describe ".atributo" do
    subject { described_class.atributo('emitente.cnpj') }

    it "retorna uma instância de DfeTaxweb::Atributo com o conteúdo do cnpj do emitente" do
      expect(subject).to be_a(DfeTaxweb::Atributo)
    end
  end

  describe ".atributos" do
    subject { described_class.atributos}

    it "retorna uma nova instância de DfeTaxweb::Nfe" do
      expect(subject).to be_a(DfeTaxweb::Atributos)
    end

    it "retorna uma nova instância de DfeTaxweb::Nfe" do
      emitente = subject.atributo('emitente')
      expect(emitente).to be_a(DfeTaxweb::Atributo)
      expect(emitente.titulo).to be_a(String)
    end
  end

end