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
    it "retorna um objeto quando o caminho indica um hash" do
      expect(subject).to receive(:conjunto).and_return({a: {b: 1}})
      expect(subject.atributo('a')).to be_a(DocumentoFiscalLib::Conjunto)
    end
    it "retorna uma array de objeto quando o caminho indica uma array" do
      expect(subject).to receive(:conjunto).and_return({a: {b: [{c: 1}]}})
      atributo = subject.atributo('a.b')
      expect(atributo).to be_a(Array)
      expect(atributo.first).to be_a(DocumentoFiscalLib::Conjunto)
    end
    it "retorna o atributo do conjunto pelo caminho" do
      expect(subject).to receive(:conjunto).and_return({a: {b: 1}})
      expect(subject.atributo('a.b')).to eq(1)
    end
    it "retorna o atributo do conjunto pelo caminho mesmo com array" do
      expect(subject).to receive(:conjunto).and_return({a: {b: [{c: 1}]}})
      expect(subject.atributo('a.b[0].c')).to eq(1)
    end
    it "retorna nil para caminho inválido" do
      expect(subject).to receive(:conjunto).and_return({a: {b: 1}})
      expect(subject.atributo('a.c')).to be_nil
    end
  end

  describe "#atualizar" do
    let(:conjunto_obj){described_class.new({a: :b, c: :d})}
    it "faz um merge do hash informado com o hash do conjunto" do
      conjunto_obj.atualizar({a: :z})
      expect(conjunto_obj.conjunto).to eq({a: :z, c: :d})
    end
    it "retorna o proprio objeto possibilitando method chain" do
      conjunto_obj.atualizar(a: 1).atualizar(a: 2)
      expect(conjunto_obj.conjunto).to eq({a: 2, c: :d})
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