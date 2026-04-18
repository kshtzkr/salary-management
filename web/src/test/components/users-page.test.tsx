import React from "react";
import { render, screen, waitFor } from "@testing-library/react";

import { AuthProvider } from "@/components/auth-context";
import { UsersPage } from "@/components/users-page";
import type { CurrentUser } from "@/types";

const admin: CurrentUser = {
  id: 1,
  full_name: "Admin",
  email: "a@x",
  role: "admin",
  active: true,
  last_login_at: null
};
const hrManager: CurrentUser = { ...admin, role: "hr_manager" };

function jsonResponse(body: unknown) {
  return { ok: true, status: 200, json: () => Promise.resolve(body) };
}

describe("UsersPage", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("loads users for admins and renders them in the table", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn(() =>
        Promise.resolve(
          jsonResponse({
            users: [
              { id: 1, full_name: "Admin", email: "a@x", role: "admin", active: true, last_login_at: null, created_at: "", updated_at: "" }
            ]
          })
        )
      )
    );

    render(
      <AuthProvider user={admin}>
        <UsersPage />
      </AuthProvider>
    );

    await waitFor(() => expect(screen.getByText("a@x")).toBeInTheDocument());
  });

  it("blocks non-admins with an EmptyState", () => {
    vi.stubGlobal("fetch", vi.fn());

    render(
      <AuthProvider user={hrManager}>
        <UsersPage />
      </AuthProvider>
    );

    expect(screen.getByText("No user-access controls")).toBeInTheDocument();
  });
});
