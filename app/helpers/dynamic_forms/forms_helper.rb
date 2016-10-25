# Helpers for creating/editing Forms
module DynamicForms
  module FormsHelper

    def display_form_field(form_builder, field, prefix=nil, extra_options={})
      field_name = prefix ? prefix : field.name
      responsive = extra_options.delete(:responsive)
      required = extra_options.delete(:required)

      if field.respond_to?(:system_field?) && field.system_field?
        if field.system_check_boxes?
          out = []
          out << "</br>"
          self.send(*field.system_field_options_for_select).each do |check_box|
            checked = extra_options[:value].to_a.include?(check_box[1])
            out <<  label_tag("custom_fields_#{field.name}_#{check_box[1]}", check_box[0] )
            out <<  check_box_tag("lead_search[custom_fields][#{field.name}][]", check_box[1], checked , :id => "custom_fields_#{field.name}_#{check_box[1]}"  )
            out << "</br>"
          end
          return out.join.html_safe
        elsif field.system_select?
          selected = extra_options[:value].present? ? extra_options[:value].to_s.to_i : nil
          return select_tag(extra_options[:name], options_for_select(self.send(*field.system_field_options_for_select), selected), :include_blank => true)
        elsif field.system_typeahead?
          return render(:partial => 'system_search_fields', :locals => {:f => form_builder, :field => field, :value => extra_options[:value]})
        end
      end

      if !field.field_helper_select_options.nil?
        if field.has_html_options?
          if field.respond_to?(:field_type) && field.field_type == 'select'
            return form_builder.send(field.kind.to_sym, field_name, options_for_select(field.field_helper_select_options, extra_options[:value]), field.field_helper_options, field.field_helper_html_options.merge(extra_options))
          else
            return form_builder.send(field.kind.to_sym, field_name, field.field_helper_select_options, field.field_helper_options, field.field_helper_html_options.merge(extra_options))
          end
        else
          extra_options.merge!(:responsive => responsive)
          return form_builder.send(field.kind.to_sym, field_name, field.field_helper_select_options, field.field_helper_options.merge(extra_options))
        end
      elsif ['date_select', 'datetime_select'].include?(field.kind.to_s)
        if responsive
          return render(:partial => '/shared/calendar_select', :locals => {
                  :required => required,
                  :input_format => field.kind.to_s == 'date_select' ? "LL" : 'LLL',
                  :input_id => "#{field.name}_select",
                  :input_field => form_builder.text_field(field_name, field.field_helper_html_options.merge(extra_options))
          })
        else
          return form_builder.send(:calendar_date_select, field_name, field.field_helper_html_options.merge(extra_options))
        end
      elsif (field.respond_to?(:field_type) && field.field_type == 'time_select') || (responsive && field.type == 'FormField::TimeSelect')
        if responsive
          return render(:partial => '/shared/calendar_select', :locals => {
                  :required => required,
                  :input_format => 'LT',
                  :input_id => "#{field.name}_select",
                  :input_field => form_builder.text_field(field_name, field.field_helper_html_options.merge(extra_options))
          })
        else
          return form_builder.send(:text_field, field_name, field.field_helper_html_options.merge(extra_options))
        end
      else
        if field.has_html_options?
          return form_builder.send(field.kind.to_sym, field_name, field.field_helper_options.merge(extra_options), field.field_helper_html_options)
        else
          return form_builder.send(field.kind.to_sym, field_name, field.field_helper_options.merge(extra_options))
        end
      end
    end

    def display_mobile_form_field(form_builder, field, prefix=nil, extra_options={})
      field_name = prefix ? prefix : field.name
      if !field.field_helper_select_options.nil?
        if field.has_html_options?
          if field.respond_to?(:field_type) && field.field_type == 'select'
            return form_builder.send(field.kind.to_sym, field_name, options_for_select(field.field_helper_select_options, extra_options[:value]), field.field_helper_options, field.field_helper_html_options.merge(extra_options))
          else
            return form_builder.send(field.kind.to_sym, field_name, field.field_helper_select_options, field.field_helper_options, field.field_helper_html_options.merge(extra_options))
          end
        elsif field.respond_to?(:field_type) && field.field_type == 'radio_button_select'
          return ("<div data-role=\"fieldcontain\"><fieldset data-role=\"controlgroup\">" + field.field_helper_select_options.map{|op| radio_button_tag(field.name, op, extra_options[:value] == op, extra_options.except(:value)) + label_tag(field.name+"_#{op}", op)}.join('') + "</fieldset></div>").html_safe
        elsif field.respond_to?(:field_type) && field.field_type == 'check_box_group'
          return ("<div data-role=\"fieldcontain\"><fieldset data-role=\"controlgroup\">" + field.field_helper_select_options.map{|op| check_box_tag(field_name, op, extra_options[:source] && extra_options[:source].include?(op), extra_options.except(:value).merge({:id => field.name+"_#{op}"})) + label_tag(field.name+"_#{op}", op)}.join('') + "</fieldset></div>").html_safe
        else
          return form_builder.send(field.kind.to_sym, field_name, field.field_helper_select_options, field.field_helper_options.merge(extra_options))
        end
      elsif ['time_select', 'datetime_select', 'date_select'].include? field.kind.to_s
        return form_builder.send(:text_field, field_name, extra_options.merge({:readonly => true, 'data-field' => field.kind.gsub("_select", "")}))
      elsif field.respond_to?(:field_type) && field.field_type == 'check_box'
        return form_builder.send(:select, field_name, options_for_select([["No","0"], ["Yes", "1"]], extra_options[:value]), {}, extra_options.merge({'data-role' => 'slider'}))
      else
        if field.has_html_options?
          return form_builder.send(field.kind.to_sym, field_name, field.field_helper_options.merge(extra_options), field.field_helper_html_options)
        else
          return form_builder.send(field.kind.to_sym, field_name, field.field_helper_options.merge(extra_options))
        end
      end
    end

    def link_to_add_field(name, f, association, conatiner_id, subclass = nil, html_options = {})
      if subclass
        new_object = subclass.constantize.new
      else
        new_object = f.object.class.reflect_on_association(association).klass.new
      end
      fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render :partial => "forms/#{association.to_s.singularize}", :locals => {:f => builder}
      end
      link_to_function(name, h("add_field(\"#{conatiner_id}\", \"#{association}\", \"#{escape_javascript(fields)}\")".html_safe), html_options)
    end

    def link_to_add_field_option(name, f, association, html_options = {})
      new_object = f.object.class.reflect_on_association(association).klass.new
      fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
        render :partial => "forms/#{association.to_s.singularize}", :locals => {:f => builder}
      end
      link_to_function(name, h("add_field_option(this, \"#{association}\", \"#{escape_javascript(fields)}\")".html_safe), html_options)
    end

    def link_to_remove_field(name, f, html_options = {})
      f.hidden_field(:_destroy) + link_to_function(name, "remove_field(this)", html_options)
    end

    def link_to_remove_field_option(name, f, html_options = {})
      f.hidden_field(:_destroy) + link_to_function(name, "remove_field_option(this)", html_options)
    end

  end
end
