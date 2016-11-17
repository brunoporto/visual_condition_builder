module VisualConditionBuilder
  module Helper
    def dictionary_values(id_field, label_field)
      self.map{|r| {id: r[id_field], label: r[label_field]} }
    end
  end
end

#INJETANDO METODO para_* em um conjunto de array
class Array
  include VisualConditionBuilder::Helper
end

#INJETANDO METODO para_* em um conjunto de registros ActiveRecord::Relation
module ActiveRecord
  class Relation
    include VisualConditionBuilder::Helper
  end
end