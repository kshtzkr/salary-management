import { NextRequest } from "next/server";

const cookieStore = {
  set: vi.fn(),
  delete: vi.fn(),
  get: vi.fn()
};

vi.mock("next/headers", () => ({
  cookies: () => cookieStore
}));

import { GET, POST } from "@/app/api/backend/[...path]/route";

describe("proxy /api/backend/[...path]", () => {
  beforeEach(() => {
    cookieStore.get.mockReturnValue({ value: "jwt-token" });
  });

  afterEach(() => {
    vi.unstubAllGlobals();
    cookieStore.get.mockReset();
  });

  it("forwards GETs with the session token as Bearer", async () => {
    const fetchMock = vi.fn(() =>
      Promise.resolve(
        new Response(JSON.stringify({ ok: true }), {
          status: 200,
          headers: { "Content-Type": "application/json" }
        })
      )
    );
    vi.stubGlobal("fetch", fetchMock);

    const request = new NextRequest(new URL("http://localhost:3000/api/backend/api/v1/employees?page=2"));

    const response = await GET(request, { params: { path: ["api", "v1", "employees"] } });

    expect(response.status).toBe(200);
    const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toContain("/api/v1/employees");
    expect(url).toContain("page=2");

    const headers = new Headers(init.headers as HeadersInit);
    expect(headers.get("Authorization")).toBe("Bearer jwt-token");
  });

  it("forwards POST bodies without the cookie header", async () => {
    const fetchMock = vi.fn(() =>
      Promise.resolve(
        new Response(JSON.stringify({ id: 1 }), {
          status: 201,
          headers: { "Content-Type": "application/json" }
        })
      )
    );
    vi.stubGlobal("fetch", fetchMock);

    const request = new NextRequest(new URL("http://localhost:3000/api/backend/api/v1/employees"), {
      method: "POST",
      body: JSON.stringify({ employee_code: "E-1" })
    });

    const response = await POST(request, { params: { path: ["api", "v1", "employees"] } });

    expect(response.status).toBe(201);
    const [, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(typeof init.body).toBe("string");
    const headers = new Headers(init.headers as HeadersInit);
    expect(headers.get("cookie")).toBeNull();
  });
});
