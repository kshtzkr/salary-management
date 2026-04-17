module Api
  module V1
    class AuthController < ApplicationController
      def create
        user = User.active.find_by!(email: params.require(:email).to_s.downcase)

        unless user.authenticate(params.require(:password))
          return render_error("Invalid email or password", :unauthorized)
        end

        token = JsonWebToken.encode(user_id: user.id)

        render json: { token: token, user: UserSerializer.new(user).as_json }
      rescue ActionController::ParameterMissing
        render_error("Email and password are required", :unprocessable_entity)
      rescue ActiveRecord::RecordNotFound
        render_error("Invalid email or password", :unauthorized)
      end
    end
  end
end
