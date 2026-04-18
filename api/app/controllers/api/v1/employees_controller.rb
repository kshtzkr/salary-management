module Api
  module V1
    class EmployeesController < ApplicationController
      DEFAULT_PER_PAGE = 25

      before_action :authorize_read_access!,   only: %i[index show]
      before_action :authorize_manage_access!, only: %i[create update destroy restore]
      before_action :set_employee, only: %i[show update destroy restore]

      rescue_from ActiveRecord::RecordNotFound do
        render_error("Employee not found", :not_found)
      end

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

      def show
        render json: { employee: EmployeeSerializer.new(@employee).as_json }
      end

      def create
        employee = Employee.new(employee_params)

        if employee.save
          render json: { employee: EmployeeSerializer.new(employee).as_json }, status: :created
        else
          render_error("Employee could not be saved", :unprocessable_entity, employee.errors.full_messages)
        end
      end

      def update
        if @employee.update(employee_params)
          render json: { employee: EmployeeSerializer.new(@employee).as_json }
        else
          render_error("Employee could not be updated", :unprocessable_entity, @employee.errors.full_messages)
        end
      end

      def destroy
        @employee.soft_delete!
        head :no_content
      end

      def restore
        @employee.restore!
        render json: { employee: EmployeeSerializer.new(@employee).as_json }
      end

      private

      def authorize_read_access!
        return if current_user.can_view_employees? || current_user.can_manage_employees?

        render_error("You are not allowed to view employees", :forbidden)
      end

      def authorize_manage_access!
        return if current_user.can_manage_employees?

        render_error("You are not allowed to manage employees", :forbidden)
      end

      def set_employee
        @employee = if params[:action] == "restore"
          Employee.archived.find(params[:id])
        elsif params[:action] == "show" && ActiveModel::Type::Boolean.new.cast(params[:include_archived])
          Employee.find(params[:id])
        else
          Employee.kept.find(params[:id])
        end
      end

      def employee_params
        params.require(:employee).permit(
          :employee_code,
          :full_name,
          :work_email,
          :job_title,
          :department,
          :country_code,
          :currency_code,
          :annual_salary_cents,
          :employment_status,
          :hired_on
        )
      end
    end
  end
end
