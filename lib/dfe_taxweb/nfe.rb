module DfeTaxweb
  class Nfe

    attr_reader :nfe, :documento

    def initialize(nfe)
      @documento = {}
      hash = nfe.is_a?(Hash) ? nfe : Hash.from_xml(nfe)
      if hash.blank?
        raise TypeError, 'Invalid NFe type, need Hash ou XML(string)'
      end
      @nfe = Conjunto.new(hash)
    end

    def to_dfe
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
          vNF: inf_nfe.atributo('total.ICMSTot.vNF'),
          emitente: emitente,
          destinatario: destinatario,
          retirada: retirada,
          entrega: entrega,
          itensDocFiscal: itens,
          tipoOperacao: tipo_de_operacao,
          tpDocFiscal: 'FT',
          naturezaOperacao: '002'
      }.compact
    end

    def emitente
      emit = inf_nfe.atributo('emit')
      endereco = endereco(emit.atributo('enderEmit'))
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
      }.merge(endereco).compact
    end

    def destinatario
      dest = inf_nfe.atributo('dest')
      endereco = endereco(dest.atributo('enderDest'))
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
      }.merge(endereco).compact
    end

    def endereco(ender)
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
      }.compact
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
        next unless produto.present?
        {
            cdCSTICMS: cst_icms_do_item(item),
            cdCSTIPI: cst_ipi_do_item(item),
            cdCSTPIS: cst_pis_do_item(item),
            cdCSTCOFINS: cst_cofins_do_item(item),
            cdItemDocFiscal: item.atributo('nItem'),
            cdCfop: produto.atributo('CFOP'),
            unidade: produto.atributo('uCom'),
            qtItemDocFiscal: produto.atributo('qCom'),
            vlUnitario: produto.atributo('vUnCom'),
            vlTotalCI: produto.atributo('vProd'),
            vlTotal: produto.atributo('vProd'),
            qtTributariaUnidade: produto.atributo('uTrib'),
            qtTributaria: quantidade_tributaria_do_item(item),
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
            enquadramentos: enquadramentos_do_item(item)
        }.compact
      end.compact
    end

    def produto_do_item(item)
      produto = item.atributo('prod')
      return {} unless produto.present?
      {
          indTot: produto.atributo('indTot'),
          cEANTrib: produto.atributo('cEANTrib'),
          codigo: produto.atributo('cProd'),
          EAN: produto.atributo('cEAN'),
          descricao: produto.atributo('xProd'),
          NCM: produto.atributo('NCM'),
          CEST: produto.atributo('CEST'),
          exTIPI: produto.atributo('EXTIPI'),
          cdOrigem: origem_do_produto(item),
          aplicacao: 'C'
      }.compact
    end

    def icms_do_item(item)
      unless item.dados(:icms).present?
        imposto = item.atributo('imposto.ICMS')
        ['ICMS00', 'ICMS10', 'ICMS20', 'ICMS30', 'ICMS40', 'ICMS51', 'ICMS60', 'ICMS70', 'ICMS90'].each do |tipo_icms|
          item.dados(:icms, imposto.atributo(tipo_icms))
          if item.dados(:icms).present?
            item.dados(:icms).atualizar(tipo: tipo_icms)
            break
          end
        end
      end
      item.dados(:icms)
    end

    def ipi_do_item(item)
      unless item.dados(:ipi).present?
        item.dados(:ipi, item.atributo('imposto.IPI'))
        ['IPINT', 'IPITrib'].each do |tipo|
          imposto = item.dados(:ipi).atributo(tipo)
          if imposto.present?
            item.dados(:ipi).atualizar(imposto.to_h)
            item.dados(:ipi).atualizar(tipo: tipo)
            break
          end
        end
      end
      item.dados(:ipi)
    end

    def pis_do_item(item)
      unless item.dados(:pis).present?
        imposto = item.atributo('imposto.PIS')
        ['PISNT', 'PISAliq', 'PISQtde', 'PISOutr'].each do |tipo|
          item.dados(:pis, imposto.atributo(tipo))
          if item.dados(:pis).present?
            item.dados(:pis).atualizar(tipo: tipo)
            break
          end
        end
      end
      item.dados(:pis)
    end

    def cofins_do_item(item)
      unless item.dados(:cofins).present?
        imposto = item.atributo('imposto.COFINS')
        ['COFINSAliq', 'COFINSQtde', 'COFINSNT', 'COFINSOutr'].each do |tipo|
          item.dados(:cofins, imposto.atributo(tipo))
          if item.dados(:cofins).present?
            item.dados(:cofins).atualizar(tipo: tipo)
            break
          end
        end
      end
      item.dados(:cofins)
    end

    def enquadramentos_do_item(item)
      imposto = item.atributo('imposto')
      icms = icms_do_item(item)
      [
          enquadramento_icms(icms), # 0 ICMS
          enquadramento_icmsst(icms), # 1 ST
          nil, # 2 ???
          enquadramento_icmsste(icms), # 3 STE
          enquadramento_ipi(ipi_do_item(item)), # 4 IPI
          enquadramento_ii(imposto.atributo('II')), # 5 II
          enquadramento_pis(pis_do_item(item)), # 6 PIS
          enquadramento_pisst(imposto.atributo('PISST')), # 7 PISST
          enquadramento_cofins(cofins_do_item(item)), # 8 COFINS
          enquadramento_cofinsst(imposto.atributo('COFINSST')), # 9 COFINSST
      ]
    end

    def enquadramento_icms(icms)
      return if icms.blank? ||
          ['ICMS00', 'ICMS10', 'ICMS20', 'ICMS40', 'ICMS51', 'ICMS70', 'ICMS90'].exclude?(icms.atributo('tipo'))
      {
          dsSigla: 'ICMS',
          situacao: situacao_do_icms_cst(icms.atributo('CST')),
          tpEnquadramento: 'IM',
          vlTributavel: icms.atributo('vBC'),
          vlAliquota: icms.atributo('pICMS'),
          vlImposto: icms.atributo('vICMS'),
          percReducaoBase: icms.atributo('pRedBC'),
          modbc: icms.atributo('modbc')
      }.compact
    end

    def enquadramento_icmsst(icms)
      return if icms.blank? ||
          ['ICMS10', 'ICMS30', 'ICMS70', 'ICMS90'].exclude?(icms.atributo('tipo'))
      {
          dsSigla: 'ST',
          situacao: situacao_do_icms_cst(icms.atributo('CST')),
          tpEnquadramento: 'IM',
          vlBase: icms.atributo('vBCST'),
          vlTributavel: icms.atributo('vBCST'),
          vlAliquota: icms.atributo('pICMSST'),
          vlImposto: icms.atributo('vICMSST'),
          vlPercentualMVA: icms.atributo('pMVAST'),
          percReducaoBase: icms.atributo('pRedBCST'),
          modBCST: icms.atributo('modBCST')
      }.compact
    end

    def enquadramento_icmsste(icms)
      return if icms.blank? ||
          ['ICMS60'].exclude?(icms.atributo('tipo'))
      {
          dsSigla: 'STE',
          situacao: situacao_do_icms_cst(icms.atributo('CST')),
          tpEnquadramento: 'IM',
          vlBase: icms.atributo('vBCST'),
          vlTributavel: icms.atributo('vBCSTRet'),
          vlImposto: icms.atributo('vICMSSTRet'),
          vlPercentualMVA: icms.atributo('pMVAST')
      }.compact
    end

    def enquadramento_ipi(ipi)
      return if ipi.blank?
      vlr_unid = ipi.atributo('vUnid')
      {
          dsSigla: 'IPI',
          situacao: 'T',
          tpEnquadramento: 'IM',
          clEnq: ipi.atributo('clEnq'),
          CNPJProd: ipi.atributo('CNPJProd'),
          cSelo: ipi.atributo('cSelo'),
          qSelo: ipi.atributo('qSelo'),
          cEnq: ipi.atributo('cEnq'),
          vlImposto: ipi.atributo('vIPI'),
          vlTributavel: (vlr_unid.present? && vlr_unid.to_f > 0 ? 0 : ipi.atributo('vBC')),
          vlAliquota: ipi.atributo('pIPI'),
          vUnid: vlr_unid,
          qUnid: ipi.atributo('qUnid')
      }.compact
    end

    def enquadramento_ii(ii)
      return if ii.blank? || ii.atributo('vII').to_f <= 0.0
      {
          dsSigla: 'II',
          situacao: 'T',
          vlTributavel: ii.atributo('vBC'),
          vlImposto: ii.atributo('vII'),
          vlIOF: ii.atributo('vlIOF'),
          vDespAdu: ii.atributo('vDespAdu'),
          tpEnquadramento: 'IM'
      }.compact
    end

    def enquadramento_pis(pis)
      return unless pis.present?
      {
          dsSigla: 'PIS',
          tpEnquadramento: 'IM',
          situacao: 'T',
          vlTributavel: pis.atributo('vBC'),
          vlAliquota: pis.atributo('pPIS'),
          vlImposto: pis.atributo('vPIS'),
          qBCProd: pis.atributo('qBCProd'),
          vlImpostoUnitario: pis.atributo('vAliqProd')
      }.compact
    end

    def enquadramento_pisst(pisst)
      return unless pisst.present?
      {
          dsSigla: 'PISST',
          tpEnquadramento: 'IM',
          situacao: 'T',
          vlTributavel: pisst.atributo('vBC'),
          vlAliquota: pisst.atributo('pPIS'),
          vlImposto: pisst.atributo('vPIS'),
          vlImpostoUnitario: pisst.atributo('vAliqProd')
      }.compact
    end

    def enquadramento_cofins(cofins)
      return unless cofins.present?
      {
          dsSigla: 'COFINS',
          tpEnquadramento: 'IM',
          situacao: cofins.atributo('tipo') == 'COFINSNT' ? 'N' : 'T',
          vlTributavel: cofins.atributo('vBC'),
          vlAliquota: cofins.atributo('pCOFINS'),
          vlImposto: cofins.atributo('vCOFINS'),
          qBCProd: cofins.atributo('qBCProd'),
          vlImpostoUnitario: cofins.atributo('vAliqProd')
      }.compact
    end

    def enquadramento_cofinsst(cofinsst)
      return unless cofinsst.present?
      {
          dsSigla: 'COFINSST',
          tpEnquadramento: 'IM',
          situacao: 'T',
          vlTributavel: cofinsst.atributo('vBC'),
          vlAliquota: cofinsst.atributo('pCOFINS'),
          vlImposto: cofinsst.atributo('vCOFINS'),
          vlImpostoUnitario: cofinsst.atributo('vAliqProd')
      }.compact
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

    # cod_pais = NFe cPais
    def codigo_pais(cod_pais)
      if cod_pais.nil? || cod_pais == '1058'
        '105'
      else
        cod_pais
      end
    end

    def origem_do_produto(item)
      ipi_do_item(item).atributo('orig') || icms_do_item(item).atributo('orig')
    end

    def cst_icms_do_item(item)
      icms = icms_do_item(item)
      cst_icms = "#{icms.atributo('orig')}#{icms.atributo('CST')}"
      cst_icms.present? ? cst_icms : nil
    end

    def cst_ipi_do_item(item)
      ipi_do_item(item).atributo('CST')
    end

    def cst_pis_do_item(item)
      pis_do_item(item).atributo('CST')
    end

    def cst_cofins_do_item(item)
      cofins_do_item(item).atributo('CST')
    end

    def situacao_do_icms_cst(cst)
      return if cst.blank?
      case cst.to_s
        when '40' # Isenta
          'I'
        when '41' # Não tributada
          'N'
        when '50' # Suspensão
          'S'
        when '51' # Diferimento
          'D'
        else # Tributada
          'T'
      end
    end

    def quantidade_tributaria_do_item(item)
      item.atributo('imposto.COFINSST.qBCProd') ||
          item.atributo('imposto.COFINS.COFINSOutr.qBCProd') ||
          item.atributo('imposto.PISST.qBCProd') ||
          item.atributo('imposto.PIS.PISOutr.qBCProd') ||
          item.atributo('prod.qTrib')
    end

    private
    def inf_nfe
      @inf_nfe ||= nfe.atributo('nfeProc.NFe.infNFe') ||
          nfe.atributo('NFe.infNFe') ||
          nfe.atributo('infNFe') ||
          Conjunto.new({})
    end

  end
end