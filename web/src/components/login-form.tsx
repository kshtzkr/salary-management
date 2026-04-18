"use client";

import { Alert, Box, Button, Card, CardContent, Stack, TextField, Typography } from "@mui/material";
import { useRouter } from "next/navigation";
import React, { FormEvent, useState, useTransition } from "react";

export function LoginForm() {
  const router = useRouter();
  const [email, setEmail] = useState("admin@salary.local");
  const [password, setPassword] = useState("Password123!");
  const [isPending, startTransition] = useTransition();

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    startTransition(async () => {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password })
      });

      if (!response.ok) {
        return;
      }

      router.push("/dashboard");
      router.refresh();
    });
  };

  return (
    <Card elevation={0} sx={{ maxWidth: 520, width: "100%", border: "1px solid rgba(15,118,110,0.15)" }}>
      <CardContent sx={{ p: 4 }}>
        <Stack spacing={3} component="form" onSubmit={handleSubmit}>
          <Box>
            <Typography variant="overline" color="secondary.main">
              Internal HR Console
            </Typography>
            <Typography variant="h4" sx={{ fontWeight: 700 }}>
              Salary command center
            </Typography>
          </Box>
          <TextField label="Email" value={email} onChange={(event) => setEmail(event.target.value)} type="email" required />
          <TextField label="Password" value={password} onChange={(event) => setPassword(event.target.value)} type="password" required />
          <Button type="submit" variant="contained" size="large" disabled={isPending}>
            {isPending ? "Signing in..." : "Sign in"}
          </Button>
        </Stack>
      </CardContent>
    </Card>
  );
}
