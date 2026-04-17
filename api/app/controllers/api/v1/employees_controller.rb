module Api
  module V1
    class EmployeesController < ApplicationController
      DEFAULT_PER_PAGE = 25

      def index
        page     = (params[:page].presence || 1).to_i
        per_page = (params[:per_page].presence || DEFAULT_PER_PAGE).to_i
        scope    = Employee.kept.order(:full_name)
        total    = scope.count
        records  = scope.offset((page - 1) * per_page).limit(per_page)

        render json: {
          employees: records.map { |employee| EmployeeSerializer.new(employee).as_json },
          meta: {
            page: page,
            per_page: per_page,
            total: total,
            total_pages: (total / per_page.to_f).ceil
          }
        }
      end
    end
  end
end
