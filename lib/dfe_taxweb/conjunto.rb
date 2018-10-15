module DfeTaxweb
  class Conjunto

    attr_reader :conjunto
    attr_accessor :dados
    delegate :present?, :to_s, to: :conjunto

    def initialize(hash)
      @conjunto = hash.deep_symbolize_keys
      @dados = {}
    end

    def to_h
      conjunto
    end

    def [](key)
      conjunto[key]
    end

    def dados(key, valor=nil)
      if valor.present?
        @dados[key.to_sym] = valor
      else
        @dados.try(:[], key.to_sym)
      end
    end

    def atributo(path)
      valor = path.split(".").inject(conjunto) do |item, key|
        next if item.nil?
        if key =~ /\[\d+\]/
          item[key.sub(/\[\d+\]/, '').to_sym][key[/\[(\d+)\]/, 1].to_i]
        else
          item[key.to_sym]
        end
      end

      if valor.is_a?(Array)
        valor.map {|v| normaliza_valores(v)}.compact
      else
        normaliza_valores(valor)
      end
    end

    def atualizar(hash)
      if hash.is_a?(Hash)
        conjunto.deep_merge!(hash.deep_symbolize_keys)
      end
      self
    end

    private
    def normaliza_valores(valor)
      valor.is_a?(Hash) ? Conjunto.new(valor) : valor
    end

  end
end

# FIX nil.atributo() nil.dados()
class NilClass
  def atributo(*_)
    nil
  end
  def dados(*_)
    nil
  end
end