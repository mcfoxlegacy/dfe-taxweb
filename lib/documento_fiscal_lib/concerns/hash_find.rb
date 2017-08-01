module HashFinders
  # extend ActiveSupport::Concern
  refine Hash do
    def atributo(path)
      path.split(".").inject(self.deep_symbolize_keys){|hash, key| hash[key.to_sym] }
    end

    def atualizar(atributos, valor)
      hash = atributos.split(".").push(valor).reverse.inject{|h,k| {k=>h}}
      self.deep_merge!(hash.deep_symbolize_keys)
    end
  end
end