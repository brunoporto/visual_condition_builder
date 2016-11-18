# Search Builder 
[![Code Climate](https://codeclimate.com/github/brunoporto/visual_condition_builder/badges/gpa.svg)](https://codeclimate.com/github/brunoporto/visual_condition_builder)

A great and easy search builder to your rails project

## How to install

Add it to your **Gemfile**: 
```ruby
gem 'visual_condition_builder'
```

Run the following command to install it:
```sh
$ bundle install
```

Add it to your **app/assets/stylesheets/application.css**
```js
*= require visual_condition_builder
```

Add it to your **app/assets/javascripts/application.js**
```js
//= require visual_condition_builder
```

## Dependency

Antes de iniciar o plugin você precisa ter o jQuery adicionado no seu application.js

Caso você tenha os seguintes plugins jQuery indicados no seu application.js, você deve remover:

- [select2](https://github.com/select2/select2)
- [autoNumeric](https://github.com/BobKnothe/autoNumeric#default-settings--supported-options)

### Select2 Languages

Select2 supports multiple languages by simply including the right language JS file (visual_condition_builder/select2_i18n/it, visual_condition_builder/select2_i18n/pt-BR, etc.) after visual_condition_builder in your **application.js**
```js
//= require visual_condition_builder/select2_i18n/en
//= require visual_condition_builder/select2_i18n/pt-BR
```

## Dictionaries

As informações do gerador de condições são baseadas em um dicionário, portanto é necessário que você crie seus dicionários de acordo com o necessário.

Para gerar um novo dicionário use o comando:

```sh
$ rails g visual_condiction_builder:dictionary example
```

Será criado um arquivo na pasta `app/condition_dictionaries/example_dictionary.rb` com a seguinte estrutura:

```ruby
class ExampleDictionary < VisualConditionBuilder::Dictionary

  dictionary do
    param :name
  end

end
```

Você pode criar multiplos contextos para esse dicionário:
```ruby
  dictionary :simple do
    param :name
  end
  
  dictionary :complex do
    param :first_name
    param :last_name
  end
```

### Params

Você não tem restrição ao uso dos parametros, pois eles não tem ligação com model ou qualquer outro elemento da aplicação.
Ao informar os parametros você pode passar argumentos para personalizar a forma como o gerador de condições será criado:

```ruby
  dictionary do
    param :name, type: 'STRING', operators: [:eq]
    param :created_at, type: 'DATE', operators: [{operator: 'eq', label: 'Equal', multiple: true, no_value: false}]
    param :updated_at, type: 'DATE', operators: [{operator: 'between', label: 'Between ... and ...', multiple: 2, no_value: false}]
    param :today, type: 'DATE', operators: [{operator: 'eq', label: 'Equal', multiple: false, no_value: true}]
  end
```

Veja abaixo todos os argumentos que você pode usar na construção dos operadores:

**TABELA DE PARAMETROS DE OPERADORES**

Por padrão, o gerador de condições implementa alguns operadores e argumentos, possibilitando que você informe apenas o nome do operador `operators: [:eq, :between]` 

Lista de operadores padrões do gerador de condições

Operator | Description | Default Arguments
--- | --- | ---
between | Between .. e .. | multiple: 2
today | Today(date) | no_value: true
yesterday | Yesterday(date) | no_value: true
tomorrow | Tomorrow(date) | no_value: true
this_week | First day of Current Week .. Last day of Current Week  | no_value: true
last_week | First day of Last Week .. Last day of Last Week | no_value: true
next_week | First day of Next Week .. Last day of Next Week | no_value: true
eq | Is exactly equal to a given value | multiple: false
not_eq | Opposite :eq | multiple: false
matches | Is like a given value | multiple: false
does_not_match |Opposite :matches | multiple: false
lt | is less than a given value | multiple: false
gt | is greater than a given value | multiple: false
lteq | is less than or equal to a given value | multiple: false
gteq | is greater than or equal to a given value | multiple: false
in | is within a specified list | multiple: true
not_in | Opposite :in | multiple: true
cont | contains a given value | multiple: false
not_cont | Opposite :not_cont  | multiple: false
cont_any | contains any of the given values | multiple: true
not_cont_any | Opposite :cont_any  | multiple: true
cont_all | contains all of the given values | multiple: true
not_cont_all | Opposite :cont_all  | multiple: true
start | begins with a given value | multiple: false
not_start | Opposite :start  | multiple: false
end | ends with a given value | multiple: false
not_end | Opposite :end  | multiple: false
true | where a field is true | no_value: true, multiple: false
not_true | Opposite :true  | no_value: true, multiple: false
false | where a field is false | no_value: true, multiple: false
not_false | Opposite :false  | no_value: true, multiple: false
present | where a field is present (not null and not a blank string) | no_value: true, multiple: false
blank | Opposite :present | no_value: true, multiple: false
null | where a field is null | no_value: true, multiple: false
not_null | Opposite :null  | no_value: true, multiple: false

Caso você não informe os operadores, o gerador de condições irá selecionar os operadores baseado no tipo informado:
*Se um tipo não for informado, será considerado STRING*

Type | Default Operators
--- | ---
DATE, DATETIME | eq, between, today, yesterday, tomorrow, this_week, last_week, next_week, present, blank
TIME | eq, between, present, blank
DECIMAL, INTEGER | eq, between
STRING | cont, eq, start, end, present, blank
... | eq

Também é possível informar listas de valores ou valores pré-definidos para que o gerador de condições para carregar esses valores por padrão:

```ruby
  dictionary do
    param :status, values: [{id: 1, label: 'Active', id: 2, label: 'Inactive'}]
    param :status_list, values: MyStatus.all.dictionary_values(:code, :title)
    param :status_proc, values: -> { MyService.get_status }
    param :status_ajax, values: ajax_my_status_path
  end
```

Em todos os exemplos acima o resultado deve sempre seguir a estrutura :

```ruby
[
    {id: 1, label: 'Example'},
    {id: 2, label: 'Example 2'},
    {id: 'A', label: 'Example 3'},
    {id: 'Text', label: 'My Text'}
]
```

Quando for utilizar uma chamada AJAX o gerador de condições fará requisições passando dois tipos de parametros: **init** ou **key**, onde:
* init - é o parametro com o valor inicial da lista. Quando o plugin tenta carregar a lista ele deverá mostrar um valor inicial antes da busca feita pelo usuário, portanto esse valor inicial deve ser retornado através do parametro init:
* key - é o parametro com o valor digitado pelo usuário para efetuar o retorno dos valores da lista.

O retorno deverá seguir a estrutua padrão de valores do dicionário e retornar em formato JSON. Exemplo de um controller que implementa essa função:
```ruby
class CitiesController < ApplicationController
  def ajax
    if params[:init]
      @cities = City.where(id: params[:init])
    else
      @cities = City.where('cities.name LIKE ?', "%#{params[:key]}%").order(:name).limit(100)
    end
    render json: @cities.select('cities.id, cities.name AS label').to_json
  end
end
```

### Methods

Dictionary Class have public methods to get informations about self:
* fields(dictionary_context_name)
* dictionary(dictionary_context_name)
* dictionaries

```ruby
#example_dictionary.rb
class ExampleDictionary < VisualConditionBuilder::Dictionary

  dictionary do
    param :name
  end

  dictionary :complex do
    param :name
    param :age
  end

end

#rails console
ExampleDictionary.fields
# =>  {:name=>{:label=>"Name", :type=>"STRING"}}

ExampleDictionary.fields(:complex)
# =>  {:name=>{:label=>"Name", :type=>"STRING"}, :age=>{:label=>"Age", :type=>"STRING"}}

ExampleDictionary.dictionary
# =>  [{:type=>"STRING", :operators=>[{:operator=>:cont, :multiple=>false, :no_value=>false, :label=>"Contém"}, {:operator=>:eq, :multiple=>false, :no_value=>false, :label=>"Igual"}, {:operator=>:start, :multiple=>false, :no_value=>false, :label=>"Começa com"}, {:operator=>:end, :multiple=>false, :no_value=>false, :label=>"Termina com"}, {:operator=>:present, :no_value=>true, :multiple=>false, :label=>"Presente"}, {:operator=>:blank, :no_value=>true, :multiple=>false, :label=>"Não Presente"}], :values=>[], :group=>"", :label=>"Name", :field=>:name}]

ExampleDictionary.dictionary(:complex)
# =>  [{:type=>"STRING", :operators=>[{:operator=>:cont, :multiple=>false, :no_value=>false, :label=>"Contém"}, {:operator=>:eq, :multiple=>false, :no_value=>false, :label=>"Igual"}, {:operator=>:start, :multiple=>false, :no_value=>false, :label=>"Começa com"}, {:operator=>:end, :multiple=>false, :no_value=>false, :label=>"Termina com"}, {:operator=>:present, :no_value=>true, :multiple=>false, :label=>"Presente"}, {:operator=>:blank, :no_value=>true, :multiple=>false, :label=>"Não Presente"}], :values=>[], :group=>"", :label=>"Name", :field=>:name}, {:type=>"STRING", :operators=>[{:operator=>:cont, :multiple=>false, :no_value=>false, :label=>"Contém"}, {:operator=>:eq, :multiple=>false, :no_value=>false, :label=>"Igual"}, {:operator=>:start, :multiple=>false, :no_value=>false, :label=>"Começa com"}, {:operator=>:end, :multiple=>false, :no_value=>false, :label=>"Termina com"}, {:operator=>:present, :no_value=>true, :multiple=>false, :label=>"Presente"}, {:operator=>:blank, :no_value=>true, :multiple=>false, :label=>"Não Presente"}], :values=>[], :group=>"", :label=>"Age", :field=>:age}] 

ExampleDictionary.dictionaries
# =>  {:default=>[{:type=>"STRING", :operators=>[{:operator=>:cont, :multiple=>false, :no_value=>false, :label=>"Contém"}, {:operator=>:eq, :multiple=>false, :no_value=>false, :label=>"Igual"}, {:operator=>:start, :multiple=>false, :no_value=>false, :label=>"Começa com"}, {:operator=>:end, :multiple=>false, :no_value=>false, :label=>"Termina com"}, {:operator=>:present, :no_value=>true, :multiple=>false, :label=>"Presente"}, {:operator=>:blank, :no_value=>true, :multiple=>false, :label=>"Não Presente"}], :values=>[], :group=>"", :label=>"Name", :field=>:name}], :padrao=>[{:type=>"STRING", :operators=>[{:operator=>:cont, :multiple=>false, :no_value=>false, :label=>"Contém"}, {:operator=>:eq, :multiple=>false, :no_value=>false, :label=>"Igual"}, {:operator=>:start, :multiple=>false, :no_value=>false, :label=>"Começa com"}, {:operator=>:end, :multiple=>false, :no_value=>false, :label=>"Termina com"}, {:operator=>:present, :no_value=>true, :multiple=>false, :label=>"Presente"}, {:operator=>:blank, :no_value=>true, :multiple=>false, :label=>"Não Presente"}], :values=>[], :group=>"", :label=>"Name", :field=>:name}, {:type=>"STRING", :operators=>[{:operator=>:cont, :multiple=>false, :no_value=>false, :label=>"Contém"}, {:operator=>:eq, :multiple=>false, :no_value=>false, :label=>"Igual"}, {:operator=>:start, :multiple=>false, :no_value=>false, :label=>"Começa com"}, {:operator=>:end, :multiple=>false, :no_value=>false, :label=>"Termina com"}, {:operator=>:present, :no_value=>true, :multiple=>false, :label=>"Presente"}, {:operator=>:blank, :no_value=>true, :multiple=>false, :label=>"Não Presente"}], :values=>[], :group=>"", :label=>"Age", :field=>:age}]} 
```

## Helpers

#### (class) dictionary_values(param_id, param_label)
Deve ser utilizado em objetos do tipo: Array ou ActiveRecord::Relation e usa o primeiro parametro como **id** e o segundo como **label** na construção da estrutura de valores para o dicionário
```ruby
dictionary do
  param :book_id, values: Book.all.dictionary_values(:code, :title)
  #MyService.myarray = [['Active','1'], ['Inactive','2'], ['Blocked','3']] 
  param :status, values: MyService.myarray.dictionary_values(1, 0)
end
```

#### (view) conditions_fields(name_of_dictionary)
Cria um seletor de campos em um elemento dropdown (bootstrap).
```haml
= conditions_fields :example
-# with context:
= conditions_fields({:dictionary_name => :context_name})
```

Mas você pode fazer a geração da lista de campos manualmente através do método `ExampleDictionary.fields(dictionary_name)` *(example_dictionary.rb)*, nesse caso você deve ter elementos "clicáveis" com a classe `add-condition-field` e atributo `data-field: field_name`
 ```haml
%a.add-condition-field{href: '#', data: {field: 'name'}} Name
%a.add-condition-field{href: '#', data: {field: 'age'}} Age
%a.add-condition-field{href: '#', data: {field: 'example'}} Example Field
 ```

#### (view) build_conditions(name_of_dictionary, *arguments)

Cria o gerador de condições na sua view:
```haml
= form_tag obrigacoes_path, method: :get do
    -# condition builder don't create input field with values, create it:
    = hidden_field_tag('my_conditions', @example_conditions.to_json)
    -# DropDown with fields
    = conditions_fields :example
    -# Conditions Element
    = build_conditions :example, input: '#my_conditions', select2Config: {allowClear: true}
```
Por padrão será gerado um elemento com o id no padrão dictionary_name + context_name + condition_container: `example_default_condition_container`

Para criar baseado em um dicionário de contexto específico use:
```haml
= build_conditions({:dictionary_name => :context_name}, input: '#my_conditions', select2Config: {allowClear: true})
```
Os argumentos possíveis para o build_conditions são:

Param | Description
--- | ---
placeholder | Placeholder for inputs {operators: 'Select a operator...', values: 'Enter a value...'}, 
values | initial values to fill conditions, format: [[field, operator, value], [field, operator, [value1, value2]]]
input  | to get initial values and save values on change from a html element, like: #my_input_element
debug | to see debugs flags. default: false
numericConfig | When the field is decimal type then the generator will create an input with numeric mask. Default {aSep: '', aDec: '.', aSign: ''}. See [Auto Numeric Plugin](https://github.com/BobKnothe/autoNumeric#default-settings--supported-options)
select2Config: | Select2 Configuration. Default {theme: "bootstrap", width: 'auto', placeholder: '', allowClear: false, dropdownAutoWidth: 'true', tags: false, language: "en"}, but some parameters can be overwritten by condition builder. See [Select2 Plugin](https://github.com/select2/select2)

Também é possível criar o builder manualmente chamando o plugin jquery diretamente:
```javascript
//my_dictionary_json = ExampleDictionary.dictionary(:example).to_json
//my_initial_values = [['name','eq','My Name']]
var builder = $('#div-container').conditionBuilder({
    placeholder: {values: 'Select a Value'},
    dictionary: my_dictionary_json,
    values: my_initial_values,
    select2Config: {language: 'pt-BR'} //visual_condition_builder/select2_i18n/pt-BR
});
```

## Javascript Methods/Callback

The conditions builder plugin have two actions:
* **Clear** - clear the conditions rows
* **Result** - return the conditions values on change fields, operators or values.

Example:

```javascript
$(document).ready(function () {
    //get the builder instance
    var $conditionBuilder = $('#example_default_condition_container').data('conditionBuilder');

    //clear conditions rows
    $('#button_to_clear_list').on('click',function(e){
      e.preventDefault();
      $conditionBuilder.clear_rows();
    });
    
    //Callback on change conditions
    $conditionBuilder.result = function(data) {
        //result data object: [[field, operator, value], [field, operator, [value1, value2]]]
        console.log(data);
        //convert to STRING before send FORM
        var json_data = JSON.stringify(data);
    }
});
```

## Converters

Condition Builder have converters of values to use in controller:
* **Ransack** - Convert conditions values `['name', 'eq', 'My Name']` in `{:name_eq => "My Name"}`

```ruby
  @example_conditions = JSON.parse(params[:my_conditions] ||= '[]')
  ransack_params = VisualConditionBuilder::Converter.to_ransack(@example_conditions)
  @q = source.ransack(ransack_params)
  @records = @q.result.paginate(page: params[:page], per_page: 10)
```


## Bug reports

If you discover any bugs, feel free to create an issue on GitHub. Please add as much information as
possible to help us fixing the possible bug. We also encourage you to help even more by forking and
sending us a pull request.

https://github.com/brunoporto/visual_condition_builder/issues

## Maintainers

* Bruno Porto (https://github.com/brunoporto)

## License

The MIT License (MIT)
Copyright (c) 2016 Bruno Porto

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.