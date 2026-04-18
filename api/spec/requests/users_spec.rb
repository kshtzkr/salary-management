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
