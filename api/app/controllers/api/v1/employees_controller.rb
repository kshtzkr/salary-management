module Api
  module V1
    class EmployeesController < ApplicationController
      DEFAULT_PER_PAGE = 25

      before_action :authorize_read_access!, only: %i[index]

      def index
        page     = (params[:page].presence || 1).to_i
        per_page = (params[:per_page].presence || DEFAULT_PER_PAGE).to_i
        results  = EmployeeSearch.new(scope: Employee.kept, params: params).call
        total    = results.count
        records  = results.offset((page - 1) * per_page).limit(per_page)

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

      private

      def authorize_read_access!
        return if current_user.can_view_employees? || current_user.can_manage_employees?

        render_error("You are not allowed to view employees", :forbidden)
      end
    end
  end
end
