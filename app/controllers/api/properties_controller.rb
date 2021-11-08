module Api
  class PropertiesController < ApiController
    def search
      input = PropertySearchInput.new(search_params)
      raise BadRequest.new(input.errors.full_messages) unless input.valid?

      # if record is valid
      properties = Property.within_range(params[:lat], params[:lng], 5).where(offer_type: params[:marketing_type], property_type: params[:property_type])
      raise NotFound.new(['No properties found for your search']) if properties.count == 0
      render_success(Presenters::PropertyApiPresenter.format(properties))
    end

    private
    def search_params
      params.permit(:lat, :lng, :marketing_type, :property_type)
    end
  end
end