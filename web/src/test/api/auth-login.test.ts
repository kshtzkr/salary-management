import { NextRequest } from "next/server";

const cookieStore = {
  set: vi.fn(),
  delete: vi.fn(),
  get: vi.fn()
};

vi.mock("next/headers", () => ({
  cookies: () => cookieStore
}));

import { POST } from "@/app/api/auth/login/route";
import { SESSION_COOKIE } from "@/lib/session";

describe("POST /api/auth/login", () => {
  beforeEach(() => {
    cookieStore.set.mockClear();
    cookieStore.delete.mockClear();
    cookieStore.get.mockClear();
    vi.stubGlobal(
      "fetch",
      vi.fn(() =>
        Promise.resolve(
          new Response(
            JSON.stringify({ token: "signed.jwt.token", user: { id: 1, full_name: "Ada", email: "ada@x" } }),
            { status: 200, headers: { "Content-Type": "application/json" } }
          )
        )
      )
    );
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("proxies credentials to the backend and sets the session cookie", async () => {
    const request = new NextRequest(new URL("http://localhost:3000/api/auth/login"), {
      method: "POST",
      body: JSON.stringify({ email: "ada@x", password: "pw" })
    });

    const response = await POST(request);

    expect(response.status).toBe(200);
    expect(cookieStore.set).toHaveBeenCalledWith(
      SESSION_COOKIE,
      "signed.jwt.token",
      expect.objectContaining({ httpOnly: true, sameSite: "lax", path: "/" })
    );

    const body = await response.json();
    expect(body.user.full_name).toBe("Ada");
  });
});
