"use client";

import { Grid, MenuItem, Paper, Select, Stack, Typography } from "@mui/material";
import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { useEffect, useState } from "react";

import { useAuth } from "@/components/auth-context";
import { EmptyState } from "@/components/empty-state";
import { SectionHeader } from "@/components/section-header";
import { apiRequest } from "@/lib/api";
import { COUNTRIES } from "@/lib/constants";
import { formatCurrency, titleize } from "@/lib/format";

type OverviewResponse = {
  country: string;
  currency_code: string;
  metrics: {
    minimum_salary_cents: number;
    maximum_salary_cents: number;
    average_salary_cents: number;
    median_salary_cents: number;
    total_payroll_cents: number;
    active_employee_count: number;
    employee_count_by_status: Record<string, number>;
  };
  top_job_titles: Array<{ job_title: string; average_salary_cents: number; employee_count: number }>;
};

export function InsightsPage() {
  const user = useAuth();
  const canView = user?.role === "admin" || user?.role === "hr_manager" || user?.role === "analyst";
  const [country, setCountry] = useState("IN");
  const [overview, setOverview] = useState<OverviewResponse | null>(null);

  useEffect(() => {
    if (!canView) return;
    apiRequest<OverviewResponse>(`/api/backend/api/v1/insights/overview?country=${country}`).then(setOverview);
  }, [canView, country]);

  if (!canView) {
    return <EmptyState title="No insight access" description="Your role can browse employees, but salary analytics require analyst, HR manager, or admin access." />;
  }

  return (
    <Stack spacing={3}>
      <SectionHeader
        eyebrow="Insights"
        title="Country salary intelligence"
        description="Compare payroll ranges, median compensation, and job-title averages for a single country at a time."
        actions={
          <Select value={country} onChange={(event) => setCountry(event.target.value)} sx={{ minWidth: 220 }}>
            {COUNTRIES.map((item) => (
              <MenuItem key={item.code} value={item.code}>
                {item.label}
              </MenuItem>
            ))}
          </Select>
        }
      />

      {overview ? (
        <>
          <Grid container spacing={2}>
            {[
              ["Minimum salary", overview.metrics.minimum_salary_cents],
              ["Average salary", overview.metrics.average_salary_cents],
              ["Median salary", overview.metrics.median_salary_cents],
              ["Maximum salary", overview.metrics.maximum_salary_cents],
              ["Total payroll", overview.metrics.total_payroll_cents]
            ].map(([label, value]) => (
              <Grid item xs={12} sm={6} md={4} lg={2.4} key={label}>
                <Paper sx={{ p: 3, borderRadius: 4, height: "100%" }}>
                  <Typography color="text.secondary" noWrap>
                    {label}
                  </Typography>
                  <Typography
                    variant="h5"
                    sx={{
                      fontWeight: 700,
                      mt: 1,
                      whiteSpace: "nowrap",
                      overflow: "hidden",
                      textOverflow: "ellipsis"
                    }}
                    title={String(formatCurrency(Number(value), overview.currency_code))}
                  >
                    {formatCurrency(Number(value), overview.currency_code)}
                  </Typography>
                </Paper>
              </Grid>
            ))}
          </Grid>

          <Grid container spacing={3}>
            <Grid item xs={12} lg={8}>
              <Paper sx={{ p: 3, borderRadius: 4, height: 420 }}>
                <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>
                  Average salary by job title
                </Typography>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={overview.top_job_titles}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="job_title" tick={{ fontSize: 10 }} interval={0} angle={-35} textAnchor="end" height={100} />
                    <YAxis tickFormatter={(value) => `${Math.round(value / 100000) / 10}L`} />
                    <Tooltip formatter={(value: number) => formatCurrency(value, overview.currency_code)} />
                    <Bar dataKey="average_salary_cents" fill="#0f766e" radius={[8, 8, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </Paper>
            </Grid>
            <Grid item xs={12} lg={4}>
              <Paper sx={{ p: 3, borderRadius: 4, height: "100%" }}>
                <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>
                  Headcount by status
                </Typography>
                <Stack spacing={2}>
                  {Object.entries(overview.metrics.employee_count_by_status).map(([status, count]) => (
                    <Paper key={status} variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                      <Typography color="text.secondary">{titleize(status)}</Typography>
                      <Typography variant="h5" sx={{ fontWeight: 700 }}>
                        {count}
                      </Typography>
                    </Paper>
                  ))}
                  <Paper variant="outlined" sx={{ p: 2, borderRadius: 3 }}>
                    <Typography color="text.secondary">Active employees in scope</Typography>
                    <Typography variant="h5" sx={{ fontWeight: 700 }}>
                      {overview.metrics.active_employee_count}
                    </Typography>
                  </Paper>
                </Stack>
              </Paper>
            </Grid>
          </Grid>
        </>
      ) : null}
    </Stack>
  );
}
