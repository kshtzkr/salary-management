require "rails_helper"

RSpec.describe Employee, type: :model do
  let(:valid_attrs) do
    {
      employee_code: "EMP-0001",
      full_name: "Alice",
      work_email: "alice@salary.local",
      job_title: "Engineer",
      department: "Engineering",
      country_code: "US",
      currency_code: "USD",
      annual_salary_cents: 100_000_00,
      hired_on: Date.new(2024, 1, 1)
    }
  end

  describe "validations" do
    it "is invalid without the required identity attributes" do
      employee = Employee.new

      employee.valid?

      %i[employee_code full_name work_email job_title department country_code currency_code hired_on].each do |attr|
        expect(employee.errors[attr]).to include("can't be blank"),
          "expected :#{attr} to require presence"
      end
    end

    it "is invalid when annual_salary_cents is missing, zero, negative, or non-integer" do
      [nil, 0, -1, 50_000.5].each do |bad|
        employee = Employee.new(annual_salary_cents: bad)

        employee.valid?

        expect(employee.errors[:annual_salary_cents]).not_to be_empty,
          "expected :annual_salary_cents to be invalid for #{bad.inspect}"
      end
    end

    it "rejects a duplicate employee_code" do
      Employee.create!(valid_attrs)
      duplicate = Employee.new(valid_attrs.merge(work_email: "another@salary.local"))

      duplicate.valid?

      expect(duplicate.errors[:employee_code]).to include("has already been taken")
    end

    it "rejects a duplicate work_email" do
      Employee.create!(valid_attrs)
      duplicate = Employee.new(valid_attrs.merge(employee_code: "EMP-0002"))

      duplicate.valid?

      expect(duplicate.errors[:work_email]).to include("has already been taken")
    end
  end
end
