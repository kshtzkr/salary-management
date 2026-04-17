require "rails_helper"

RSpec.describe "GET /api/v1/employees", type: :request do
  it "returns the kept employees serialized in an envelope" do
    viewer = create(:user, role: :viewer)
    alice  = create(:employee, full_name: "Alice", employee_code: "EMP-A001", work_email: "alice@salary.local")
    create(:employee, full_name: "Bob", employee_code: "EMP-A002", work_email: "bob@salary.local", deleted_at: 1.day.ago)

    get "/api/v1/employees", headers: auth_headers_for(viewer)

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body, symbolize_names: true)
    expect(body[:employees].map { |e| e[:id] }).to contain_exactly(alice.id)
    expect(body[:meta]).to include(page: 1, per_page: 25, total: 1, total_pages: 1)
  end
end
