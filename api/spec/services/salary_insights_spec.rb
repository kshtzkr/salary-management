require "rails_helper"

RSpec.describe SalaryInsights do
  describe "#overview" do
    it "reports the requested country and its currency" do
      create(:employee, country_code: "US", currency_code: "USD", annual_salary_cents: 150_000_00, employee_code: "EMP-I001", work_email: "i1@salary.local")
      create(:employee, country_code: "DE", currency_code: "EUR", annual_salary_cents: 120_000_00, employee_code: "EMP-I002", work_email: "i2@salary.local")

      result = described_class.new(country_code: "us").overview

      expect(result).to include(country: "US", currency_code: "USD")
    end

    it "reports minimum, maximum, and total payroll cents for the scoped country" do
      create(:employee, country_code: "US", annual_salary_cents:  80_000_00, employee_code: "EMP-M001", work_email: "m1@salary.local")
      create(:employee, country_code: "US", annual_salary_cents: 150_000_00, employee_code: "EMP-M002", work_email: "m2@salary.local")
      create(:employee, country_code: "US", annual_salary_cents: 220_000_00, employee_code: "EMP-M003", work_email: "m3@salary.local")
      create(:employee, country_code: "DE", annual_salary_cents: 999_999_00, employee_code: "EMP-M004", work_email: "m4@salary.local")

      metrics = described_class.new(country_code: "US").overview[:metrics]

      expect(metrics).to include(
        minimum_salary_cents:  80_000_00,
        maximum_salary_cents: 220_000_00,
        total_payroll_cents:  450_000_00
      )
    end
  end
end
