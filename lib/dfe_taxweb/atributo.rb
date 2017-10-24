module DfeTaxweb
  class Atributo
    attr_accessor :titulo, :descricao
    attr_reader :caminho

    def initialize(atributos, caminho='')
      @caminho = caminho
      pai_titulo = caminho =~ /\./ ? DfeTaxweb.atributo(caminho[0, caminho.rindex('.')]).titulo : ''
      atributos.each do |k, v|
        begin
          if k.to_s=='titulo'
            self.titulo = "#{pai_titulo} #{v}"
          else
            self.send(:"#{k}=", v)
          end
        rescue NoMethodError => e
          # self.class.send(:attr_accessor, k)
          # retry
        end
      end
    end
  end
end