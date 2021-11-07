module Api
  class PropertiesController < ApiController
    def index
      render json: { success: 200 }
    end
  end
end