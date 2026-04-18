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
end
