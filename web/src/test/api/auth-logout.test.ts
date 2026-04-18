const cookieStore = {
  set: vi.fn(),
  delete: vi.fn(),
  get: vi.fn()
};

vi.mock("next/headers", () => ({
  cookies: () => cookieStore
}));

import { POST } from "@/app/api/auth/logout/route";
import { SESSION_COOKIE } from "@/lib/session";

describe("POST /api/auth/logout", () => {
  beforeEach(() => {
    cookieStore.set.mockClear();
    cookieStore.delete.mockClear();
    cookieStore.get.mockClear();
  });

  it("deletes the session cookie and returns 200", async () => {
    const response = await POST();

    expect(response.status).toBe(200);
    expect(cookieStore.delete).toHaveBeenCalledWith(SESSION_COOKIE);
  });
});
