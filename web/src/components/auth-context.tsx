"use client";

import React, { createContext, useContext } from "react";

import type { CurrentUser } from "@/types";

const AuthContext = createContext<CurrentUser | null>(null);

export function AuthProvider({ user, children }: { user: CurrentUser | null; children: React.ReactNode }) {
  return <AuthContext.Provider value={user}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
