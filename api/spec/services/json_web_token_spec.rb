require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode and .decode" do
    it "round-trips a payload" do
      token = JsonWebToken.encode(user_id: 42)

      payload = JsonWebToken.decode(token)

      expect(payload).to include("user_id" => 42)
    end

    it "raises DecodeError when the token is past its expiry" do
      token = JsonWebToken.encode({ user_id: 42 }, exp: 1.hour.ago)

      expect { JsonWebToken.decode(token) }.to raise_error(JsonWebToken::DecodeError)
    end

    it "raises DecodeError when the token is blank" do
      expect { JsonWebToken.decode("") }.to raise_error(JsonWebToken::DecodeError, /Missing token/)
    end
  end
end
