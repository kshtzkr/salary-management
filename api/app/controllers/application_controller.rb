class ApplicationController < ActionController::API
  before_action :authenticate_user!

  attr_reader :current_user

  private

  def authenticate_user!
    token = bearer_token
    payload = JsonWebToken.decode(token)
    @current_user = User.active.find(payload.fetch("user_id"))
  rescue KeyError, ActiveRecord::RecordNotFound, JsonWebToken::DecodeError
    render_error("Authentication required", :unauthorized)
  end

  def authorize_roles!(*roles)
    return if current_user&.role_in?(roles)

    render_error("You are not allowed to perform this action", :forbidden)
  end

  def render_error(message, status, details = nil)
    render json: { error: message, details: details }, status: status
  end

  def bearer_token
    request.authorization.to_s.split(" ", 2).last if request.authorization.to_s.start_with?("Bearer ")
  end
end
