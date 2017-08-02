module DocumentoFiscalLib
  class Nfe

    attr_reader :nfe, :documento

    def initialize(nfe)
      @documento = {}
      hash = nfe.is_a?(Hash) ? nfe : Hash.from_xml(nfe)
      @nfe = Conjunto.new hash
    end

    def para_documento_fiscal
      @documento = mapear_documento
    end

    def mapear_documento
      {
          idDocFiscal: inf_nfe.atributo('ide.cNF'),
          natOp: inf_nfe.atributo('ide.natOp'),
          tipoPagto: inf_nfe.atributo('ide.indPag'),
          modelo: inf_nfe.atributo('ide.mod'),
          serie: inf_nfe.atributo('ide.serie'),
          numero: inf_nfe.atributo('ide.nNF'),
          dtEmissao: data_de_emissao,
          dtES: inf_nfe.atributo('ide.dSaiEnt'),
          dtPagto: inf_nfe.atributo('ide.dSaiEnt'),
          cMunFG: inf_nfe.atributo('ide.cMunFg'),
          refNFP: inf_nfe.atributo('ide.refNFP'),
          refCTE: inf_nfe.atributo('ide.refCTE'),
          refECF: inf_nfe.atributo('ide.refECF'),
          tpImp: inf_nfe.atributo('ide.tpImp'),
          tpEmis: inf_nfe.atributo('ide.tpEmis'),
          cDV: inf_nfe.atributo('ide.cDV'),
          tpAmb: inf_nfe.atributo('ide.tpAmb'),
          finNFe: inf_nfe.atributo('ide.finNFe'),
          procEmi: inf_nfe.atributo('ide.procEmi'),
          verProc: inf_nfe.atributo('ide.verProc'),
          dhCont: inf_nfe.atributo('ide.dhCont'),
          xJust: inf_nfe.atributo('ide.xJust'),
          emitente: emitente,
          destinatario: destinatario,
          retirada: retirada,
          entrega: entrega,
          itensDocFiscal: itens,
          tipoOperacao: tipo_de_operacao,
          tpDocFiscal: 'FT',
          naturezaOperacao: '002'
      }
    end

    def emitente
      emit = inf_nfe.atributo('emit')
      {
          cnpj: emit.atributo('CNPJ'),
          cpf: emit.atributo('CPF'),
          nome: emit.atributo('xNome'),
          xFant: emit.atributo('xFant'),
          inscricaoEstadual: emit.atributo('IE'),
          IEST: emit.atributo('IEST'),
          inscricaoMunicipal: emit.atributo('IM'),
          cdAtividadeEconomica: emit.atributo('CNAE'),
          contribuinteICMS: emit.atributo('IE') ? 'S' : 'N',
          # contribuinteIPI: emit.atributo('IE') ? 'S' : 'N',
          contribuinteST: emit.atributo('IEST') ? 'S' : 'N',
          contribuinteISS: emit.atributo('IM') ? 'S' : 'N',
          contribuintePIS: emit.atributo('CNPJ') ? 'S' : 'N',
          contribuinteCOFINS: emit.atributo('CNPJ') ? 'S' : 'N',
          contribuinteII: 'S',
          simplesNac: [1, 2].include?(emit.atributo('CRT')) ? 'S' : 'N'
      }.merge(endereco(emit.atributo('enderEmit')))
    end

    def destinatario
      dest = inf_nfe.atributo('dest')
      {
          cnpj: dest.atributo('CNPJ'),
          cpf: dest.atributo('CPF'),
          nome: dest.atributo('xNome'),
          inscricaoEstadual: dest.atributo('IE'),
          contribuinteICMS: dest.atributo('IE') ? 'S' : 'N',
          # contribuinteIPI: dest.atributo('IE') ? 'S' : 'N',
          contribuintePIS: dest.atributo('CNPJ') ? 'S' : 'N',
          contribuinteCOFINS: dest.atributo('CNPJ') ? 'S' : 'N',
          contribuinteII: 'S',
          ISUF: dest.atributo('ISUF'),
          email: dest.atributo('email')
      }.merge(endereco(dest.atributo('enderDest')))
    end

    def endereco(ender=nil)
      return {} unless ender.present?
      {
          xLgr: ender.atributo('xLgr'),
          Nro: ender.atributo('Nro'),
          xCpl: ender.atributo('xCpl'),
          xBairro: ender.atributo('xBairro'),
          cdMunicipio: ender.atributo('cMun'),
          xMun: ender.atributo('xMun'),
          uf: ender.atributo('UF'),
          cep: ender.atributo('CEP'),
          cdPais: codigo_pais(ender.atributo('cPais')),
          xPais: ender.atributo('xPais'),
          fone: ender.atributo('fone')
      }
    end

    def retirada
      inf_nfe.atributo('retirada')
    end

    def entrega
      inf_nfe.atributo('entrega')
    end

    def itens
      itens = inf_nfe.atributo('det')
      itens = [itens] unless itens.is_a?(Array)
      itens.map do |item|
        produto = item.atributo('prod')
        df_item = {
            cdItemDocFiscal: item.atributo('nItem'),
            cdCfop: produto.atributo('CFOP'),
            unidade: produto.atributo('uCom'),
            qtItemDocFiscal: produto.atributo('qCom'),
            vlUnitario: produto.atributo('vUnCom'),
            vlTotalCI: produto.atributo('vproduto'),
            vlTotal: produto.atributo('vproduto'),
            qtTributariaUnidade: produto.atributo('uTrib'),
            qtTributaria: produto.atributo('qTrib'),
            vUnTrib: produto.atributo('vUnTrib'),
            vlFrete: produto.atributo('vFrete'),
            vlSeguro: produto.atributo('vSeg'),
            vlDesconto: produto.atributo('vDesc'),
            vlOda: produto.atributo('vOutro'),
            DI: produto.atributo('DI'),
            xPed: produto.atributo('xPed'),
            nItemPed: produto.atributo('nItemPed'),
            cdClassificacao: 'M',
            deduzCFOP: 'S',
            deduzCSTICMS: 'S',
            deduzCSTPIS: 'S',
            deduzCSTCOFINS: 'S',
            deduzCSTIPI: 'S',
            prodItem: produto_do_item(item),
            enquadramentos: []
        }
        impostos_do_item(item, df_item)
      end.compact
    end

    def produto_do_item(item)
      produto = item.atributo('prod')
      {
          indTot: produto.atributo('indTot'),
          cEANTrib: produto.atributo('cEANTrib'),
          codigo: produto.atributo('cProd'),
          EAN: produto.atributo('cEAN'),
          descricao: produto.atributo('xProd'),
          NCM: produto.atributo('NCM'),
          CEST: produto.atributo('CEST'),
          exTIPI: produto.atributo('EXTIPI'),
          aplicacao: 'C'
      }
    end

    def impostos_do_item(nf_item, df_item)
      imposto = nf_item.atributo('imposto')
      icms_do_item(imposto.atributo('ICMS'), df_item)
      ipi_do_item(imposto.atributo('IPI'), df_item)
      ii_do_item(imposto.atributo('II'), df_item)
      pis_do_item(imposto.atributo('PIS'), df_item)
      pisst_do_item(imposto.atributo('PISST'), df_item)
      cofins_do_item(imposto.atributo('COFINS'), df_item)
      cofinsst_do_item(imposto.atributo('COFINSST'), df_item)
    end

    def icms_do_item(icms, df_item)
      icms00_do_item(icms.atributo('ICMS00'), df_item)
      icms10_do_item(icms.atributo('ICMS10'), df_item)
      icms20_do_item(icms.atributo('ICMS20'), df_item)
      icms30_do_item(icms.atributo('ICMS30'), df_item)
      icms40_do_item(icms.atributo('ICMS40'), df_item)
      icms51_do_item(icms.atributo('ICMS51'), df_item)
      icms60_do_item(icms.atributo('ICMS60'), df_item)
      icms70_do_item(icms.atributo('ICMS70'), df_item)
      icms90_do_item(icms.atributo('ICMS90'), df_item)
    end

    # Tributação pelo ICMS
    # 00 - Tributada integralmente
    def icms00_do_item(icms00, df_item)
      return unless icms00.present?
      df_item[:enquadramentos][0] = {
          dsSigla: 'ICMS',
          situacao: 'T',
          tpEnquadramento: 'IM',
          vlTributavel: 'vBC',
          vlAliquota: 'pICMS',
          vlImposto: 'vICMS',
          modbc: 'modbc'
      }
      orig = icms00.atributo('orig')
      df_item.atualizar('prodItem.cdOrigem', orig)
      df_item.atualizar('cdCSTICMS', "#{orig}#{icms00.atributo('CST')}")
    end

    # Tributação pelo ICMS
    # 10 - Tributada e com cobrança do ICMS por substituição tributária
    def parse_icms10(icms10, item)
      return unless icms10

      item[:enquadramentos][0] = {}
      icms = item[:enquadramentos][0]
      icms[:dsSigla] = 'ICMS'
      icms[:situacao] = 'T'
      icms[:tpEnquadramento] = 'IM'
      icms[:vlTributavel] = icms10['vBC']
      icms[:vlAliquota] = icms10['pICMS']
      icms[:vlImposto] = icms10['vICMS']
      icms[:modbc] = icms10['modBC']

      item[:enquadramentos][1] = {}
      st = item[:enquadramentos][1]
      st[:dsSigla] = 'ST'
      st[:situacao] = 'T'
      st[:tpEnquadramento] = 'IM'
      st[:vlTributavel] = icms10['vBCST']
      st[:vlAliquota] = icms10['pICMSST']
      st[:vlImposto] = icms10['vICMSST']
      st[:modBCST] = icms10['modBCST']
      st[:vlPercentualMVA] = icms10['pMVAST']

      item[:prodItem][:cdOrigem] = icms10['orig']
      item[:cdCSTICMS] = "#{icms10['orig']}#{icms10['CST']}"


    end


    # Tributção pelo ICMS
    # 20 - Com redução de base de cálculo
    def parse_icms20(icms20, item)
      return unless icms20

      item[:enquadramentos][0] = {}
      icms = item[:enquadramentos][0]
      icms[:dsSigla] = 'ICMS'
      icms[:situacao] = 'T'
      icms[:tpEnquadramento] = 'IM'
      icms[:vlTributavel] = icms20['vBC']
      icms[:percReducaoBase] = icms20['pRedBC']
      icms[:vlAliquota] = icms20['pICMS']
      icms[:vlImposto] = icms20['vICMS']
      icms[:modbc] = icms20['modBC']


      item[:prodItem][:cdOrigem] = icms20['orig']
      item[:cdCSTICMS] = "#{icms20['orig']}#{icms20['CST']}"


    end


    # Tributação pelo ICMS
    # 30 - Isenta ou não tributada e com cobrança do ICMS por substituição tributária
    def parse_icms30(icms30, item)
      return unless icms30

      item[:enquadramentos][1] = {}
      st = item[:enquadramentos][1]
      st[:dsSigla] = 'ST'
      st[:situacao] = 'T'
      st[:tpEnquadramento] = 'IM'
      st[:modBCST] = icms30['modBCST']
      st[:vlPercentualMVA] = icms30['pMVAST']
      st[:percReducaoBase] = icms30['pRedBCST']
      st[:vlBase] = icms30['vBCST']
      st[:vlTributavel] = icms30['vBCST']
      st[:vlAliquota] = icms30['pICMSST']
      st[:vlImposto] = icms30['vICMSST']

      item[:prodItem][:cdOrigem] = icms30['orig']
      item[:cdCSTICMS] = "#{icms30['orig']}#{icms30['CST']}"


    end

    # Tributação pelo ICMS
    # 40 - Isenta
    # 41 - Não tributada
    # 50 - Suspensão
    def parse_icms40(icms40, item)
      return unless icms40

      item[:enquadramentos][0] = {}
      icms = item[:enquadramentos][0]
      icms[:dsSigla] = 'ICMS'

      case icms40['CST'].to_s
        #40 - Isenta
        when '40' then
          icms[:situacao] = 'I'
        #41 - Não tributada
        when '41' then
          icms[:situacao] = 'N'
        #50 - Suspensão
        when '50' then
          icms[:situacao] = 'S'
      end

      icms[:tpEnquadramento] = 'IM'

      item[:prodItem][:cdOrigem] = icms40['orig']
      item[:cdCSTICMS] = "#{icms40['orig']}#{icms40['CST']}"


    end

    # Tributção pelo ICMS
    # 51 - Diferimento
    # A exigência do preenchimento das informações do ICMS diferido fica à critério de cada UF.
    def parse_icms51(icms51, item)
      return unless icms51

      item[:enquadramentos][0] = {}
      icms = item[:enquadramentos][0]
      icms[:dsSigla] = 'ICMS'
      icms[:situacao] = 'D'
      icms[:tpEnquadramento] = 'IM'

      icms[:vlTributavel] = icms51['vBC']
      icms[:percReducaoBase] = icms51['pRedBC']
      icms[:vlAliquota] = icms51['pICMS']
      icms[:vlImposto] = icms51['vICMS']
      icms[:modbc] = icms51['modBC']


      item[:prodItem][:cdOrigem] = icms51['orig']
      item[:cdCSTICMS] = "#{icms51['orig']}#{icms51['CST']}"


    end


    # Tributação pelo ICMS
    # 60 - ICMS cobrado anteriormente por substituição tributária
    def parse_icms60(icms60, item)
      return unless icms60

      item[:enquadramentos][3] = {}
      ste = item[:enquadramentos][3]
      ste[:dsSigla] = 'STE'
      ste[:situacao] = 'T'
      ste[:tpEnquadramento] = 'IM'
      ste[:vlTributavel] = icms60['vBCSTRet']
      ste[:vlImposto] = icms60['vICMSSTRet']
      ste[:vlPercentualMVA] = icms60['pMVAST']


      item[:prodItem][:cdOrigem] = icms60['orig']
      item[:cdCSTICMS] = "#{icms60['orig']}#{icms60['CST']}"

    end

    # Tributação pelo ICMS
    # 70 - Com redução de base de cálculo e cobrança do ICMS por substituição tributária
    def parse_icms70(icms70, item)
      return unless icms70

      item[:enquadramentos][0] = {}
      icms = item[:enquadramentos][0]
      icms[:dsSigla] = 'ICMS'
      icms[:situacao] = 'T'
      icms[:tpEnquadramento] = 'IM'
      icms[:percReducaoBase] = icms70['pRedBC']
      icms[:vlTributavel] = icms70['vBC']
      icms[:vlAliquota] = icms70['pICMS']
      icms[:vlImposto] = icms70['vICMS']
      icms[:modbc] = icms70['modBC']

      item[:enquadramentos][1] = {}
      st = item[:enquadramentos][1]
      st[:dsSigla] = 'ST'
      st[:situacao] = 'T'
      st[:tpEnquadramento] = 'IM'
      st[:modBCST] = icms70['modBCST']
      st[:vlPercentualMVA] = icms70['pMVAST']
      st[:percReducaoBase] = icms70['pRedBCST']
      st[:vlTributavel] = icms70['vBCST']
      st[:vlAliquota] = icms70['pICMSST']
      st[:vlImposto] = icms70['vICMSST']

      item[:prodItem][:cdOrigem] = icms70['orig']
      item[:cdCSTICMS] = "#{icms70['orig']}#{icms70['CST']}"

    end

    # Tributação pelo ICMS
    # 90 - Outras
    def parse_icms90(icms90, item)
      return unless icms90

      item[:prodItem][:cdOrigem] = icms90['orig']
      item[:cdCSTICMS] = "#{icms90['orig']}#{icms90['CST']}"


      item[:enquadramentos][0] = {}
      icms = item[:enquadramentos][0]
      icms[:dsSigla] = 'ICMS'
      icms[:situacao] = 'T'
      icms[:tpEnquadramento] = 'IM'
      icms[:percReducaoBase] = icms90['pRedBC']
      icms[:vlTributavel] = icms90['vBC']
      icms[:vlAliquota] = icms90['pICMS']
      icms[:vlImposto] = icms90['vICMS']
      icms[:modbc] = icms90['modBC']

      item[:enquadramentos][1] = {}
      st = item[:enquadramentos][1]
      st[:dsSigla] = 'ST'
      st[:situacao] = 'T'
      st[:tpEnquadramento] = 'IM'
      st[:modBCST] = icms90['modBCST']
      st[:vlPercentualMVA] = icms90['pMVAST']
      st[:percReducaoBase] = icms90['pRedBCST']
      st[:vlTributavel] = icms90['vBCST']
      st[:vlAliquota] = icms90['pICMSST']
      st[:vlImposto] = icms90['vICMSST']


    end

    def data_de_emissao
      inf_nfe.atributo('ide.dEmi') || inf_nfe.atributo('ide.dhEmi')
    end

    def tipo_de_operacao
      emit_uf = inf_nfe.atributo('emit.UF')
      dest_uf = inf_nfe.atributo('dest.UF')
      if emit_uf && dest_uf
        emit_uf == dest_uf ? 'E' : 'I'
      end
    end

    def codigo_pais(cPais)
      if cPais.nil? || cPais == '1058'
        '105'
      else
        cPais
      end
    end

    private
    def resolver_expressoes(nfe)
      atributo = nfe.gsub(/\s+/, "")
      if nfe =~ /\|\|/
        atributo.split('||').map {|a| inf_nfe.atributo(a)}.compact.first
      else
        inf_nfe.atributo(atributo)
      end
    end

    def inf_nfe
      @inf_nfe ||= nfe.atributo('nfeProc.NFe.infNFe') ||
          nfe.atributo('NFe.infNFe') ||
          nfe.atributo('infNFe') ||
          Conjunto.new({})
    end

  end
end