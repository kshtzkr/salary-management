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

  it "rejects analysts who can't view the employee directory" do
    analyst = create(:user, role: :analyst)

    get "/api/v1/employees", headers: auth_headers_for(analyst)

    expect(response).to have_http_status(:forbidden)
    expect(JSON.parse(response.body)).to include("error" => "You are not allowed to view employees")
  end

  describe "filtering" do
    let(:viewer) { create(:user, role: :viewer) }

    it "filters by free-text query against name/email/title/department" do
      match = create(:employee, full_name: "Carla Backend", employee_code: "EMP-S001", work_email: "carla@salary.local")
      create(:employee, full_name: "Dan Frontend",  employee_code: "EMP-S002", work_email: "dan@salary.local")

      get "/api/v1/employees", params: { query: "backend" }, headers: auth_headers_for(viewer)

      expect(JSON.parse(response.body)["employees"].map { |e| e["id"] }).to contain_exactly(match.id)
    end

    it "filters by country code (case-insensitive)" do
      match = create(:employee, country_code: "DE", employee_code: "EMP-C001", work_email: "de@salary.local")
      create(:employee, country_code: "US", employee_code: "EMP-C002", work_email: "us@salary.local")

      get "/api/v1/employees", params: { country: "de" }, headers: auth_headers_for(viewer)

      expect(JSON.parse(response.body)["employees"].map { |e| e["id"] }).to contain_exactly(match.id)
    end

    it "filters by employment_status" do
      match = create(:employee, employment_status: :probation, employee_code: "EMP-P001", work_email: "p@salary.local")
      create(:employee, employment_status: :active, employee_code: "EMP-P002", work_email: "a@salary.local")

      get "/api/v1/employees", params: { employment_status: "probation" }, headers: auth_headers_for(viewer)

      expect(JSON.parse(response.body)["employees"].map { |e| e["id"] }).to contain_exactly(match.id)
    end

    it "include_archived=true unscopes the kept filter" do
      kept = create(:employee, employee_code: "EMP-K001", work_email: "k@salary.local")
      arch = create(:employee, employee_code: "EMP-K002", work_email: "g@salary.local", deleted_at: 1.day.ago)

      get "/api/v1/employees", params: { include_archived: "true" }, headers: auth_headers_for(viewer)

      expect(JSON.parse(response.body)["employees"].map { |e| e["id"] }).to contain_exactly(kept.id, arch.id)
    end
  end
end

RSpec.describe "GET /api/v1/employees/:id", type: :request do
  let(:viewer) { create(:user, role: :viewer) }

  it "returns the serialized employee" do
    employee = create(:employee, full_name: "Eve")

    get "/api/v1/employees/#{employee.id}", headers: auth_headers_for(viewer)

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body, symbolize_names: true)[:employee]).to include(id: employee.id, full_name: "Eve")
  end

  it "404s for an archived employee unless include_archived is requested" do
    employee = create(:employee, deleted_at: 1.day.ago)

    get "/api/v1/employees/#{employee.id}", headers: auth_headers_for(viewer)

    expect(response).to have_http_status(:not_found)
  end
end
