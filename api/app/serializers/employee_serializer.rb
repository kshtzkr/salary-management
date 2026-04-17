class EmployeeSerializer
  def initialize(employee)
    @employee = employee
  end

  def as_json(*)
    {
      id: employee.id,
      employee_code: employee.employee_code,
      full_name: employee.full_name,
      work_email: employee.work_email,
      job_title: employee.job_title,
      department: employee.department,
      country_code: employee.country_code,
      currency_code: employee.currency_code,
      annual_salary_cents: employee.annual_salary_cents,
      employment_status: employee.employment_status,
      hired_on: employee.hired_on,
      archived: employee.archived?,
      created_at: employee.created_at,
      updated_at: employee.updated_at
    }
  end

  private

  attr_reader :employee
end
