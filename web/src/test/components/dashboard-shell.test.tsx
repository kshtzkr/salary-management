import React from "react";
import { render, screen, waitFor } from "@testing-library/react";

import { DashboardShell } from "@/components/dashboard-shell";

const push = vi.fn();
const replace = vi.fn();
const refresh = vi.fn();

vi.mock("next/navigation", () => ({
  usePathname: () => "/dashboard",
  useRouter: () => ({ push, replace, refresh })
}));

function jsonResponse(body: unknown, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    json: () => Promise.resolve(body)
  };
}

describe("DashboardShell", () => {
  beforeEach(() => {
    push.mockClear();
    replace.mockClear();
    refresh.mockClear();
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("fetches the current user and renders their name", async () => {
    const fetchMock = vi.fn(() =>
      Promise.resolve(
        jsonResponse({ user: { id: 1, full_name: "Grace Hopper", email: "g@x", role: "admin", active: true, last_login_at: null } })
      )
    );
    vi.stubGlobal("fetch", fetchMock);

    render(
      <DashboardShell>
        <div>content</div>
      </DashboardShell>
    );

    await waitFor(() => expect(screen.getByText("Grace Hopper")).toBeInTheDocument());
    expect(fetchMock).toHaveBeenCalledWith("/api/auth/me", expect.any(Object));
  });

  it("gates the Users link to admins", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn(() =>
        Promise.resolve(
          jsonResponse({ user: { id: 2, full_name: "V Viewer", email: "v@x", role: "viewer", active: true, last_login_at: null } })
        )
      )
    );

    render(
      <DashboardShell>
        <div>content</div>
      </DashboardShell>
    );

    await waitFor(() => expect(screen.getByText("V Viewer")).toBeInTheDocument());
    expect(screen.queryByText("User access")).not.toBeInTheDocument();
  });

  it("redirects to /login when the session is invalid", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn(() => Promise.resolve({ ok: false, status: 401, json: () => Promise.resolve({ error: "Authentication required" }) }))
    );

    render(
      <DashboardShell>
        <div>content</div>
      </DashboardShell>
    );

    await waitFor(() => expect(replace).toHaveBeenCalledWith("/login"));
  });
});
