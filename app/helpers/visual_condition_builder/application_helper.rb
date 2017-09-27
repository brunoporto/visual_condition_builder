module VisualConditionBuilder
  module ApplicationHelper

    def build_conditions(dictionary, *args)
      dictionary_name = get_dictionary_name(dictionary)
      dictionary_klass = get_dictionary_klass(dictionary)
      container_name = "#{dictionary_name}_condition_container"

      hArgs = (args ||= []).reduce(Hash.new, :merge)
      hArgs = normalize_placeholder_label(hArgs)

      builder_options = {
          dictionary: dictionary_klass.dictionary(get_dictionary_context(dictionary), self.request)
      }.deep_merge(hArgs)

      render partial: 'visual_condition_builder/builder_conditions', locals: {container_name: container_name, builder_options: builder_options.to_json.html_safe}
    end

    def conditions_fields(dictionary, title: nil)
      dictionary_name = get_dictionary_name(dictionary)
      dictionary_klass = get_dictionary_klass(dictionary)
      container_id = "##{dictionary_name}_condition_container"
      fields = dictionary_klass.fields(get_dictionary_context(dictionary))
      title = I18n.t(:dropdown, default: ['Fields'], scope: [:condition_builder]) if title.blank?
      render partial: 'visual_condition_builder/conditions_fields',
             locals: {container_id: container_id, fields: fields, title: title}
    end

    private
    def get_dictionary_context(dictionary)
      dictionary.is_a?(Hash) ? dictionary.values.first : :default
    end
    def get_dictionary_name(dictionary)
      "#{dictionary.is_a?(Hash) ? dictionary.keys.first : dictionary}_#{get_dictionary_context(dictionary)}"
    end
    def get_dictionary_klass(dictionary)
      "#{dictionary.is_a?(Hash) ? dictionary.keys.first : dictionary}_dictionary".classify.constantize
    end

    def normalize_placeholder_label(args)
      args[:placeholder] ||= {}
      [:fields, :operators, :values].each do |attr|
        unless args[:placeholder][attr].present?
          label = I18n.t(attr, default: [''], scope: [:condition_builder, :placeholder])
          args[:placeholder][attr] = label if label.present?
        end
      end
      args
    end

  end
end
