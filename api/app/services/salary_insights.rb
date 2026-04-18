class SalaryInsights
  def initialize(country_code:)
    @country_code = country_code.to_s.upcase
    @scope = Employee.kept.where(country_code: @country_code)
  end

  def overview
    {
      country: country_code,
      currency_code: scope.pick(:currency_code)
    }
  end

  private

  attr_reader :country_code, :scope
end
