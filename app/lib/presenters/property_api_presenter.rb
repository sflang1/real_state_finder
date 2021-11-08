module Presenters
  class PropertyApiPresenter
    class << self
      def format(object_to_format)
        if object_to_format.respond_to?(:map)
          object_to_format.map{ |property| format_single_property(property) }
        else
          format_single_property(object_to_format)
        end
      end

      def format_single_property(property)
        {
          id:                 property.id,
          house_number:       property.house_number,
          street:             property.street,
          city:               property.city,
          zip_code:           property.zip_code,
          lat:                property.lat,
          lng:                property.lng,
          price:              property.price,
        }
      end
    end
  end
end