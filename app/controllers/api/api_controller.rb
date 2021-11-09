module Api
  class ApiController < ApplicationController
    # pagy for pagination
    include Pagy::Backend

    class BadRequest < StandardError; end
    class NotFound < StandardError; end

    rescue_from BadRequest,               with: :bad_request
    rescue_from NotFound,                 with: :not_found

    def render_success(data)
      render json: { success: true, data: data, message: '' }
    end

    def render_error(message, error_code)
      render json: { success: false, data: [], message: JSON.parse(message) }, status: error_code
    end

    def bad_request(exception)
      render_error(exception.message, 400)
    end

    def not_found(exception)
      render_error(exception.message, 404)
    end
  end
end