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
        total_payroll_cents: scope.sum(:annual_salary_cents),
        active_employee_count: scope.count,
        employee_count_by_status: scope.group(:employment_status).count.transform_keys { |status| Employee.employment_statuses.key(status) }
      },
      top_job_titles: job_title_breakdown.first(10)
    }
  end

  def job_titles
    {
      country: country_code,
      currency_code: scope.pick(:currency_code),
      job_titles: job_title_breakdown
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

  def job_title_breakdown
    scope.group(:job_title)
         .pluck(:job_title, Arel.sql("AVG(annual_salary_cents)"), Arel.sql("COUNT(*)"))
         .map do |job_title, average_salary_cents, employee_count|
      {
        job_title: job_title,
        average_salary_cents: average_salary_cents.to_f.round,
        employee_count: employee_count
      }
    end.sort_by { |row| [-row[:employee_count], row[:job_title]] }
  end
end
