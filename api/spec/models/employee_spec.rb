require "rails_helper"

RSpec.describe Employee, type: :model do
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
  end
end
