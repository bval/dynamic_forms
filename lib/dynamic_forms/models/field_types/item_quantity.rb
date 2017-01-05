# Models a ItemQuantity
module DynamicForms
  module Models
    module FieldTypes
      module ItemQuantity
        
        def self.included(model)
          model.class_eval do
            allow_validation_of :required, :number
          end
        end
        
      end
    end
  end
end
