import { Box, Stack, Typography } from "@mui/material";

import { LoginForm } from "@/components/login-form";

export default function LoginPage() {
  return (
    <Box sx={{ minHeight: "100vh", display: "grid", placeItems: "center", p: 3 }}>
      <Stack direction={{ xs: "column", lg: "row" }} spacing={6} alignItems="center">
        <Stack spacing={2} sx={{ maxWidth: 480 }}>
          <Typography variant="overline" color="secondary.main">
            Minimal, usable, production-shaped
          </Typography>
          <Typography variant="h2" sx={{ fontFamily: "var(--font-display)", lineHeight: 1 }}>
            Salary clarity for a fast-moving HR team.
          </Typography>
          <Typography color="text.secondary">
            Review headcount, manage compensation records, and surface country-level payroll trends with just enough ceremony for a 10,000-employee organization.
          </Typography>
        </Stack>
        <LoginForm />
      </Stack>
    </Box>
  );
}
