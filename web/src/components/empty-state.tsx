"use client";

import { Paper, Stack, Typography } from "@mui/material";

export function EmptyState({ title, description }: { title: string; description: string }) {
  return (
    <Paper sx={{ p: 4, borderRadius: 4, textAlign: "center" }}>
      <Stack spacing={1}>
        <Typography variant="h6" sx={{ fontWeight: 700 }}>
          {title}
        </Typography>
        <Typography color="text.secondary">{description}</Typography>
      </Stack>
    </Paper>
  );
}
