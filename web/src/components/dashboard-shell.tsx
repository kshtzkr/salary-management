"use client";

import AssessmentRoundedIcon from "@mui/icons-material/AssessmentRounded";
import BadgeRoundedIcon from "@mui/icons-material/BadgeRounded";
import LogoutRoundedIcon from "@mui/icons-material/LogoutRounded";
import ManageAccountsRoundedIcon from "@mui/icons-material/ManageAccountsRounded";
import {
  AppBar,
  Avatar,
  Box,
  Button,
  CircularProgress,
  Divider,
  Drawer,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Stack,
  Toolbar,
  Typography
} from "@mui/material";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import React from "react";
import { ReactNode, useEffect, useMemo, useState } from "react";

import { apiRequest } from "@/lib/api";
import type { CurrentUser } from "@/types";

import { AuthProvider } from "./auth-context";

const drawerWidth = 280;

export function DashboardShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [user, setUser] = useState<CurrentUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let isMounted = true;

    apiRequest<{ user: CurrentUser }>("/api/auth/me")
      .then((payload) => {
        if (isMounted) {
          setUser(payload.user);
          setLoading(false);
        }
      })
      .catch(() => {
        if (isMounted) {
          router.replace("/login");
        }
      });

    return () => {
      isMounted = false;
    };
  }, [router]);

  const navItems = useMemo(() => {
    if (!user) {
      return [];
    }

    return [
      (user.role === "admin" || user.role === "hr_manager" || user.role === "viewer") && {
        href: "/dashboard/employees",
        label: "Employees",
        icon: <BadgeRoundedIcon />
      },
      (user.role === "admin" || user.role === "hr_manager" || user.role === "analyst") && {
        href: "/dashboard/insights",
        label: "Insights",
        icon: <AssessmentRoundedIcon />
      },
      user.role === "admin" && {
        href: "/dashboard/users",
        label: "User access",
        icon: <ManageAccountsRoundedIcon />
      }
    ].filter(Boolean) as Array<{ href: string; label: string; icon: ReactNode }>;
  }, [user]);

  const handleLogout = async () => {
    await fetch("/api/auth/logout", { method: "POST" });
    router.replace("/login");
    router.refresh();
  };

  if (loading) {
    return (
      <Box sx={{ display: "grid", placeItems: "center", minHeight: "100vh" }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <AuthProvider user={user}>
      <Box sx={{ display: "flex", minHeight: "100vh" }}>
        <Drawer
          variant="permanent"
          sx={{
            width: drawerWidth,
            flexShrink: 0,
            "& .MuiDrawer-paper": {
              width: drawerWidth,
              boxSizing: "border-box",
              background: "linear-gradient(180deg, rgba(15,118,110,0.96), rgba(15,23,42,0.94))",
              color: "white",
              borderRight: "none"
            }
          }}
        >
          <Toolbar sx={{ px: 3, py: 4, alignItems: "flex-start" }}>
            <Stack spacing={1}>
              <Typography variant="overline" sx={{ color: "rgba(255,255,255,0.72)" }}>
                Salary Management Tool
              </Typography>
              <Typography variant="h5" sx={{ fontWeight: 700 }}>
                HR Pulse
              </Typography>
              <Typography sx={{ color: "rgba(255,255,255,0.72)" }}>
                Employee operations and salary analytics for a 10k-person organization.
              </Typography>
            </Stack>
          </Toolbar>
          <Divider sx={{ borderColor: "rgba(255,255,255,0.12)" }} />
          <List sx={{ px: 2, py: 2 }}>
            {navItems.map((item) => (
              <ListItemButton
                component={Link}
                href={item.href}
                key={item.href}
                selected={pathname === item.href}
                sx={{
                  borderRadius: 3,
                  mb: 1,
                  color: "white",
                  "&.Mui-selected": { backgroundColor: "rgba(255,255,255,0.14)" }
                }}
              >
                <ListItemIcon sx={{ color: "inherit", minWidth: 40 }}>{item.icon}</ListItemIcon>
                <ListItemText primary={item.label} />
              </ListItemButton>
            ))}
          </List>
          <Box sx={{ mt: "auto", p: 3 }}>
            <Stack spacing={2}>
              {user ? (
                <Stack direction="row" spacing={2} alignItems="center">
                  <Avatar sx={{ bgcolor: "secondary.main" }}>{user.full_name?.charAt(0)}</Avatar>
                  <Box>
                    <Typography fontWeight={700}>{user.full_name}</Typography>
                    <Typography sx={{ color: "rgba(255,255,255,0.72)" }}>{user.role?.replace("_", " ")}</Typography>
                  </Box>
                </Stack>
              ) : null}
              <Button variant="outlined" startIcon={<LogoutRoundedIcon />} onClick={handleLogout} sx={{ color: "white", borderColor: "rgba(255,255,255,0.25)" }}>
                Sign out
              </Button>
            </Stack>
          </Box>
        </Drawer>
        <Box sx={{ flexGrow: 1 }}>
          <AppBar position="static" color="transparent" elevation={0} sx={{ borderBottom: "1px solid rgba(15,23,42,0.08)" }}>
            <Toolbar sx={{ justifyContent: "space-between" }}>
              <Box>
                <Typography variant="h5" sx={{ fontWeight: 700 }}>
                  Workforce overview
                </Typography>
                <Typography color="text.secondary">Role-aware workflows for HR operations and compensation analysis.</Typography>
              </Box>
            </Toolbar>
          </AppBar>
          <Box sx={{ p: 4 }}>{children}</Box>
        </Box>
      </Box>
    </AuthProvider>
  );
}
