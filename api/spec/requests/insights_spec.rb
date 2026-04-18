require "rails_helper"

RSpec.describe "GET /api/v1/insights/overview", type: :request do
  it "returns the overview payload for an analyst" do
    analyst = create(:user, role: :analyst)
    create(:employee, country_code: "US", annual_salary_cents: 150_000_00)

    get "/api/v1/insights/overview", params: { country: "US" }, headers: auth_headers_for(analyst)

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body, symbolize_names: true)
    expect(body).to include(country: "US")
    expect(body[:metrics]).to include(:average_salary_cents, :median_salary_cents, :total_payroll_cents)
  end

  it "rejects a viewer with 403" do
    viewer = create(:user, role: :viewer)

    get "/api/v1/insights/overview", params: { country: "US" }, headers: auth_headers_for(viewer)

    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)).to include("error" => "You are not allowed to view salary insights")
  end

  it "returns 422 when country is missing" do
    analyst = create(:user, role: :analyst)

    get "/api/v1/insights/overview", headers: auth_headers_for(analyst)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)).to include("error" => "country is required")
  end
end
