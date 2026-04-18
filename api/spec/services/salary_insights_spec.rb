require "rails_helper"

RSpec.describe SalaryInsights do
  describe "#overview" do
    it "reports the requested country and its currency" do
      create(:employee, country_code: "US", currency_code: "USD", annual_salary_cents: 150_000_00, employee_code: "EMP-I001", work_email: "i1@salary.local")
      create(:employee, country_code: "DE", currency_code: "EUR", annual_salary_cents: 120_000_00, employee_code: "EMP-I002", work_email: "i2@salary.local")

      result = described_class.new(country_code: "us").overview

      expect(result).to include(country: "US", currency_code: "USD")
    end
  end
end
