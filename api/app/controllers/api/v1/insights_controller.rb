module Api
  module V1
    class InsightsController < ApplicationController
      before_action :authorize_read_access!
      before_action :require_country!

      def overview
        render json: SalaryInsights.new(country_code: params[:country]).overview
      end

      def job_titles
        render json: SalaryInsights.new(country_code: params[:country]).job_titles
      end

      private

      def authorize_read_access!
        return if current_user.can_view_insights?

        render_error("You are not allowed to view salary insights", :forbidden)
      end

      def require_country!
        return if params[:country].present?

        render_error("country is required", :unprocessable_entity)
      end
    end
  end
end
