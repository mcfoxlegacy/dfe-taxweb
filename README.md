# Documento Fiscal TaxWeb

Biblioteca para manipulação de Documentos Fiscais

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/658ba4cd0f254379bc23add8abbf0216)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=taxweb/dfe-taxweb&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/658ba4cd0f254379bc23add8abbf0216)](https://www.codacy.com?utm_source=github.com&utm_medium=referral&utm_content=taxweb/dfe-taxweb&utm_campaign=Badge_Coverage)

## Instalação

Adicione essa linha no Gemfile da sua aplicação:

```ruby
gem 'dfe-taxweb'
```

E então execute no terminal no diretório do seu projeto:

    $ bundle install

## Dependência

```ruby
activesupport >= 4
 ```

## Uso

##### NFe

- **to_dfe** : Converte uma NFe para a estrutura do documento fiscal TaxWeb.
 
```ruby
xml_string = File.read('/caminho/nfe.xml')
hash_documento_fiscal = DfeTaxweb.nfe(xml_string).to_dfe

# também é possível enviar um hash do xml.  
# hash_documento_fiscal = DfeTaxweb.nfe(xml_hash).to_dfe

hash_documento_fiscal[:emitente][:nome] # Fulano de Tal
```