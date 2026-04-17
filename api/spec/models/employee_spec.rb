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

    it "requires country_code to be exactly 2 characters" do
      employee = Employee.new(valid_attrs.merge(country_code: "USA"))

      employee.valid?

      expect(employee.errors[:country_code]).to include("is the wrong length (should be 2 characters)")
    end

    it "requires currency_code to be exactly 3 characters" do
      employee = Employee.new(valid_attrs.merge(currency_code: "DOLLAR"))

      employee.valid?

      expect(employee.errors[:currency_code]).to include("is the wrong length (should be 3 characters)")
    end
  end

  describe "normalization" do
    it "upper-cases country_code and currency_code, lower-cases work_email" do
      employee = Employee.new(country_code: "us", currency_code: "usd", work_email: "  Bob@SALARY.local  ")

      expect(employee.country_code).to eq("US")
      expect(employee.currency_code).to eq("USD")
      expect(employee.work_email).to eq("bob@salary.local")
    end
  end

  describe "employment_status enum" do
    it "exposes the four allowed statuses" do
      expect(Employee::EMPLOYMENT_STATUSES.keys).to match_array(%i[active probation leave_of_absence inactive])
    end

    it "raises when assigned an unknown status" do
      expect { Employee.new(employment_status: :sabbatical) }.to raise_error(ArgumentError)
    end

    it "defaults to :active" do
      employee = Employee.new(valid_attrs)

      expect(employee.employment_status).to eq("active")
    end
  end

  describe "soft-delete scopes" do
    it ".kept returns only employees with deleted_at NULL" do
      kept = Employee.create!(valid_attrs)
      Employee.create!(valid_attrs.merge(employee_code: "EMP-0002", work_email: "two@salary.local", deleted_at: 1.day.ago))

      expect(Employee.kept).to contain_exactly(kept)
    end

    it ".archived returns only employees with deleted_at set" do
      Employee.create!(valid_attrs)
      archived = Employee.create!(valid_attrs.merge(employee_code: "EMP-0002", work_email: "two@salary.local", deleted_at: 1.day.ago))

      expect(Employee.archived).to contain_exactly(archived)
    end
  end

  describe "soft-delete lifecycle" do
    it "#soft_delete! stamps deleted_at and reports archived?" do
      employee = Employee.create!(valid_attrs)

      employee.soft_delete!

      expect(employee.deleted_at).to be_present
      expect(employee).to be_archived
    end

    it "#restore! clears deleted_at" do
      employee = Employee.create!(valid_attrs.merge(deleted_at: 1.day.ago))

      employee.restore!

      expect(employee.deleted_at).to be_nil
      expect(employee).not_to be_archived
    end
  end
end
