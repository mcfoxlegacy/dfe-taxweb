module DocumentoFiscalLib
  class Nfe
    using HashFinders

    attr_reader :nfe, :documento

    def initialize(nfe)
      @documento = {}
      @nfe = if nfe.is_a?(Hash)
               nfe
             else
               Hash.from_xml(nfe)
             end
    end

    def to_docfiscal
      mapear
      ajustar
      documento
    end

    def mapear
      {
          'idDocFiscal' => 'ide.cNF',
          'natOp' => 'ide.natOp',
          'tipoPagto' => 'ide.indPag',
          'modelo' => 'ide.mod',
          'serie' => 'ide.serie',
          'numero' => 'ide.nNF',
          'dtEmissao' => 'ide.dEmi || ide.dhEmi',
          'dtES' => 'ide.dSaiEnt',
          'dtPagto' => 'ide.dSaiEnt',
          'cMunFG' => 'ide.cMunFg',
          'refNFP' => 'ide.refNFP',
          'refCTE' => 'ide.refCTE',
          'refECF' => 'ide.refECF',
          'tpImp' => 'ide.tpImp',
          'tpEmis' => 'ide.tpEmis',
          'cDV' => 'ide.cDV',
          'tpAmb' => 'ide.tpAmb',
          'finNFe' => 'ide.finNFe',
          'procEmi' => 'ide.procEmi',
          'verProc' => 'ide.verProc',
          'dhCont' => 'ide.dhCont',
          'xJust' => 'ide.xJust',
          'emitente.cnpj' => 'emit.CNPJ',
          'emitente.cpf' => 'emit.CPF',
          'emitente.nome' => 'emit.xNome',
          'emitente.xFant' => 'emit.xFant',
          'emitente.xLgr' => 'emit.enderEmit.xLgr',
          'emitente.Nro' => 'emit.enderEmit.Nro',
          'emitente.xCpl' => 'emit.enderEmit.xCpl',
          'emitente.xBairro' => 'emit.enderEmit.xBairro',
          'emitente.cdMunicipio' => 'emit.enderEmit.cMun',
          'emitente.xMun' => 'emit.enderEmit.xMun',
          'emitente.uf' => 'emit.enderEmit.UF',
          'emitente.cep' => 'emit.enderEmit.CEP',
          'emitente.cdPais' => 'emit.enderEmit.cPais',
          'emitente.xPais' => 'emit.enderEmit.xPais',
          'emitente.fone' => 'emit.enderEmit.fone',
          'emitente.inscricaoEstadual' => 'emit.IE',
          'emitente.IEST' => 'emit.IEST',
          'emitente.inscricaoMunicipal' => 'emit.IM',
          'emitente.cdAtividadeEconomica' => 'emit.CNAE'
      }.each do |doc, nfe|
        valor = resolver_expressoes(nfe)
        documento.atualizar(doc, valor)
      end
    end

    def ajustar
      documento.atualizar 'cdTipo',
                          (inf_nfe.atributo('ide.tpNF') == 0 ? 'E' : 'S')

      documento.atualizar 'emitente.simplesNac',
                          (['1', '2'].include?(inf_nfe.atributo('emit.CRT')) ? 'S' : 'N')

      # AJUSTA O CODIGO DO PAIS SE FOR BRASIL
      if documento[:emitente][:cdPais].nil? || documento[:emitente][:cdPais] == '1058'
        documento.atualizar 'emitente.cdPais', '105'
      end

      # É CONTRIBUINTE?
      documento.atualizar 'emitente.contribuinteICMS',
                          (inf_nfe.atributo('emit.IE') ? 'S' : 'N')
      documento.atualizar 'emitente.contribuinteST',
                          (inf_nfe.atributo('emit.IEST') ? 'S' : 'N')
      documento.atualizar 'emitente.contribuinteISS',
                          (inf_nfe.atributo('emit.IM') ? 'S' : 'N')
      documento.atualizar 'emitente.contribuintePIS',
                          (inf_nfe.atributo('emit.CNPJ') ? 'S' : 'N')
      documento.atualizar 'emitente.contribuinteCOFINS',
                          (inf_nfe.atributo('emit.CNPJ') ? 'S' : 'N')
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
          {}
    end

  end
end