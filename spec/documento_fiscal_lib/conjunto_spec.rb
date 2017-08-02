require "spec_helper"

describe DocumentoFiscalLib::Conjunto do
  subject {described_class.new({fake: true})}

  describe "#initialize" do
    it "atribui o hash informado como conjunto" do
      expect(subject.conjunto).to eq({fake: true})
    end
  end

  describe "#to_h" do
    it "retorna o conjunto informado como hash" do
      expect(subject.to_h).to eq(subject.conjunto)
    end
  end

  describe "#[]" do
    it "retorna o item do conjunto pela chave" do
      expect(subject[:fake]).to eq(true)
    end
  end

  describe "#atributo" do
    it "retorna o atributo do conjunto pelo caminho" do

    end
  end

  describe "#atualizar" do
    it "atualiza ou cria o valor no conjunto seguindo o caminho informado" do

    end
  end

  describe "#normaliza_valores" do
    it "retorna uma nova instancia do conjunto caso o valor informado seja um Hash" do
      expect(subject.send(:normaliza_valores, {teste: true})).to be_a(DocumentoFiscalLib::Conjunto)
    end
    it "retorna o valor informado caso ele não seja um hash" do
      expect(subject.send(:normaliza_valores, 'teste')).to eq('teste')
    end
  end


end