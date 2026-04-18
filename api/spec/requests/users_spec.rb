require "rails_helper"

RSpec.describe "GET /api/v1/users", type: :request do
  it "returns users ordered by full_name for an admin" do
    admin = create(:user, role: :admin, full_name: "Zoe Admin", email: "zoe@salary.local")
    bob   = create(:user, role: :viewer, full_name: "Bob", email: "bob@salary.local")

    get "/api/v1/users", headers: auth_headers_for(admin)

    expect(response).to have_http_status(:ok)
    ids = JSON.parse(response.body, symbolize_names: true)[:users].map { |u| u[:id] }
    expect(ids).to eq([bob.id, admin.id])
  end

  it "rejects a non-admin caller with 403" do
    viewer = create(:user, role: :viewer)

    get "/api/v1/users", headers: auth_headers_for(viewer)

    expect(response).to have_http_status(:forbidden)
  end
end

RSpec.describe "POST /api/v1/users", type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:valid_payload) do
    {
      user: {
        full_name: "New Person",
        email: "new@salary.local",
        role: "viewer",
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    }
  end

  it "creates a user" do
    expect {
      post "/api/v1/users", params: valid_payload, headers: auth_headers_for(admin)
    }.to change(User, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body, symbolize_names: true)[:user]).to include(email: "new@salary.local", role: "viewer")
  end

  it "returns 422 with model errors on invalid payload" do
    post "/api/v1/users",
         params: { user: valid_payload[:user].merge(email: "not-an-email") },
         headers: auth_headers_for(admin)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)["details"]).to include(match(/Email/i))
  end
end
