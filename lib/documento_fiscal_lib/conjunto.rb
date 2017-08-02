module DocumentoFiscalLib
  class Conjunto

    attr_reader :conjunto

    def initialize(hash)
      @conjunto = hash
    end

    def to_h
      conjunto
    end

    def [](key)
      conjunto[key]
    end

    def atributo(path)
      valor = path.split(".").inject(conjunto.deep_symbolize_keys) do |item, key|
        if key =~ /\[\d+\]/
          indice = key[/\[(\d+)\]/, 1]
          key_name = key.sub(/\[\d+\]/, '')
          item[key_name.to_sym][indice.to_i]
        else
          item[key.to_sym]
        end
      end
      if valor.is_a?(Array)
        valor.map { |v| normaliza_valores(v) }.compact
      else
        normaliza_valores(valor)
      end
    end

    def atualizar(atributos, valor)
      hash = atributos.split(".").push(valor).reverse.inject do |hash, key|
        if key =~ '/\[\d+\]/'
          {key => h}
        else
          {key => h}
        end
      end
      conjunto.deep_merge!(hash.deep_symbolize_keys)
    end

    private
    def normaliza_valores(valor)
      valor.is_a?(Hash) ? Conjunto.new(valor) : valor
    end

  end
end