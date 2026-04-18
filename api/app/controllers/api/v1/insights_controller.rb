module Api
  module V1
    class InsightsController < ApplicationController
      def overview
        render json: SalaryInsights.new(country_code: params[:country]).overview
      end
    end
  end
end
