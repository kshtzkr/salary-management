require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is invalid without an email" do
      user = User.new(email: nil)

      user.valid?

      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid when the email is already taken" do
      User.create!(email: "duplicate@salary.local")
      user = User.new(email: "duplicate@salary.local")

      user.valid?

      expect(user.errors[:email]).to include("has already been taken")
    end

    it "is invalid when the email is malformed" do
      user = User.new(email: "not-an-email")

      user.valid?

      expect(user.errors[:email]).to include("is invalid")
    end
  end

  describe "normalization" do
    it "lower-cases and strips the email before saving" do
      user = User.new(email: "  Mixed@Case.LOCAL  ")

      expect(user.email).to eq("mixed@case.local")
    end
  end
end
