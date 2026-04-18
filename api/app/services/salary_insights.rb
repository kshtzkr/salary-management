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
        average_salary_cents: average_salary_cents,
        median_salary_cents: median_salary_cents(salaries),
        total_payroll_cents: scope.sum(:annual_salary_cents)
      }
    }
  end

  private

  attr_reader :country_code, :scope

  def average_salary_cents
    scope.average(:annual_salary_cents)&.to_f&.round
  end

  def median_salary_cents(salaries)
    return nil if salaries.empty?

    midpoint = salaries.length / 2
    return salaries[midpoint] if salaries.length.odd?

    ((salaries[midpoint - 1] + salaries[midpoint]) / 2.0).round
  end
end
