require 'singleton'
require 'yaml'

module DfeTaxweb
  class Atributos
    include Singleton

    attr_reader :atributos_hash, :atributos_list, :atributos_object

    def initialize
      atributos_h = YAML.load(File.read(File.join(__dir__, 'atributos.yml')))
      @atributos_hash ||= atributos_h['documento'].deep_symbolize_keys || {}
    end

    def lista
      @atributos_list ||= tree_to_list(@atributos_hash)
    end

    def colecao
      @atributos_object ||= lista.map do |atributo_path|
        atributo(atributo_path)
      end.compact
    end

    def atributo(path, conjunto=nil)
      conjunto = @atributos_hash if conjunto.nil?
      attrs = path.split(".").inject(conjunto) do |item, key|
        next if item.nil?
        if key =~ /\[\d+\]/
          item[key.sub(/\[\d+\]/, '').to_sym][key[/\[(\d+)\]/, 1].to_i]
        else
          item[key.to_sym]
        end
      end
      DfeTaxweb::Atributo.new(attrs, path)
    end

    private
    def tree_to_list(hash, parent='')
      if hash.is_a?(Array)
        hash.map {|a| tree_to_list(a, parent)}.flatten.compact
      elsif hash.is_a?(Hash)
        hash.map do |key, attrs|
          extra_attributes = attrs.except(:titulo, :descricao) #YML
          if extra_attributes.present?
            normalized_parent = normalize_parent_key(parent, key)
            tree_to_list(extra_attributes, normalized_parent)
          else
            tree_to_list(key, parent)
          end
        end.flatten.compact
      else
        normalize_parent_key(parent, hash)
      end
    end

    def normalize_parent_key(parent, key)
      parent.present? ? "#{parent}.#{key}" : "#{key}"
    end

  end

end