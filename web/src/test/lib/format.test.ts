import { formatCurrency } from "@/lib/format";

describe("formatCurrency", () => {
  it("formats USD cents as a whole-dollar currency string", () => {
    expect(formatCurrency(150_000_00, "USD")).toBe("$150,000");
  });

  it("respects the requested currency code", () => {
    expect(formatCurrency(120_000_00, "EUR")).toMatch(/120,000/);
  });
});
