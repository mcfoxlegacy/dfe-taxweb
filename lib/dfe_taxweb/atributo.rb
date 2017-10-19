module DfeTaxweb
  class Atributo
    attr_accessor :titulo, :descricao, :tamanho

    def initialize(atributos)
      atributos.each do |k, v|
        begin
          self.send(:"#{k}=", v)
        rescue NoMethodError => e
          self.class.send(:attr_accessor, k)
          retry
        end
      end
    end
  end
end