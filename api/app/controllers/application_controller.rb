class ApplicationController < ActionController::API
  private

  def render_error(message, status, details = nil)
    render json: { error: message, details: details }, status: status
  end
end
