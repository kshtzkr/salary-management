"use client";

import { Button, Dialog, DialogActions, DialogContent, DialogTitle, Paper, Stack, Switch, Table, TableBody, TableCell, TableHead, TableRow, TextField, Typography } from "@mui/material";
import { useEffect, useState } from "react";

import { useAuth } from "@/components/auth-context";
import { EmptyState } from "@/components/empty-state";
import { SectionHeader } from "@/components/section-header";
import { apiRequest } from "@/lib/api";
import type { UserRecord } from "@/types";

const defaultUser = {
  full_name: "",
  email: "",
  role: "viewer",
  password: "Password123!",
  password_confirmation: "Password123!",
  active: true
};

export function UsersPage() {
  const user = useAuth();
  const canManage = user?.role === "admin";
  const [rows, setRows] = useState<UserRecord[]>([]);
  const [selected, setSelected] = useState<UserRecord | null>(null);
  const [draft, setDraft] = useState<typeof defaultUser | null>(null);

  const loadUsers = () => apiRequest<{ users: UserRecord[] }>("/api/backend/api/v1/users").then((payload) => setRows(payload.users));

  useEffect(() => {
    if (canManage) {
      loadUsers();
    }
  }, [canManage]);

  const handleSave = async () => {
    if (!draft) return;

    if (selected) {
      await apiRequest(`/api/backend/api/v1/users/${selected.id}`, {
        method: "PATCH",
        body: JSON.stringify({ user: draft })
      });
    } else {
      await apiRequest("/api/backend/api/v1/users", {
        method: "POST",
        body: JSON.stringify({ user: draft })
      });
    }

    setSelected(null);
    setDraft(null);
    loadUsers();
  };

  const deactivate = async (row: UserRecord) => {
    await apiRequest(`/api/backend/api/v1/users/${row.id}`, { method: "DELETE" });
    loadUsers();
  };

  if (!canManage) {
    return <EmptyState title="No user-access controls" description="Only administrators can manage application users and role assignments." />;
  }

  return (
    <Stack spacing={3}>
      <SectionHeader
        eyebrow="Access"
        title="User accounts and roles"
        description="Create evaluator accounts, change permissions, and deactivate access without removing history."
        actions={<Button variant="contained" onClick={() => { setSelected(null); setDraft(defaultUser); }}>Add user</Button>}
      />

      <Paper sx={{ borderRadius: 4, overflow: "hidden" }}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Role</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.map((row) => (
              <TableRow key={row.id}>
                <TableCell>{row.full_name}</TableCell>
                <TableCell>{row.email}</TableCell>
                <TableCell>{row.role?.replace("_", " ")}</TableCell>
                <TableCell>{row.active ? "Active" : "Inactive"}</TableCell>
                <TableCell align="right">
                  <Stack direction="row" spacing={1} justifyContent="flex-end">
                    <Button size="small" onClick={() => { setSelected(row); setDraft({ ...defaultUser, ...row, password: "", password_confirmation: "" }); }}>
                      Edit
                    </Button>
                    {row.active ? <Button size="small" color="error" onClick={() => deactivate(row)}>Deactivate</Button> : null}
                  </Stack>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Paper>

      <Dialog open={Boolean(draft)} onClose={() => { setSelected(null); setDraft(null); }} maxWidth="sm" fullWidth>
        <DialogTitle>{selected ? "Edit user" : "Add user"}</DialogTitle>
        <DialogContent dividers>
          {draft ? (
            <Stack spacing={2} sx={{ mt: 1 }}>
              <TextField label="Full name" value={draft.full_name} onChange={(event) => setDraft((current) => current ? { ...current, full_name: event.target.value } : current)} />
              <TextField label="Email" value={draft.email} onChange={(event) => setDraft((current) => current ? { ...current, email: event.target.value } : current)} />
              <TextField label="Role" value={draft.role} onChange={(event) => setDraft((current) => current ? { ...current, role: event.target.value } : current)} helperText="Use admin, hr_manager, analyst, or viewer." />
              <TextField label="Password" type="password" value={draft.password} onChange={(event) => setDraft((current) => current ? { ...current, password: event.target.value } : current)} />
              <TextField label="Confirm password" type="password" value={draft.password_confirmation} onChange={(event) => setDraft((current) => current ? { ...current, password_confirmation: event.target.value } : current)} />
              <Stack direction="row" alignItems="center" spacing={1}>
                <Typography>Active</Typography>
                <Switch checked={draft.active} onChange={(_, checked) => setDraft((current) => current ? { ...current, active: checked } : current)} />
              </Stack>
            </Stack>
          ) : null}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => { setSelected(null); setDraft(null); }}>Cancel</Button>
          <Button variant="contained" onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Stack>
  );
}
