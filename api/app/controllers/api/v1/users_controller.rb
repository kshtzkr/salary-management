module Api
  module V1
    class UsersController < ApplicationController
      before_action -> { authorize_roles!(:admin) }

      def index
        render json: { users: User.order(:full_name).map { |user| UserSerializer.new(user).as_json } }
      end
    end
  end
end
