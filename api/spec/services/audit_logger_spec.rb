require "rails_helper"

RSpec.describe AuditLogger do
  describe ".log!" do
    it "creates an AuditLog with actor, action, subject, and changeset metadata" do
      actor    = create(:user, role: :hr_manager)
      employee = create(:employee)

      log = described_class.log!(
        actor: actor,
        action: "employee_updated",
        subject: employee,
        changeset: { "job_title" => ["Engineer", "Senior Engineer"] }
      )

      expect(log).to be_persisted
      expect(log).to have_attributes(
        actor: actor,
        action: "employee_updated",
        subject_type: "Employee",
        subject_id: employee.id,
        metadata: { "job_title" => ["Engineer", "Senior Engineer"] }
      )
    end

    it "defaults metadata to {} when no changeset is given" do
      actor    = create(:user, role: :hr_manager)
      employee = create(:employee)

      log = described_class.log!(actor: actor, action: "employee_archived", subject: employee)

      expect(log.metadata).to eq({})
    end
  end
end
