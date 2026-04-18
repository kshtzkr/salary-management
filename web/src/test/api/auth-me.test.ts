const cookieStore = {
  set: vi.fn(),
  delete: vi.fn(),
  get: vi.fn()
};

vi.mock("next/headers", () => ({
  cookies: () => cookieStore
}));

import { GET } from "@/app/api/auth/me/route";

describe("GET /api/auth/me", () => {
  beforeEach(() => {
    cookieStore.get.mockReset();
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("returns 401 when no session cookie is present", async () => {
    cookieStore.get.mockReturnValue(undefined);

    const response = await GET();

    expect(response.status).toBe(401);
    const body = await response.json();
    expect(body.error).toMatch(/auth/i);
  });

  it("forwards the bearer token and returns the user payload", async () => {
    cookieStore.get.mockReturnValue({ value: "jwt-token" });
    const fetchMock = vi.fn(() =>
      Promise.resolve(
        new Response(JSON.stringify({ user: { id: 42, full_name: "Grace" } }), {
          status: 200,
          headers: { "Content-Type": "application/json" }
        })
      )
    );
    vi.stubGlobal("fetch", fetchMock);

    const response = await GET();

    expect(response.status).toBe(200);
    const body = await response.json();
    expect(body.user.full_name).toBe("Grace");

    const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    const headers = new Headers(init.headers as HeadersInit);
    expect(headers.get("Authorization")).toBe("Bearer jwt-token");
  });
});
