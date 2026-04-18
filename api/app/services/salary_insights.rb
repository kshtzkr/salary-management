class SalaryInsights
  def initialize(country_code:)
    @country_code = country_code.to_s.upcase
    @scope = Employee.kept.where(country_code: @country_code)
  end

  def overview
    salaries = scope.pluck(:annual_salary_cents).sort

    {
      country: country_code,
      currency_code: scope.pick(:currency_code),
      metrics: {
        minimum_salary_cents: salaries.first,
        maximum_salary_cents: salaries.last,
        total_payroll_cents: scope.sum(:annual_salary_cents)
      }
    }
  end

  private

  attr_reader :country_code, :scope
end
