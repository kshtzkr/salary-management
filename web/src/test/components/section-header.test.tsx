import React from "react";
import { render, screen } from "@testing-library/react";

import { SectionHeader } from "@/components/section-header";

describe("SectionHeader", () => {
  it("renders the eyebrow, title, description and optional actions", () => {
    render(
      <SectionHeader
        eyebrow="Employees"
        title="Workforce"
        description="Manage the roster"
        actions={<button>Add employee</button>}
      />
    );

    expect(screen.getByText("Employees")).toBeInTheDocument();
    expect(screen.getByRole("heading", { name: "Workforce" })).toBeInTheDocument();
    expect(screen.getByText("Manage the roster")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Add employee" })).toBeInTheDocument();
  });
});
