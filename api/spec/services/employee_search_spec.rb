require "rails_helper"

RSpec.describe EmployeeSearch do
  def search(params)
    described_class.new(scope: Employee.kept, params: ActionController::Parameters.new(params)).call
  end

  describe "sort + direction" do
    it "defaults to full_name ascending" do
      bert  = create(:employee, full_name: "Bert",  employee_code: "EMP-S001", work_email: "b@salary.local")
      alice = create(:employee, full_name: "Alice", employee_code: "EMP-S002", work_email: "a@salary.local")

      expect(search({})).to eq([alice, bert])
    end

    it "sorts by salary desc when asked" do
      low  = create(:employee, annual_salary_cents:  80_000_00, employee_code: "EMP-L001", work_email: "l@salary.local")
      high = create(:employee, annual_salary_cents: 200_000_00, employee_code: "EMP-L002", work_email: "h@salary.local")

      expect(search(sort: "annual_salary_cents", direction: "desc")).to eq([high, low])
    end

    it "ignores an unknown sort field and falls back to full_name" do
      bert  = create(:employee, full_name: "Bert",  employee_code: "EMP-U001", work_email: "b2@salary.local")
      alice = create(:employee, full_name: "Alice", employee_code: "EMP-U002", work_email: "a2@salary.local")

      expect(search(sort: "password_digest")).to eq([alice, bert])
    end
  end
end
