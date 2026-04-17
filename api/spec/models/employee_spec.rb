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
  end
end
