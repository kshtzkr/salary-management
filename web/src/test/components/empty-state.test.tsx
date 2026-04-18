import React from "react";
import { render, screen } from "@testing-library/react";

import { EmptyState } from "@/components/empty-state";

describe("EmptyState", () => {
  it("renders a title and a description", () => {
    render(<EmptyState title="No records yet" description="Try another filter." />);

    expect(screen.getByText("No records yet")).toBeInTheDocument();
    expect(screen.getByText("Try another filter.")).toBeInTheDocument();
  });
});
