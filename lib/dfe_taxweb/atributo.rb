module DfeTaxweb
  class Atributo
    attr_accessor :titulo, :descricao
    attr_reader :caminho

    def initialize(atributos, caminho='')
      @caminho = caminho
      atributos.each do |k, v|
        begin
          self.send(:"#{k}=", v)
        rescue NoMethodError => e
          # self.class.send(:attr_accessor, k)
          # retry
        end
      end
    end
  end
end