import React from "react";
import { render, screen, waitFor } from "@testing-library/react";

import { AuthProvider } from "@/components/auth-context";
import { EmployeesPage } from "@/components/employees-page";
import type { CurrentUser } from "@/types";

const admin: CurrentUser = {
  id: 1,
  full_name: "Admin",
  email: "a@x",
  role: "admin",
  active: true,
  last_login_at: null
};

const viewer: CurrentUser = { ...admin, id: 2, role: "viewer" };
const analyst: CurrentUser = { ...admin, id: 3, role: "analyst" };

const employeesPayload = {
  employees: [
    {
      id: 10,
      employee_code: "E-001",
      full_name: "Ada Lovelace",
      work_email: "ada@example.com",
      job_title: "Software Engineer",
      department: "Engineering",
      country_code: "IN",
      currency_code: "INR",
      annual_salary_cents: 12_000_000,
      employment_status: "active",
      hired_on: "2020-01-15",
      archived: false
    }
  ],
  meta: { page: 1, per_page: 10, total: 1, total_pages: 1 }
};

function jsonResponse(body: unknown, status = 200) {
  return { ok: status >= 200 && status < 300, status, json: () => Promise.resolve(body) };
}

describe("EmployeesPage", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("loads employees for roles that can read and renders them", async () => {
    vi.stubGlobal("fetch", vi.fn(() => Promise.resolve(jsonResponse(employeesPayload))));

    render(
      <AuthProvider user={admin}>
        <EmployeesPage />
      </AuthProvider>
    );

    await waitFor(() => expect(screen.getByText("Ada Lovelace")).toBeInTheDocument());
    expect(screen.getByText("ada@example.com")).toBeInTheDocument();
  });

  it("blocks roles that cannot read with an EmptyState", () => {
    vi.stubGlobal("fetch", vi.fn());

    render(
      <AuthProvider user={analyst}>
        <EmployeesPage />
      </AuthProvider>
    );

    expect(screen.getByText("No employee access")).toBeInTheDocument();
  });

  it("hides the Add employee CTA for viewers", async () => {
    vi.stubGlobal("fetch", vi.fn(() => Promise.resolve(jsonResponse(employeesPayload))));

    render(
      <AuthProvider user={viewer}>
        <EmployeesPage />
      </AuthProvider>
    );

    await waitFor(() => expect(screen.getByText("Ada Lovelace")).toBeInTheDocument());
    expect(screen.queryByRole("button", { name: /add employee/i })).not.toBeInTheDocument();
  });
});
