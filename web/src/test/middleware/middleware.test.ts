import { NextRequest } from "next/server";

import { middleware } from "../../../middleware";
import { SESSION_COOKIE } from "@/lib/session";

function buildRequest(path: string, cookies: Record<string, string> = {}) {
  const request = new NextRequest(new URL(`http://localhost:3000${path}`));
  for (const [name, value] of Object.entries(cookies)) {
    request.cookies.set(name, value);
  }
  return request;
}

describe("middleware", () => {
  it("redirects unauthenticated visitors away from /dashboard", () => {
    const response = middleware(buildRequest("/dashboard"));
    expect(response.status).toBe(307);
    expect(response.headers.get("location")).toContain("/login");
  });

  it("redirects authenticated visitors away from /login", () => {
    const response = middleware(buildRequest("/login", { [SESSION_COOKIE]: "token" }));
    expect(response.status).toBe(307);
    expect(response.headers.get("location")).toContain("/dashboard");
  });

  it("allows authenticated visitors to reach /dashboard", () => {
    const response = middleware(buildRequest("/dashboard", { [SESSION_COOKIE]: "token" }));
    expect(response.headers.get("location")).toBeNull();
  });
});
