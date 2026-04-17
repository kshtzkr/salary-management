module Api
  module V1
    class AuthController < ApplicationController
      def create
        user = User.active.find_by!(email: params.require(:email).to_s.downcase)
        user.authenticate(params.require(:password)) || raise(ActiveRecord::RecordNotFound)

        token = JsonWebToken.encode(user_id: user.id)

        render json: { token: token, user: UserSerializer.new(user).as_json }
      end
    end
  end
end
