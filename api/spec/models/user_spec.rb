require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is invalid without an email" do
      user = User.new(email: nil)

      user.valid?

      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid when the email is already taken" do
      User.create!(email: "duplicate@salary.local", full_name: "Dup User", password: "Password123!", role: :viewer)
      user = User.new(email: "duplicate@salary.local", full_name: "Dup User", password: "Password123!", role: :viewer)

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
      user = User.create!(email: "keep@salary.local", full_name: "Keep", password: "Password123!", role: :viewer)

      user.full_name = "Keep Name"

      expect(user).to be_valid
    end

    it "is invalid without a role" do
      user = User.new(role: nil)

      user.valid?

      expect(user.errors[:role]).to include("can't be blank")
    end
  end

  describe "roles" do
    it "exposes the four allowed roles" do
      expect(User::ROLES.keys).to match_array(%i[admin hr_manager analyst viewer])
    end

    it "raises when assigned an unknown role" do
      expect { User.new(role: :ceo) }.to raise_error(ArgumentError)
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
      User.create!(email: "login@salary.local", full_name: "Login User", password: "Password123!", role: :viewer)
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
