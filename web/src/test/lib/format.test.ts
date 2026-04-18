import { formatCurrency, titleize } from "@/lib/format";

describe("formatCurrency", () => {
  it("formats USD cents as a whole-dollar currency string", () => {
    expect(formatCurrency(150_000_00, "USD")).toBe("$150,000");
  });

  it("respects the requested currency code", () => {
    expect(formatCurrency(120_000_00, "EUR")).toMatch(/120,000/);
  });
});

describe("titleize", () => {
  it("replaces underscores with spaces and capitalises each word", () => {
    expect(titleize("leave_of_absence")).toBe("Leave Of Absence");
  });

  it("returns an empty string for null/undefined/empty input", () => {
    expect(titleize(null)).toBe("");
    expect(titleize(undefined)).toBe("");
    expect(titleize("")).toBe("");
  });
});
