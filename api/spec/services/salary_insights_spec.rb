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

    it "reports rounded average and median salary cents" do
      create(:employee, country_code: "US", annual_salary_cents: 100_000_00, employee_code: "EMP-A001", work_email: "a1@salary.local")
      create(:employee, country_code: "US", annual_salary_cents: 150_000_00, employee_code: "EMP-A002", work_email: "a2@salary.local")
      create(:employee, country_code: "US", annual_salary_cents: 200_000_00, employee_code: "EMP-A003", work_email: "a3@salary.local")
      create(:employee, country_code: "US", annual_salary_cents: 300_000_00, employee_code: "EMP-A004", work_email: "a4@salary.local")

      metrics = described_class.new(country_code: "US").overview[:metrics]

      expect(metrics).to include(
        average_salary_cents: 187_500_00,        # (100 + 150 + 200 + 300) / 4 * 100
        median_salary_cents: 175_000_00          # (150 + 200) / 2 * 100
      )
    end

    it "reports active_employee_count and employee_count_by_status with symbolised keys" do
      create(:employee, country_code: "US", employment_status: :active,            employee_code: "EMP-ST01", work_email: "s1@salary.local")
      create(:employee, country_code: "US", employment_status: :active,            employee_code: "EMP-ST02", work_email: "s2@salary.local")
      create(:employee, country_code: "US", employment_status: :probation,         employee_code: "EMP-ST03", work_email: "s3@salary.local")
      create(:employee, country_code: "US", employment_status: :leave_of_absence,  employee_code: "EMP-ST04", work_email: "s4@salary.local")

      metrics = described_class.new(country_code: "US").overview[:metrics]

      expect(metrics[:active_employee_count]).to eq(4)
      expect(metrics[:employee_count_by_status]).to eq(active: 2, probation: 1, leave_of_absence: 1)
    end
  end

  describe "#overview top_job_titles" do
    it "returns each job_title with count and rounded avg, sorted by count desc then title asc" do
      create(:employee, country_code: "US", job_title: "Engineer", annual_salary_cents: 100_000_00, employee_code: "EMP-T001", work_email: "t1@salary.local")
      create(:employee, country_code: "US", job_title: "Engineer", annual_salary_cents: 200_000_00, employee_code: "EMP-T002", work_email: "t2@salary.local")
      create(:employee, country_code: "US", job_title: "Designer", annual_salary_cents: 120_000_00, employee_code: "EMP-T003", work_email: "t3@salary.local")
      create(:employee, country_code: "US", job_title: "Product Manager", annual_salary_cents: 180_000_00, employee_code: "EMP-T004", work_email: "t4@salary.local")

      top = described_class.new(country_code: "US").overview[:top_job_titles]

      expect(top).to eq([
        { job_title: "Engineer",        average_salary_cents: 150_000_00, employee_count: 2 },
        { job_title: "Designer",        average_salary_cents: 120_000_00, employee_count: 1 },
        { job_title: "Product Manager", average_salary_cents: 180_000_00, employee_count: 1 }
      ])
    end
  end

  describe "#job_titles" do
    it "returns the full breakdown (not truncated to 10)" do
      12.times do |i|
        create(:employee, country_code: "US", job_title: "Role #{format('%02d', i)}", employee_code: "EMP-JT#{i.to_s.rjust(3, '0')}", work_email: "jt#{i}@salary.local")
      end

      result = described_class.new(country_code: "US").job_titles

      expect(result[:country]).to eq("US")
      expect(result[:job_titles].length).to eq(12)
    end
  end
end
