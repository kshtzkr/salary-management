"use client";

import DeleteOutlineRoundedIcon from "@mui/icons-material/DeleteOutlineRounded";
import EditRoundedIcon from "@mui/icons-material/EditRounded";
import RestoreRoundedIcon from "@mui/icons-material/RestoreRounded";
import VisibilityRoundedIcon from "@mui/icons-material/VisibilityRounded";
import {
  Alert,
  Button,
  Chip,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControl,
  Grid,
  InputLabel,
  MenuItem,
  Paper,
  Select,
  Stack,
  Switch,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TablePagination,
  TableRow,
  TextField,
  Typography
} from "@mui/material";
import { useCallback, useDeferredValue, useEffect, useMemo, useState, useTransition } from "react";

import { useAuth } from "@/components/auth-context";
import { EmptyState } from "@/components/empty-state";
import { SectionHeader } from "@/components/section-header";
import { apiRequest } from "@/lib/api";
import { COUNTRIES, DEPARTMENTS, EMPLOYMENT_STATUSES, JOB_TITLES } from "@/lib/constants";
import { formatCurrency, titleize } from "@/lib/format";
import type { Employee } from "@/types";

type EmployeeDraft = {
  employee_code: string;
  full_name: string;
  work_email: string;
  job_title: string;
  department: string;
  country_code: string;
  currency_code: string;
  annual_salary_cents: number;
  employment_status: string;
  hired_on: string;
};

const defaultEmployee: EmployeeDraft = {
  employee_code: "",
  full_name: "",
  work_email: "",
  job_title: JOB_TITLES[0],
  department: DEPARTMENTS[0],
  country_code: COUNTRIES[0].code,
  currency_code: COUNTRIES[0].currency,
  annual_salary_cents: 7_500_000,
  employment_status: "active",
  hired_on: new Date().toISOString().slice(0, 10)
};

export function EmployeesPage() {
  const user = useAuth();
  const canManage = user?.role === "admin" || user?.role === "hr_manager";
  const canRead = canManage || user?.role === "viewer";
  const [rows, setRows] = useState<Employee[]>([]);
  const [meta, setMeta] = useState({ page: 1, per_page: 10, total: 0, total_pages: 0 });
  const [query, setQuery] = useState("");
  const deferredQuery = useDeferredValue(query);
  const [country, setCountry] = useState("");
  const [department, setDepartment] = useState("");
  const [employmentStatus, setEmploymentStatus] = useState("");
  const [includeArchived, setIncludeArchived] = useState(false);
  const [sort] = useState("full_name");
  const [direction] = useState("asc");
  const [selected, setSelected] = useState<Employee | null>(null);
  const [editing, setEditing] = useState<EmployeeDraft | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();

  const queryString = useMemo(() => {
    const params = new URLSearchParams({
      page: String(meta.page),
      per_page: String(meta.per_page),
      sort,
      direction
    });

    if (deferredQuery) params.set("query", deferredQuery);
    if (country) params.set("country", country);
    if (department) params.set("department", department);
    if (employmentStatus) params.set("employment_status", employmentStatus);
    if (includeArchived) params.set("include_archived", "true");

    return params.toString();
  }, [country, deferredQuery, department, direction, employmentStatus, includeArchived, meta.page, meta.per_page, sort]);

  const loadEmployees = useCallback(() => {
    setError(null);
    startTransition(async () => {
      try {
        const payload = await apiRequest<{ employees: Employee[]; meta: typeof meta }>(`/api/backend/api/v1/employees?${queryString}`);
        setRows(payload.employees);
        setMeta(payload.meta);
      } catch (loadError) {
        setError(loadError instanceof Error ? loadError.message : "Unable to load employees");
      }
    });
  }, [queryString]);

  useEffect(() => {
    if (canRead) {
      loadEmployees();
    }
  }, [canRead, loadEmployees]);

  const handleDelete = async (employee: Employee) => {
    await apiRequest<void>(`/api/backend/api/v1/employees/${employee.id}`, { method: "DELETE" });
    loadEmployees();
  };

  const handleRestore = async (employee: Employee) => {
    await apiRequest(`/api/backend/api/v1/employees/${employee.id}/restore`, { method: "POST" });
    loadEmployees();
  };

  const handleSave = async () => {
    if (!editing) return;

    const payload = {
      ...editing,
      annual_salary_cents: Number(editing.annual_salary_cents)
    };

    if (selected) {
      await apiRequest(`/api/backend/api/v1/employees/${selected.id}`, {
        method: "PATCH",
        body: JSON.stringify({ employee: payload })
      });
    } else {
      await apiRequest("/api/backend/api/v1/employees", {
        method: "POST",
        body: JSON.stringify({ employee: payload })
      });
    }

    setEditing(null);
    setSelected(null);
    loadEmployees();
  };

  if (!canRead) {
    return <EmptyState title="No employee access" description="Your role can review insights only. Ask an administrator if you need employee directory access." />;
  }

  return (
    <Stack spacing={3}>
      <SectionHeader
        eyebrow="Employees"
        title="Directory and salary records"
        description="Search, filter, review, and maintain employee records with archived visibility for HR roles."
        actions={
          canManage ? (
            <Button variant="contained" onClick={() => { setSelected(null); setEditing(defaultEmployee); }}>
              Add employee
            </Button>
          ) : null
        }
      />

      {error ? <Alert severity="error">{error}</Alert> : null}

      <Paper sx={{ p: 3, borderRadius: 4 }}>
        <Grid container spacing={2}>
          <Grid item xs={12} md={4}>
            <TextField fullWidth label="Search by name, email, job title, department" value={query} onChange={(event) => setQuery(event.target.value)} />
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <FormControl fullWidth>
              <InputLabel>Country</InputLabel>
              <Select value={country} label="Country" onChange={(event) => setCountry(event.target.value)}>
                <MenuItem value="">All</MenuItem>
                {COUNTRIES.map((item) => <MenuItem value={item.code} key={item.code}>{item.label}</MenuItem>)}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <FormControl fullWidth>
              <InputLabel>Department</InputLabel>
              <Select value={department} label="Department" onChange={(event) => setDepartment(event.target.value)}>
                <MenuItem value="">All</MenuItem>
                {DEPARTMENTS.map((item) => <MenuItem value={item} key={item}>{item}</MenuItem>)}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <FormControl fullWidth>
              <InputLabel>Status</InputLabel>
              <Select value={employmentStatus} label="Status" onChange={(event) => setEmploymentStatus(event.target.value)}>
                <MenuItem value="">All</MenuItem>
                {EMPLOYMENT_STATUSES.map((item) => <MenuItem value={item} key={item}>{titleize(item)}</MenuItem>)}
              </Select>
            </FormControl>
          </Grid>
          <Grid item xs={6} sm={12} md={2} sx={{ display: "flex", alignItems: "center", justifyContent: { xs: "flex-start", sm: "flex-end", md: "center" } }}>
            <Stack direction="row" alignItems="center" spacing={1}>
              <Typography>Archived</Typography>
              <Switch disabled={!canManage} checked={includeArchived} onChange={(_, checked) => setIncludeArchived(checked)} />
            </Stack>
          </Grid>
        </Grid>
      </Paper>

      <Paper sx={{ borderRadius: 4, overflow: "hidden" }}>
        <TableContainer>
          <Table sx={{ minWidth: 800 }}>
            <TableHead>
              <TableRow>
                <TableCell>Employee</TableCell>
                <TableCell>Job title</TableCell>
                <TableCell>Country</TableCell>
                <TableCell>Salary</TableCell>
                <TableCell>Status</TableCell>
                <TableCell align="right">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {rows.map((employee) => (
                <TableRow hover key={employee.id}>
                  <TableCell>
                    <Typography fontWeight={700}>{employee.full_name}</Typography>
                    <Typography color="text.secondary">{employee.work_email}</Typography>
                  </TableCell>
                  <TableCell>
                    <Typography>{employee.job_title}</Typography>
                    <Typography color="text.secondary">{employee.department}</Typography>
                  </TableCell>
                  <TableCell>{employee.country_code}</TableCell>
                  <TableCell>{formatCurrency(employee.annual_salary_cents, employee.currency_code)}</TableCell>
                  <TableCell>
                    <Chip label={employee.archived ? "Archived" : titleize(employee.employment_status)} color={employee.archived ? "default" : "primary"} size="small" />
                  </TableCell>
                  <TableCell align="right">
                    <Stack direction="row" spacing={1} justifyContent="flex-end">
                      <Button size="small" startIcon={<VisibilityRoundedIcon />} onClick={() => setSelected(employee)}>
                        View
                      </Button>
                      {canManage && !employee.archived ? (
                        <>
                          <Button
                            size="small"
                            startIcon={<EditRoundedIcon />}
                            onClick={() => {
                              setSelected(employee);
                              setEditing({
                                employee_code: employee.employee_code,
                                full_name: employee.full_name,
                                work_email: employee.work_email,
                                job_title: employee.job_title,
                                department: employee.department,
                                country_code: employee.country_code,
                                currency_code: employee.currency_code,
                                annual_salary_cents: employee.annual_salary_cents,
                                employment_status: employee.employment_status,
                                hired_on: employee.hired_on
                              });
                            }}
                          >
                            Edit
                          </Button>
                          <Button size="small" color="error" startIcon={<DeleteOutlineRoundedIcon />} onClick={() => handleDelete(employee)}>
                            Archive
                          </Button>
                        </>
                      ) : null}
                      {canManage && employee.archived ? (
                        <Button size="small" startIcon={<RestoreRoundedIcon />} onClick={() => handleRestore(employee)}>
                          Restore
                        </Button>
                      ) : null}
                    </Stack>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        <TablePagination
          component="div"
          count={meta.total}
          page={Math.max(meta.page - 1, 0)}
          onPageChange={(_, nextPage) => setMeta((current) => ({ ...current, page: nextPage + 1 }))}
          rowsPerPage={meta.per_page}
          onRowsPerPageChange={(event) => setMeta((current) => ({ ...current, page: 1, per_page: Number(event.target.value) }))}
        />
      </Paper>

      {rows.length === 0 && !isPending ? (
        <EmptyState title="No employees found" description="Try widening the search or removing one of the active filters." />
      ) : null}

      <Dialog open={Boolean(selected) && !editing} onClose={() => setSelected(null)} maxWidth="sm" fullWidth>
        <DialogTitle>Employee profile</DialogTitle>
        <DialogContent dividers>
          {selected ? (
            <Stack spacing={1.5}>
              <Typography><strong>Code:</strong> {selected.employee_code}</Typography>
              <Typography><strong>Email:</strong> {selected.work_email}</Typography>
              <Typography><strong>Job title:</strong> {selected.job_title}</Typography>
              <Typography><strong>Department:</strong> {selected.department}</Typography>
              <Typography><strong>Country:</strong> {selected.country_code}</Typography>
              <Typography><strong>Status:</strong> {titleize(selected.employment_status)}</Typography>
              <Typography><strong>Annual salary:</strong> {formatCurrency(selected.annual_salary_cents, selected.currency_code)}</Typography>
              <Typography><strong>Hired on:</strong> {selected.hired_on}</Typography>
            </Stack>
          ) : null}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setSelected(null)}>Close</Button>
        </DialogActions>
      </Dialog>

      <Dialog open={Boolean(editing)} onClose={() => { setEditing(null); setSelected(null); }} maxWidth="md" fullWidth>
        <DialogTitle>{selected ? "Edit employee" : "Add employee"}</DialogTitle>
        <DialogContent dividers>
          {editing ? (
            <Grid container spacing={2} sx={{ mt: 0.5 }}>
              {(["employee_code", "full_name", "work_email"] as const).map((field) => (
                <Grid item xs={12} md={4} key={field}>
                  <TextField
                    fullWidth
                    label={titleize(field)}
                    value={editing[field]}
                    onChange={(event) => setEditing((current) => current ? { ...current, [field]: event.target.value } : current)}
                  />
                </Grid>
              ))}
              <Grid item xs={12} md={4}>
                <FormControl fullWidth>
                  <InputLabel>Job title</InputLabel>
                  <Select label="Job title" value={editing.job_title} onChange={(event) => setEditing((current) => current ? { ...current, job_title: event.target.value } : current)}>
                    {JOB_TITLES.map((item) => <MenuItem key={item} value={item}>{item}</MenuItem>)}
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12} md={4}>
                <FormControl fullWidth>
                  <InputLabel>Department</InputLabel>
                  <Select label="Department" value={editing.department} onChange={(event) => setEditing((current) => current ? { ...current, department: event.target.value } : current)}>
                    {DEPARTMENTS.map((item) => <MenuItem key={item} value={item}>{item}</MenuItem>)}
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12} md={4}>
                <FormControl fullWidth>
                  <InputLabel>Country</InputLabel>
                  <Select
                    label="Country"
                    value={editing.country_code}
                    onChange={(event) => {
                      const selectedCountry = COUNTRIES.find((item) => item.code === event.target.value)!;
                      setEditing((current) => current ? { ...current, country_code: selectedCountry.code, currency_code: selectedCountry.currency } : current);
                    }}
                  >
                    {COUNTRIES.map((item) => <MenuItem key={item.code} value={item.code}>{item.label}</MenuItem>)}
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  label="Annual salary (minor units)"
                  type="number"
                  value={editing.annual_salary_cents}
                  onChange={(event) => setEditing((current) => current ? { ...current, annual_salary_cents: Number(event.target.value) } : current)}
                />
              </Grid>
              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  label="Hired on"
                  type="date"
                  value={editing.hired_on}
                  onChange={(event) => setEditing((current) => current ? { ...current, hired_on: event.target.value } : current)}
                  InputLabelProps={{ shrink: true }}
                />
              </Grid>
              <Grid item xs={12} md={4}>
                <FormControl fullWidth>
                  <InputLabel>Status</InputLabel>
                  <Select label="Status" value={editing.employment_status} onChange={(event) => setEditing((current) => current ? { ...current, employment_status: event.target.value } : current)}>
                    {EMPLOYMENT_STATUSES.map((item) => <MenuItem key={item} value={item}>{titleize(item)}</MenuItem>)}
                  </Select>
                </FormControl>
              </Grid>
            </Grid>
          ) : null}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => { setEditing(null); setSelected(null); }}>Cancel</Button>
          <Button variant="contained" onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Stack>
  );
}
