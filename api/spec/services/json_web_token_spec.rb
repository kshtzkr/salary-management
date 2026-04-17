require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode and .decode" do
    it "round-trips a payload" do
      token = JsonWebToken.encode(user_id: 42)

      payload = JsonWebToken.decode(token)

      expect(payload).to include("user_id" => 42)
    end
  end
end
