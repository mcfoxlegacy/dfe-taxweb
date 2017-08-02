require "spec_helper"

describe DocumentoFiscalLib::Nfe do
  let(:nfe_xml_string) {File.read("spec/fixtures/files/nfe.xml")}
  subject {described_class.new(nfe_xml_string)}

  describe "#para_documento_fiscal" do
    it "atribui o mapeamento do documento" do
      expect(subject).to receive(:mapear_documento).and_return({})
      expect(subject.para_documento_fiscal).to be_a(Hash)
    end
  end

  describe "#mapear_documento" do
    it "retorna o hash do documento fiscal mapeado com os valores da nfe" do
      expect(subject).to receive(:data_de_emissao).and_return(nil)
      expect(subject).to receive(:tipo_de_operacao).and_return(nil)
      expect(subject).to receive(:emitente).and_return({})
      expect(subject).to receive(:destinatario).and_return({})
      expect(subject).to receive(:retirada).and_return({})
      expect(subject).to receive(:entrega).and_return({})
      expect(subject).to receive(:itens).and_return([])
      documento = subject.mapear_documento
      expect(documento).to be_a(Hash)
      expect(documento.keys.sort).to eq([:idDocFiscal, :natOp, :tipoPagto, :modelo, :serie, :numero, :dtEmissao, :dtES, :dtPagto, :cMunFG, :refNFP, :refCTE, :refECF, :tpImp, :tpEmis, :cDV, :tpAmb, :finNFe, :procEmi, :verProc, :dhCont, :xJust, :emitente, :destinatario, :retirada, :entrega, :itensDocFiscal, :tipoOperacao, :tpDocFiscal, :naturezaOperacao].sort)
    end
  end

  describe "#emitente" do
    it "retorna o hash de emitente" do
      expect(subject).to receive(:endereco).and_return({})
      expect(subject.emitente.keys.sort).to eq([:cnpj, :cpf, :nome, :xFant, :inscricaoEstadual, :IEST, :inscricaoMunicipal, :cdAtividadeEconomica, :contribuinteICMS, :contribuinteST, :contribuinteISS, :contribuintePIS, :contribuinteCOFINS, :contribuinteII, :simplesNac].sort)
    end
  end

  describe "#destinatario" do
    it "retorna o hash de destinatario" do
      expect(subject).to receive(:endereco).and_return({})
      expect(subject.destinatario.keys.sort).to eq([:cnpj, :cpf, :nome, :inscricaoEstadual, :contribuinteICMS, :contribuintePIS, :contribuinteCOFINS, :contribuinteII, :ISUF, :email].sort)
    end
  end

  describe "#endereco" do
    it "retorna o hash dos dados do endereço quando informado um hash válido" do
      fake_hash = DocumentoFiscalLib::Conjunto.new({fake: true})
      expect(subject).to receive(:codigo_pais).and_return('')
      expect(subject.endereco(fake_hash).keys.sort).to eq([:xLgr, :Nro, :xCpl, :xBairro, :cdMunicipio, :xMun, :uf, :cep, :cdPais, :xPais, :fone].sort)
    end
    it "retorna {} quando não é informado um endereço válido" do
      expect(subject.endereco({})).to eq({})
      expect(subject.endereco(nil)).to eq({})
    end
  end

  describe "#retirada" do
    it "retorna o hash de retirada" do
      expect(subject).to receive_message_chain(:inf_nfe).and_return(DocumentoFiscalLib::Conjunto.new({retirada: {fake: true}}))
      expect(subject.retirada).to be_a(DocumentoFiscalLib::Conjunto)
    end
    it "retorna nil quando não há retirada" do
      expect(subject.retirada).to be_nil
    end
  end

  describe "#entrega" do
    it "retorna o hash de entrega" do
      expect(subject).to receive(:inf_nfe).and_return(DocumentoFiscalLib::Conjunto.new({entrega: {fake: true}}))
      expect(subject.entrega).to be_a(DocumentoFiscalLib::Conjunto)
    end
    it "retorna nil quando não há entrega" do
      expect(subject.retirada).to be_nil
    end
  end

  describe "#itens" do
    # it "retorna o array com os itens da NFe" do
    #   expect(subject).to receive(:inf_nfe).and_return(DocumentoFiscalLib::Conjunto.new({entrega: {fake: true}}))
    #   expect(subject.entrega).to be_a(DocumentoFiscalLib::Conjunto)
    # end
    # it "retorna [] quando não há itens" do
    #   expect(subject.itens).to be_nil
    # end
  end

  describe "#produto_do_item" do
    it "retorna os atributos do produto do item informado" do
      item = DocumentoFiscalLib::Conjunto.new({prod: {fake: true}})
      expect(subject.produto_do_item(item).keys.sort).to eq([:indTot, :cEANTrib, :codigo, :EAN, :descricao, :NCM, :CEST, :exTIPI, :aplicacao, :cdOrigem].sort)
    end
    it "retorna {} quando não produto no item" do
      item = DocumentoFiscalLib::Conjunto.new({prod: {}})
      expect(subject.produto_do_item(item)).to eq({})
    end
  end

  describe "#icms_do_item" do

  end

  describe "#ipi_do_item" do

  end

  describe "#pis_do_item" do

  end

  describe "#enquadramentos_do_item" do

  end

  describe "#enquadramento_icms" do

  end

  describe "#enquadramento_icmsst" do

  end

  describe "#enquadramento_icmsste" do

  end

  describe "#enquadramento_ipi" do

  end

  describe "#enquadramento_ii" do

  end

  describe "#enquadramento_pis" do

  end

  describe "#enquadramento_pisst" do

  end

  describe "#enquadramento_cofins" do

  end

  describe "#enquadramento_cofinsst" do

  end

  describe "#data_de_emissao" do
    let(:inf_nfe) {DocumentoFiscalLib::Conjunto.new({ide: {dEmi: nil, dhEmi: nil}})}
    it "retorna data de emissão dEmi" do
      expect(subject).to receive(:inf_nfe).and_return(inf_nfe)
      expect(inf_nfe).to receive(:atributo).with('ide.dEmi').and_return(1)
      expect(subject.data_de_emissao).to eq(1)
    end
    it "retorna data de emissão dhEmi caso dEmi não exista" do
      expect(subject).to receive(:inf_nfe).twice.and_return(inf_nfe)
      expect(inf_nfe).to receive(:atributo).with('ide.dEmi').and_return(nil)
      expect(inf_nfe).to receive(:atributo).with('ide.dhEmi').and_return(2)
      expect(subject.data_de_emissao).to eq(2)
    end
  end

  describe "#tipo_de_operacao" do
    let(:inf_nfe) {DocumentoFiscalLib::Conjunto.new({emit: {UF: nil}, dest: {UF: nil}})}
    before(:each) {expect(subject).to receive(:inf_nfe).twice.and_return(inf_nfe)}
    it "retorna E caso UF do emitente seja igual a UF do destinatário" do
      expect(inf_nfe).to receive(:atributo).with('emit.UF').and_return('SP')
      expect(inf_nfe).to receive(:atributo).with('dest.UF').and_return('SP')
      expect(subject.tipo_de_operacao).to eq('E')
    end
    it "retorna I caso UF do emitente seja diferente da UF do destinatário" do
      expect(inf_nfe).to receive(:atributo).with('emit.UF').and_return('SP')
      expect(inf_nfe).to receive(:atributo).with('dest.UF').and_return('RJ')
      expect(subject.tipo_de_operacao).to eq('I')
    end
    it "retorna nil caso a UF do emitente ou a UF do destinatário não tenha sido informada" do
      expect(inf_nfe).to receive(:atributo).with('emit.UF').and_return('SP')
      expect(inf_nfe).to receive(:atributo).with('dest.UF').and_return(nil)
      expect(subject.tipo_de_operacao).to be_nil
    end
  end

  describe "#codigo_pais" do
    it "retorna 105 caso o código do país seja nil ou 1058" do
      expect(subject.codigo_pais(nil)).to eq('105')
      expect(subject.codigo_pais('1058')).to eq('105')
    end
    it "retorna o valor informado quando diferentes de nil e 1058" do
      expect(subject.codigo_pais('0000')).to eq('0000')
    end
  end


  describe "#origem_do_produto" do

  end

  describe "#cst_icms_do_item" do

  end

  describe "#cst_ipi_do_item" do

  end

  describe "#cst_pis_do_item" do

  end

  describe "#cst_cofins_do_item" do

  end

  describe "#situacao_do_icms_cst" do

  end

  describe "#quantidade_tributaria_do_item" do

  end

  describe "#inf_nfe" do

  end

end