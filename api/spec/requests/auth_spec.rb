require "rails_helper"

RSpec.describe "POST /api/v1/auth/login", type: :request do
  it "returns 200 with a token and the user payload for valid credentials" do
    user = create(:user, email: "alice@salary.local", password: "Password123!")

    post "/api/v1/auth/login", params: { email: "alice@salary.local", password: "Password123!" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["token"]).to be_present
    expect(body.dig("user", "email")).to eq(user.email)
  end
end
