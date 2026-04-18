require "rails_helper"

RSpec.describe AuditLog, type: :model do
  describe "validations" do
    it "requires action, subject_type, subject_id" do
      log = AuditLog.new

      log.valid?

      expect(log.errors[:action]).to include("can't be blank")
      expect(log.errors[:subject_type]).to include("can't be blank")
      expect(log.errors[:subject_id]).to include("can't be blank")
    end

    it "actor is optional (system-originated events)" do
      log = AuditLog.new(action: "seed_ran", subject_type: "System", subject_id: 0)

      expect(log.valid?).to be(true)
    end
  end
end
