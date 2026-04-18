import { apiRequest } from "@/lib/api";

describe("apiRequest", () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it("returns the parsed JSON body on 2xx responses", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => ({
      ok: true,
      status: 200,
      json: async () => ({ hello: "world" })
    })));

    const payload = await apiRequest<{ hello: string }>("/api/v1/anything");

    expect(payload).toEqual({ hello: "world" });
  });

  it("returns undefined for 204 No Content (no JSON body)", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => ({
      ok: true,
      status: 204,
      json: async () => { throw new Error("should not be called"); }
    })));

    const result = await apiRequest("/api/v1/employees/1");

    expect(result).toBeUndefined();
  });

  it("throws with the payload.error message on 4xx", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => ({
      ok: false,
      status: 422,
      json: async () => ({ error: "something is wrong" })
    })));

    await expect(apiRequest("/fail")).rejects.toThrow("something is wrong");
  });
});
