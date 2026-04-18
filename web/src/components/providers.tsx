"use client";

import { CssBaseline, ThemeProvider, createTheme } from "@mui/material";
import { ReactNode } from "react";

const theme = createTheme({
  palette: {
    primary: {
      main: "#0f766e"
    },
    secondary: {
      main: "#d97706"
    },
    background: {
      default: "#f4efe6",
      paper: "#fffdfa"
    }
  },
  typography: {
    fontFamily: "var(--font-body)"
  },
  shape: {
    borderRadius: 18
  }
});

export function AppProviders({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {children}
    </ThemeProvider>
  );
}
