import { cookies } from "next/headers";
import { NextResponse } from "next/server";

import { apiRequest } from "@/lib/api";
import { SESSION_COOKIE } from "@/lib/session";

const API_BASE_URL = process.env.INTERNAL_API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3001";

export async function GET() {
  try {
    const token = cookies().get(SESSION_COOKIE)?.value;
    if (!token) {
      return NextResponse.json({ error: "Authentication required" }, { status: 401 });
    }

    const payload = await apiRequest<{ user: any }>(`${API_BASE_URL}/api/v1/auth/me`, {
      headers: { Authorization: `Bearer ${token}` }
    });

    return NextResponse.json(payload);
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Request failed" },
      { status: 500 }
    );
  }
}
