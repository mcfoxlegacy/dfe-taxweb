module DocumentoFiscalLib
  class Conjunto

    attr_reader :conjunto
    attr_accessor :atributos
    delegate :present?, :to_s, to: :conjunto

    def initialize(hash)
      @conjunto = hash.deep_symbolize_keys
      @atributos = {}
    end

    def to_h
      conjunto
    end

    def [](key)
      conjunto[key]
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

    def atualizar(path, valor=nil)
      if path.is_a?(Hash)
        conjunto.deep_merge!(path.deep_symbolize_keys)
      else
        valor = path.split(".").inject(conjunto) do |item, key|
          if key =~ /\[\d+\]/
            k = key.sub(/\[\d+\]/, '').to_sym
            item ||= {k: []}
            item[k][key[/\[(\d+)\]/, 1].to_i]
          else
            item ||= {}
            item[key.to_sym]
          end
        end
      end
      #
      # atributo = atributo(path)
      # if atributo.present?
      #   atributo = valor
      # else
      #   if path.is_a?(Hash)
      #     hash = path
      #   else
      #     hash = atributos.split(".").push(valor).reverse.inject do |hash, key|
      #       {key => hash}
      #     end
      #   end
      #   conjunto.deep_merge!(hash.deep_symbolize_keys)
      # end
      self
    end

    private
    def normaliza_valores(valor)
      if valor.is_a?(Hash)
        Conjunto.new(valor)
      else
        valor
      end
    end

  end
end

# FIX nil.atributo(...)
class NilClass
  def atributo(path=nil)
    nil
  end
end