require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is invalid without an email" do
      user = User.new(email: nil)

      user.valid?

      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid when the email is already taken" do
      User.create!(email: "duplicate@salary.local", full_name: "Dup User", password: "Password123!")
      user = User.new(email: "duplicate@salary.local", full_name: "Dup User", password: "Password123!")

      user.valid?

      expect(user.errors[:email]).to include("has already been taken")
    end

    it "is invalid when the email is malformed" do
      user = User.new(email: "not-an-email")

      user.valid?

      expect(user.errors[:email]).to include("is invalid")
    end

    it "is invalid without a full name" do
      user = User.new(full_name: nil)

      user.valid?

      expect(user.errors[:full_name]).to include("can't be blank")
    end

    it "is invalid when the password is shorter than 10 characters" do
      user = User.new(password: "short")

      user.valid?

      expect(user.errors[:password]).to include("is too short (minimum is 10 characters)")
    end

    it "allows password to be omitted on update (nil-tolerant)" do
      user = User.create!(email: "keep@salary.local", full_name: "Keep", password: "Password123!")

      user.full_name = "Keep Name"

      expect(user).to be_valid
    end
  end

  describe "normalization" do
    it "lower-cases and strips the email before saving" do
      user = User.new(email: "  Mixed@Case.LOCAL  ")

      expect(user.email).to eq("mixed@case.local")
    end
  end

  describe "#authenticate" do
    let(:user) do
      User.create!(email: "login@salary.local", full_name: "Login User", password: "Password123!")
    end

    it "stores the password as a bcrypt digest, not plaintext" do
      expect(user.password_digest).not_to eq("Password123!")
      expect(user.password_digest).to start_with("$2a$")
    end

    it "returns the user when given the correct password" do
      expect(user.authenticate("Password123!")).to eq(user)
    end

    it "returns false when given the wrong password" do
      expect(user.authenticate("nope")).to eq(false)
    end
  end
end
