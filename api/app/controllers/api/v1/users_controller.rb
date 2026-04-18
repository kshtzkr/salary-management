module Api
  module V1
    class UsersController < ApplicationController
      before_action -> { authorize_roles!(:admin) }

      def index
        render json: { users: User.order(:full_name).map { |user| UserSerializer.new(user).as_json } }
      end

      def create
        user = User.new(user_params)

        if user.save
          render json: { user: UserSerializer.new(user).as_json }, status: :created
        else
          render_error("User could not be created", :unprocessable_entity, user.errors.full_messages)
        end
      end

      private

      def user_params
        permitted = params.require(:user).permit(:full_name, :email, :role, :password, :password_confirmation, :active)
        permitted.delete(:password) if permitted[:password].blank?
        permitted.delete(:password_confirmation) if permitted[:password_confirmation].blank?
        permitted
      end
    end
  end
end
