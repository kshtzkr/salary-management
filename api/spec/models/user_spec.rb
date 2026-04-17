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
  end
end
