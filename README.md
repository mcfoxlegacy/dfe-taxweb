# Biblioteca Documento Fiscal

Biblioteca para manipulação de Documentos Fiscais

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/286e9c4e761d4584ba0ae86f7be5862a)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=taxweb/documento_fiscal_lib&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://api.codacy.com/project/badge/Coverage/286e9c4e761d4584ba0ae86f7be5862a)](https://www.codacy.com?utm_source=github.com&utm_medium=referral&utm_content=taxweb/documento_fiscal_lib&utm_campaign=Badge_Coverage)

## Instalação

Adicione essa linha no Gemfile da sua aplicação:

```ruby
gem 'documento_fiscal_lib',  :git => 'https://TOKEN:x-oauth-basic@github.com/taxweb/documento_fiscal_lib.git'
```

E então execute no terminal na raiz do seu projeto:

    $ bundle

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
hash_documento_fiscal = DocumentoFiscalLib.nfe(xml_string).para_documento_fiscal
hash_documento_fiscal[:emitente][:nome] # Fulano de Tal
```