# Biblioteca Documento Fiscal

Biblioteca para manipulação de Documentos Fiscais

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/286e9c4e761d4584ba0ae86f7be5862a)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=taxweb/dfe_taxweb&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/286e9c4e761d4584ba0ae86f7be5862a)](https://www.codacy.com?utm_source=github.com&utm_medium=referral&utm_content=taxweb/dfe_taxweb&utm_campaign=Badge_Coverage)

## Instalação

Adicione essa linha no Gemfile da sua aplicação:

```ruby
gem 'dfe_taxweb',  :git => 'https://TOKEN:x-oauth-basic@github.com/taxweb/dfe_taxweb.git'
```
Troque `TOKEN` pelo seu [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) do GitHub

E então execute no terminal no diretório do seu projeto:

    $ bundle install

## Dependência

```ruby
activesupport >= 4
 ```

## Uso

Atualmente só há um método para um tipo de arquivo NFe:

##### NFe

- **para_documento_fiscal** : Converte uma NFe para a estrutura do documento fiscal.
 
```ruby
xml_string = File.read('/caminho/nfe.xml')
# também é possível enviar um hash do xml.  
hash_documento_fiscal = DfeTaxweb.nfe(xml_string).para_documento_fiscal
hash_documento_fiscal[:emitente][:nome] # Fulano de Tal
```