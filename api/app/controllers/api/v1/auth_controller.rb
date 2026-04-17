module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: :create

      def create
        user = User.active.find_by!(email: params.require(:email).to_s.downcase)

        unless user.authenticate(params.require(:password))
          return render_error("Invalid email or password", :unauthorized)
        end

        user.update!(last_login_at: Time.current)
        token = JsonWebToken.encode(user_id: user.id)

        render json: { token: token, user: UserSerializer.new(user).as_json }
      rescue ActionController::ParameterMissing
        render_error("Email and password are required", :unprocessable_entity)
      rescue ActiveRecord::RecordNotFound
        render_error("Invalid email or password", :unauthorized)
      end

      def show
        render json: { user: UserSerializer.new(current_user).as_json }
      end

      def destroy
        head :no_content
      end
    end
  end
end
