import React from "react";
import { render, screen } from "@testing-library/react";

import { AuthProvider, useAuth } from "@/components/auth-context";
import type { CurrentUser } from "@/types";

function Probe() {
  const user = useAuth();
  return <span data-testid="who">{user ? user.full_name : "anonymous"}</span>;
}

describe("AuthContext", () => {
  it("returns the user provided to AuthProvider", () => {
    const user: CurrentUser = {
      id: 1,
      full_name: "Ada Lovelace",
      email: "ada@example.com",
      role: "admin",
      active: true,
      last_login_at: null
    };

    render(
      <AuthProvider user={user}>
        <Probe />
      </AuthProvider>
    );

    expect(screen.getByTestId("who")).toHaveTextContent("Ada Lovelace");
  });

  it("returns null when no user is provided", () => {
    render(
      <AuthProvider user={null}>
        <Probe />
      </AuthProvider>
    );

    expect(screen.getByTestId("who")).toHaveTextContent("anonymous");
  });
});
