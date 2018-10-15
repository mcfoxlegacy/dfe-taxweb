require "spec_helper"

describe DfeTaxweb::Nfe do
  # let(:nfe_xml_string) {File.read("spec/fixtures/files/nfe.xml")}
  subject {described_class.new('<xml></xml>')}

  describe "#initialize" do
    it "requer o envio de 1 parametro" do
      expect{described_class.new}.to raise_error(ArgumentError)
    end
    it "requer o parametro como sendo hash ou xml_string" do
      expect(described_class.new({fake: true})).to be_a(DfeTaxweb::Nfe)
      expect(described_class.new('<xml></xml>')).to be_a(DfeTaxweb::Nfe)
    end
    it "retorna TypeError caso o parametro não seja Hash ou XmlString" do
      expect{described_class.new([])}.to raise_error(TypeError)
      expect{described_class.new('')}.to raise_error(TypeError)
      expect{described_class.new(1)}.to raise_error(TypeError)
      expect{described_class.new(Object.new)}.to raise_error(TypeError)
    end
  end

  describe "#to_dfe" do
    it "atribui o mapeamento do documento" do
      expect(subject).to receive(:mapear_documento).and_return({})
      expect(subject.to_dfe).to be_a(Hash)
    end

    it "converte nfe com entrega" do
      dfe_taxweb = described_class.new(File.read("spec/fixtures/files/nfe_com_entrega.xml"))
      dfe = dfe_taxweb.to_dfe
      expect(dfe[:entrega]).to be_a(Hash)
    end

    it "converte nfe com DI" do
      dfe_taxweb = described_class.new(File.read("spec/fixtures/files/nfe_com_di.xml"))
      dfe = dfe_taxweb.to_dfe
      expect(dfe[:itensDocFiscal][0][:DI]).to be_a(Hash)
    end

  end

  describe "#mapear_documento" do
    it "retorna o hash do documento fiscal mapeado com os valores da nfe" do
      expect(subject).to receive(:data_de_emissao).and_return(nil)
      expect(subject).to receive(:tipo_de_operacao).and_return(nil)
      expect(subject).to receive(:emitente).and_return({})
      expect(subject).to receive(:destinatario).and_return({})
      expect(subject).to receive(:itens).and_return([])
      documento = subject.mapear_documento
      expect(documento).to be_a(Hash)
      expect(documento.keys.sort).to eq([:destinatario, :emitente, :entrega, :indConsumidorFinal, :itensDocFiscal, :naturezaOperacao, :retirada, :tpDocFiscal].sort)
    end
  end

  describe "#emitente" do
    it "retorna o hash de emitente" do
      expect(subject).to receive(:endereco).and_return({})
      expect(subject.emitente).to be_a(Hash)
    end
  end

  describe "#destinatario" do
    it "retorna o hash de destinatario" do
      expect(subject).to receive(:endereco).and_return({})
      expect(subject.emitente).to be_a(Hash)
    end
  end

  describe "#endereco" do
    it "retorna o hash dos dados do endereço quando informado um hash válido" do
      fake_hash = DfeTaxweb::Conjunto.new({fake: true})
      expect(subject).to receive(:codigo_pais).and_return('')
      expect(subject.endereco(fake_hash).keys.sort).to eq([:cdPais].sort)
    end
    it "retorna {} quando não é informado um endereço válido" do
      expect(subject.endereco({})).to eq({})
      expect(subject.endereco(nil)).to eq({})
    end
  end

  describe "#itens" do
    it "retorna o hash de entrega" do
      expect(subject).to receive(:inf_nfe).and_return(DfeTaxweb::Conjunto.new({det: [{prod: {fake: true}}]}))
      expect(subject).to receive(:cst_icms_do_item).and_return(true)
      expect(subject).to receive(:cst_ipi_do_item).and_return(true)
      expect(subject).to receive(:cst_pis_do_item).and_return(true)
      expect(subject).to receive(:cst_cofins_do_item).and_return(true)
      expect(subject).to receive(:quantidade_tributaria_do_item).and_return(true)
      expect(subject).to receive(:produto_do_item).and_return({})
      expect(subject).to receive(:enquadramentos_do_item).and_return([])
      itens = subject.itens
      expect(itens).to be_a(Array)
      item = itens.first
      expect(item).to be_a(Hash)
      expect(item[:cdClassificacao]).to eq('M')
    end
    it "retorna array vazia quando não há itens" do
      expect(subject).to receive(:inf_nfe).and_return(DfeTaxweb::Conjunto.new({det: []}))
      expect(subject.itens).to eq([])
    end
  end

  describe "#produto_do_item" do
    it "retorna os atributos do produto do item informado" do
      item = DfeTaxweb::Conjunto.new({prod: {fake: true}})
      expect(subject.produto_do_item(item).keys.sort).to eq([:aplicacao].sort)
    end
    it "retorna {} quando não produto no item" do
      item = DfeTaxweb::Conjunto.new({prod: {}})
      expect(subject.produto_do_item(item)).to eq({})
    end
  end

  describe "#icms_do_item" do
    it "retorna o hash de informações do imposto ICMS" do
      ['ICMS00', 'ICMS10', 'ICMS20', 'ICMS30', 'ICMS40', 'ICMS51', 'ICMS60', 'ICMS70', 'ICMS90'].each do |tipo|
        item = DfeTaxweb::Conjunto.new({imposto: {ICMS: {tipo => {fake: true}}}})
        imposto = subject.icms_do_item(item)
        expect(imposto).to be_a(DfeTaxweb::Conjunto)
        expect(imposto.atributo('tipo')).to eq(tipo)
      end
    end
    it "retorna nil quando o icms não existe" do
      item = DfeTaxweb::Conjunto.new({imposto: {ICMS: {:ICMSFAKE => {fake: true}}}})
      expect(subject.icms_do_item(item)).to be_nil
    end
  end

  describe "#ipi_do_item" do
    it "retorna o hash de informações do imposto IPI" do
      ['IPINT', 'IPITrib'].each do |tipo|
        item = DfeTaxweb::Conjunto.new({imposto: {IPI: {tipo => {fake: true}}}})
        imposto = subject.ipi_do_item(item)
        expect(imposto).to be_a(DfeTaxweb::Conjunto)
        expect(imposto.atributo('tipo')).to eq(tipo)
      end
    end
    it "retorna apenas os dados básicos do IPI, caso subgrupo não exista" do
      item = DfeTaxweb::Conjunto.new({imposto: {IPI: {:IPIFAKE => {fake: true}}}})
      imposto = subject.ipi_do_item(item)
      expect(imposto).to be_a(DfeTaxweb::Conjunto)
      expect(imposto.atributo('tipo')).to be_nil
    end
  end

  describe "#pis_do_item" do
    it "retorna o hash de informações do imposto ICMS" do
      ['PISNT', 'PISAliq', 'PISQtde', 'PISOutr'].each do |tipo|
        item = DfeTaxweb::Conjunto.new({imposto: {PIS: {tipo => {fake: true}}}})
        imposto = subject.pis_do_item(item)
        expect(imposto).to be_a(DfeTaxweb::Conjunto)
        expect(imposto.atributo('tipo')).to eq(tipo)
      end
    end
    it "retorna nil quando o icms não existe" do
      item = DfeTaxweb::Conjunto.new({imposto: {PIS: {:PISFAKE => {fake: true}}}})
      expect(subject.pis_do_item(item)).to be_nil
    end
  end

  describe "#cofins_do_item" do
    it "retorna o hash de informações do imposto ICMS" do
      ['COFINSAliq', 'COFINSQtde', 'COFINSNT', 'COFINSOutr'].each do |tipo|
        item = DfeTaxweb::Conjunto.new({imposto: {COFINS: {tipo => {fake: true}}}})
        imposto = subject.cofins_do_item(item)
        expect(imposto).to be_a(DfeTaxweb::Conjunto)
        expect(imposto.atributo('tipo')).to eq(tipo)
      end
    end
    it "retorna nil quando o icms não existe" do
      item = DfeTaxweb::Conjunto.new({imposto: {COFINS: {:COFINSFAKE => {fake: true}}}})
      expect(subject.cofins_do_item(item)).to be_nil
    end
  end

  describe "#enquadramentos_do_item" do
    it "retorna um array com os impostos para enquadramento do item" do
      expect(subject).to receive(:enquadramento_icms).and_return(true)
      expect(subject).to receive(:enquadramento_icmsst).and_return(true)
      expect(subject).to receive(:enquadramento_icmsste).and_return(true)
      expect(subject).to receive(:enquadramento_ipi).and_return(true)
      expect(subject).to receive(:enquadramento_ii).and_return(true)
      expect(subject).to receive(:enquadramento_pis).and_return(true)
      expect(subject).to receive(:enquadramento_pisst).and_return(true)
      expect(subject).to receive(:enquadramento_cofins).and_return(true)
      expect(subject).to receive(:enquadramento_cofinsst).and_return(true)
      expect(subject.enquadramentos_do_item(nil).size).to eq(10)
    end
  end

  describe "#enquadramento_icms" do
    it "retorna hash com os atributos documento fiscal do icms" do
      expect(subject).to receive(:situacao_do_icms_cst).exactly(7).and_return(true)
      ['ICMS00', 'ICMS10', 'ICMS20', 'ICMS40', 'ICMS51', 'ICMS70', 'ICMS90'].each do |tipo|
        item = DfeTaxweb::Conjunto.new({tipo: tipo})
        enquadramento = subject.enquadramento_icms(item)
        expect(enquadramento).to be_a(Hash)
        expect(enquadramento[:dsSigla]).to eq('ICMS')
      end
    end
    it "retorna nil caso o item não exista ou não seja um dos grupos de icms esperados" do
      item = DfeTaxweb::Conjunto.new({tipo: :fake})
      expect(subject.enquadramento_icms(nil)).to be_nil
      expect(subject.enquadramento_icms(item)).to be_nil
    end
  end

  describe "#enquadramento_icmsst" do
    it "retorna hash com os atributos documento fiscal do icmsst" do
      expect(subject).to receive(:situacao_do_icms_cst).exactly(4).and_return(true)
      ['ICMS10', 'ICMS30', 'ICMS70', 'ICMS90'].each do |tipo|
        item = DfeTaxweb::Conjunto.new({tipo: tipo})
        enquadramento = subject.enquadramento_icmsst(item)
        expect(enquadramento).to be_a(Hash)
        expect(enquadramento[:dsSigla]).to eq('ST')
      end
    end
    it "retorna nil caso o item não exista ou não seja um dos grupos de icmsst esperados" do
      item = DfeTaxweb::Conjunto.new({tipo: :fake})
      expect(subject.enquadramento_icmsst(nil)).to be_nil
      expect(subject.enquadramento_icmsst(item)).to be_nil
    end
  end

  describe "#enquadramento_icmsste" do
    it "retorna hash com os atributos documento fiscal do icmsste" do
      expect(subject).to receive(:situacao_do_icms_cst).exactly(1).and_return(true)
      ['ICMS60'].each do |tipo|
        item = DfeTaxweb::Conjunto.new({tipo: tipo})
        enquadramento = subject.enquadramento_icmsste(item)
        expect(enquadramento).to be_a(Hash)
        expect(enquadramento[:dsSigla]).to eq('STE')
      end
    end
    it "retorna nil caso o item não exista ou não seja um dos grupos de icmsste esperados" do
      item = DfeTaxweb::Conjunto.new({tipo: :fake})
      expect(subject.enquadramento_icmsste(nil)).to be_nil
      expect(subject.enquadramento_icmsste(item)).to be_nil
    end
  end

  describe "#enquadramento_ipi" do
    it "retorna hash com os atributos documento fiscal do ipi" do
      item = DfeTaxweb::Conjunto.new({fake: true})
      enquadramento = subject.enquadramento_ipi(item)
      expect(enquadramento).to be_a(Hash)
      expect(enquadramento[:dsSigla]).to eq('IPI')
    end
    it "retorna nil caso o item do ipi seja enviado em branco" do
      expect(subject.enquadramento_icmsste(nil)).to be_nil
      expect(subject.enquadramento_icmsste({})).to be_nil
    end
  end

  describe "#enquadramento_ii" do
    it "retorna hash com os atributos documento fiscal do ii" do
      item = DfeTaxweb::Conjunto.new({vII: 1})
      enquadramento = subject.enquadramento_ii(item)
      expect(enquadramento).to be_a(Hash)
      expect(enquadramento[:dsSigla]).to eq('II')
    end
    it "retorna nil caso o item ii seja enviado em branco ou o atributo VII seja menor ou igual a zero" do
      item = DfeTaxweb::Conjunto.new({vII: 0})
      expect(subject.enquadramento_ii(nil)).to be_nil
      expect(subject.enquadramento_ii({})).to be_nil
      expect(subject.enquadramento_ii(item)).to be_nil
    end
  end

  describe "#enquadramento_pis" do
    it "retorna hash com os atributos documento fiscal do pis" do
      item = DfeTaxweb::Conjunto.new({fake: true})
      enquadramento = subject.enquadramento_pis(item)
      expect(enquadramento).to be_a(Hash)
      expect(enquadramento[:dsSigla]).to eq('PIS')
    end
    it "retorna nil caso o item pis seja enviado em branco" do
      expect(subject.enquadramento_pis(nil)).to be_nil
      expect(subject.enquadramento_pis({})).to be_nil
    end
  end

  describe "#enquadramento_pisst" do
    it "retorna hash com os atributos documento fiscal do pisst" do
      item = DfeTaxweb::Conjunto.new({fake: true})
      enquadramento = subject.enquadramento_pisst(item)
      expect(enquadramento).to be_a(Hash)
      expect(enquadramento[:dsSigla]).to eq('PISST')
    end
    it "retorna nil caso o item pisst seja enviado em branco" do
      expect(subject.enquadramento_pisst(nil)).to be_nil
      expect(subject.enquadramento_pisst({})).to be_nil
    end
  end

  describe "#enquadramento_cofins" do
    it "retorna hash com os atributos documento fiscal do cofins" do
      item = DfeTaxweb::Conjunto.new({fake: true})
      enquadramento = subject.enquadramento_cofins(item)
      expect(enquadramento).to be_a(Hash)
      expect(enquadramento[:dsSigla]).to eq('COFINS')
      expect(enquadramento[:situacao]).to eq('T')
    end
    it "retorna situacao N caso o tipo seja COFINSNT" do
      item = DfeTaxweb::Conjunto.new({tipo: 'COFINSNT'})
      enquadramento = subject.enquadramento_cofins(item)
      expect(enquadramento[:situacao]).to eq('N')
    end
    it "retorna nil caso o item pisst seja enviado em branco" do
      expect(subject.enquadramento_cofins(nil)).to be_nil
      expect(subject.enquadramento_cofins({})).to be_nil
    end
  end

  describe "#enquadramento_cofinsst" do
    it "retorna hash com os atributos documento fiscal do cofinsst" do
      item = DfeTaxweb::Conjunto.new({fake: true})
      enquadramento = subject.enquadramento_cofinsst(item)
      expect(enquadramento).to be_a(Hash)
      expect(enquadramento[:dsSigla]).to eq('COFINSST')
    end
    it "retorna nil caso o item cofinsst seja enviado em branco" do
      expect(subject.enquadramento_cofinsst(nil)).to be_nil
      expect(subject.enquadramento_cofinsst({})).to be_nil
    end
  end

  describe "#data_de_emissao" do
    let(:inf_nfe) {DfeTaxweb::Conjunto.new({ide: {dEmi: nil, dhEmi: nil}})}
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
    let(:inf_nfe) {DfeTaxweb::Conjunto.new({emit: {UF: nil}, dest: {UF: nil}})}
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
    it "retorna a origem do produto do ipi possua o atributo orig" do
      expect(subject).to receive_message_chain(:ipi_do_item, :atributo).and_return(1)
      expect(subject.origem_do_produto({})).to eq(1)
    end
    it "retorna a orig do produto do icms caso não possua a orig no ipi" do
      expect(subject).to receive_message_chain(:ipi_do_item, :atributo).and_return(nil)
      expect(subject).to receive_message_chain(:icms_do_item, :atributo).and_return(2)
      expect(subject.origem_do_produto({})).to eq(2)
    end
    it "retorna nil caso não tenha orig no ipi e nem no icms" do
      expect(subject).to receive_message_chain(:ipi_do_item, :atributo).and_return(nil)
      expect(subject).to receive_message_chain(:icms_do_item, :atributo).and_return(nil)
      expect(subject.origem_do_produto({})).to be_nil
    end
  end

  describe "#cst_icms_do_item" do
    let(:icms_do_item){Hash.new}
    it "retorna os atributos orig e CST concatenados caso ambos existam" do
      expect(subject).to receive(:icms_do_item).and_return(icms_do_item)
      expect(icms_do_item).to receive(:atributo).with('orig').and_return("A")
      expect(icms_do_item).to receive(:atributo).with('CST').and_return("B")
      expect(subject.cst_icms_do_item(icms_do_item)).to eq('AB')
    end
    it "retorna o atributo orig caso não haja CST" do
      expect(subject).to receive(:icms_do_item).and_return(icms_do_item)
      expect(icms_do_item).to receive(:atributo).with('orig').and_return("A")
      expect(icms_do_item).to receive(:atributo).with('CST').and_return(nil)
      expect(subject.cst_icms_do_item(icms_do_item)).to eq('A')
    end
    it "retorna o atributo CST caso orig" do
      expect(subject).to receive(:icms_do_item).and_return(icms_do_item)
      expect(icms_do_item).to receive(:atributo).with('orig').and_return(nil)
      expect(icms_do_item).to receive(:atributo).with('CST').and_return("B")
      expect(subject.cst_icms_do_item(icms_do_item)).to eq('B')
    end
    it "retorna nil caso não haja CST nem orig" do
      expect(subject).to receive(:icms_do_item).and_return(icms_do_item)
      expect(icms_do_item).to receive(:atributo).with('orig').and_return(nil)
      expect(icms_do_item).to receive(:atributo).with('CST').and_return(nil)
      expect(subject.cst_icms_do_item(icms_do_item)).to be_nil
    end
  end

  describe "#cst_ipi_do_item" do
    let(:ipi_do_item){Hash.new}
    it "retorna o CST do IPI" do
      expect(subject).to receive(:ipi_do_item).and_return(ipi_do_item)
      expect(ipi_do_item).to receive(:atributo).with('CST').and_return("A")
      expect(subject.cst_ipi_do_item(ipi_do_item)).to eq('A')
    end
    it "retorna nil caso não haja CST no IPI" do
      expect(subject).to receive(:ipi_do_item).and_return(ipi_do_item)
      expect(ipi_do_item).to receive(:atributo).with('CST').and_return(nil)
      expect(subject.cst_ipi_do_item(ipi_do_item)).to be_nil
    end
  end

  describe "#cst_pis_do_item" do
    let(:pis_do_item){Hash.new}
    it "retorna o CST do PIS" do
      expect(subject).to receive(:pis_do_item).and_return(pis_do_item)
      expect(pis_do_item).to receive(:atributo).with('CST').and_return("A")
      expect(subject.cst_pis_do_item(pis_do_item)).to eq('A')
    end
    it "retorna nil caso não haja CST no PIS" do
      expect(subject).to receive(:pis_do_item).and_return(pis_do_item)
      expect(pis_do_item).to receive(:atributo).with('CST').and_return(nil)
      expect(subject.cst_pis_do_item(pis_do_item)).to be_nil
    end
  end

  describe "#cst_cofins_do_item" do
    let(:cofins_do_item){Hash.new}
    it "retorna o CST do COFINS" do
      expect(subject).to receive(:cofins_do_item).and_return(cofins_do_item)
      expect(cofins_do_item).to receive(:atributo).with('CST').and_return("A")
      expect(subject.cst_cofins_do_item(cofins_do_item)).to eq('A')
    end
    it "retorna nil caso não haja CST no COFINS" do
      expect(subject).to receive(:cofins_do_item).and_return(cofins_do_item)
      expect(cofins_do_item).to receive(:atributo).with('CST').and_return(nil)
      expect(subject.cst_cofins_do_item(cofins_do_item)).to be_nil
    end
  end

  describe "#situacao_do_icms_cst" do
    it "retorna I para cst igual a 40" do
      expect(subject.situacao_do_icms_cst(40)).to eq('I')
    end
    it "retorna N para cst igual a 41" do
      expect(subject.situacao_do_icms_cst(41)).to eq('N')
    end
    it "retorna S para cst igual a 50" do
      expect(subject.situacao_do_icms_cst(50)).to eq('S')
    end
    it "retorna D para cst igual a 51" do
      expect(subject.situacao_do_icms_cst(51)).to eq('D')
    end
    it "retorna T para qualquer outro cst não mencionado acima." do
      expect(subject.situacao_do_icms_cst(99)).to eq('T')
    end
    it "retorna nil para cst enviado em branco." do
      expect(subject.situacao_do_icms_cst('')).to be_nil
      expect(subject.situacao_do_icms_cst(nil)).to be_nil
    end
  end

  describe "#quantidade_tributaria_do_item" do
    let(:item){Hash.new}
    it "retorna o valor de imposto.COFINSST.qBCProd" do
      expect(item).to receive(:atributo).with('imposto.COFINSST.qBCProd').and_return(1)
      expect(subject.quantidade_tributaria_do_item(item)).to eq(1)
    end
    it "retorna o valor de imposto.COFINS.COFINSOutr.qBCProd caso não exista qBCProd em COFINSST" do
      expect(item).to receive(:atributo).with('imposto.COFINSST.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.COFINS.COFINSOutr.qBCProd').and_return(2)
      expect(subject.quantidade_tributaria_do_item(item)).to eq(2)
    end
    it "retorna o valor de imposto.PISST.qBCProd caso não exista qBCProd em COFINSST e COFINSOutr" do
      expect(item).to receive(:atributo).with('imposto.COFINSST.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.COFINS.COFINSOutr.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.PISST.qBCProd').and_return(3)
      expect(subject.quantidade_tributaria_do_item(item)).to eq(3)
    end
    it "retorna o valor de imposto.PIS.PISOutr.qBCProd caso não exista qBCProd em COFINSST, COFINSOutr e PISST" do
      expect(item).to receive(:atributo).with('imposto.COFINSST.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.COFINS.COFINSOutr.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.PISST.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.PIS.PISOutr.qBCProd').and_return(4)
      expect(subject.quantidade_tributaria_do_item(item)).to eq(4)
    end
    it "retorna o valor de prod.qTrib caso não exista qBCProd em COFINSST, COFINSOutr, PISST e PIS.PISOutr" do
      expect(item).to receive(:atributo).with('imposto.COFINSST.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.COFINS.COFINSOutr.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.PISST.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('imposto.PIS.PISOutr.qBCProd').and_return(nil)
      expect(item).to receive(:atributo).with('prod.qTrib').and_return(5)
      expect(subject.quantidade_tributaria_do_item(item)).to eq(5)
    end
    it "retorna nil caso não exista qBCProd e qTrib informados" do
      expect(item).to receive(:atributo).exactly(5).and_return(nil)
      expect(subject.quantidade_tributaria_do_item(item)).to be_nil
    end
  end

  describe "#inf_nfe" do
    let(:nfe){Hash.new}
    it "retorna o hash com os dados da nfeProc.NFe.infNFe" do
      expect(subject).to receive(:nfe).exactly(1).and_return(nfe)
      expect(nfe).to receive(:atributo).with('nfeProc.NFe.infNFe').and_return(1)
      expect(subject.send :inf_nfe).to eq(1)
    end
    it "retorna o hash com os dados da NFe.infNFe caso nfeProc.NFe.infNFe não exista" do
      expect(subject).to receive(:nfe).exactly(2).and_return(nfe)
      expect(nfe).to receive(:atributo).with('nfeProc.NFe.infNFe').and_return(nil)
      expect(nfe).to receive(:atributo).with('NFe.infNFe').and_return(2)
      expect(subject.send :inf_nfe).to eq(2)
    end
    it "retorna o hash com os dados de infNFe caso  NFe.infNFe e nfeProc.NFe.infNFe não existam" do
      expect(subject).to receive(:nfe).exactly(3).and_return(nfe)
      expect(nfe).to receive(:atributo).with('nfeProc.NFe.infNFe').and_return(nil)
      expect(nfe).to receive(:atributo).with('NFe.infNFe').and_return(nil)
      expect(nfe).to receive(:atributo).with('infNFe').and_return(3)
      expect(subject.send :inf_nfe).to eq(3)
    end
    it "retorna a instancia do conjunto vazio caso infNFe não exista" do
      expect(subject).to receive(:nfe).exactly(3).and_return(nfe)
      expect(nfe).to receive(:atributo).exactly(3).and_return(nil)
      inf_nfe = subject.send(:inf_nfe)
      expect(inf_nfe).to be_a(DfeTaxweb::Conjunto)
      expect(inf_nfe.to_h).to eq({})
    end
  end

  describe "#dest_contribuinte_icms?" do
    let(:inf_nfe){DfeTaxweb::Conjunto.new({})}
    before(:each){allow(subject).to receive(:inf_nfe).and_return(inf_nfe)}
    context 'é contribuinte' do
      it "caso ide.indIEDest=1" do
        expect(inf_nfe).to receive(:atributo).with('ide.indIEDest').and_return(1)
        expect(subject.dest_contribuinte_icms?).to eq('S')
      end
      it "caso ide.indIEDest não seja 1, 2 ou 9 mas tenha IE" do
        expect(inf_nfe).to receive(:atributo).with('ide.indIEDest').and_return(3)
        expect(inf_nfe).to receive(:atributo).with('dest.IE').and_return('123')
        expect(subject.dest_contribuinte_icms?).to eq('S')
      end
    end
    context 'não é contribuinte' do
      it "caso ide.indIEDest=2 ou 9" do
        expect(inf_nfe).to receive(:atributo).with('ide.indIEDest').and_return(2)
        expect(subject.dest_contribuinte_icms?).to eq('N')
        expect(inf_nfe).to receive(:atributo).with('ide.indIEDest').and_return(9)
        expect(subject.dest_contribuinte_icms?).to eq('N')
      end
      it "caso ide.indIEDest não seja 1, 2 ou 9 e não tenha IE" do
        expect(inf_nfe).to receive(:atributo).with('ide.indIEDest').and_return(3)
        expect(inf_nfe).to receive(:atributo).with('dest.IE').and_return(nil)
        expect(subject.dest_contribuinte_icms?).to eq('N')
      end
    end
  end

  describe "#contribuinte_ipi?" do
    it "é contribuinte caso cnae comece com 1, 2 ou 3" do
      expect(subject.contribuinte_ipi?('1099-6/03')).to eq('S')
      expect(subject.contribuinte_ipi?('2710-4/02')).to eq('S')
      expect(subject.contribuinte_ipi?('3102-1/00')).to eq('S')
    end
    it "não contribuinte caso cnae não comece com 1, 2 ou 3" do
      expect(subject.contribuinte_ipi?('5111-1/00')).to eq('N')
      expect(subject.contribuinte_ipi?('0729-4/05')).to eq('N')
    end
    it "retorna nil caso não seja informado um cnae" do
      expect(subject.contribuinte_ipi?(nil)).to be_nil
      expect(subject.contribuinte_ipi?('')).to be_nil
      expect(subject.contribuinte_ipi?('ABC')).to be_nil
    end
  end

end