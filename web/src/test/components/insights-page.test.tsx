import React from "react";
import { render, screen, waitFor } from "@testing-library/react";

import { AuthProvider } from "@/components/auth-context";
import { InsightsPage } from "@/components/insights-page";
import type { CurrentUser } from "@/types";

const analyst: CurrentUser = {
  id: 1,
  full_name: "Ada",
  email: "a@x",
  role: "analyst",
  active: true,
  last_login_at: null
};
const viewer: CurrentUser = { ...analyst, role: "viewer" };

const overviewPayload = {
  country: "IN",
  currency_code: "INR",
  metrics: {
    minimum_salary_cents: 5_000_000,
    maximum_salary_cents: 50_000_000,
    average_salary_cents: 20_000_000,
    median_salary_cents: 18_000_000,
    total_payroll_cents: 2_000_000_000,
    active_employee_count: 100,
    employee_count_by_status: { active: 90, probation: 10 }
  },
  top_job_titles: []
};

function jsonResponse(body: unknown) {
  return { ok: true, status: 200, json: () => Promise.resolve(body) };
}

describe("InsightsPage", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("fetches the overview for analysts and renders currency metrics", async () => {
    const fetchMock = vi.fn(() => Promise.resolve(jsonResponse(overviewPayload)));
    vi.stubGlobal("fetch", fetchMock);

    render(
      <AuthProvider user={analyst}>
        <InsightsPage />
      </AuthProvider>
    );

    await waitFor(() => expect(screen.getByText("Average salary")).toBeInTheDocument());
    expect(fetchMock).toHaveBeenCalledWith(
      expect.stringContaining("/api/backend/api/v1/insights/overview?country=IN"),
      expect.any(Object)
    );
  });

  it("blocks viewers with an EmptyState", () => {
    vi.stubGlobal("fetch", vi.fn());

    render(
      <AuthProvider user={viewer}>
        <InsightsPage />
      </AuthProvider>
    );

    expect(screen.getByText("No insight access")).toBeInTheDocument();
  });
});
