import { cookies } from "next/headers";
import { NextRequest, NextResponse } from "next/server";

import { apiRequest } from "@/lib/api";
import { SESSION_COOKIE } from "@/lib/session";

const API_BASE_URL = process.env.INTERNAL_API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3001";

export async function POST(request: NextRequest) {
  try {
    const payload = await apiRequest<{ token: string; user: any }>(`${API_BASE_URL}/api/v1/auth/login`, {
      method: "POST",
      body: await request.text()
    });

    cookies().set(SESSION_COOKIE, payload.token, {
      httpOnly: true,
      sameSite: "lax",
      secure: process.env.NODE_ENV === "production",
      maxAge: 60 * 60 * 24,
      path: "/"
    });

    return NextResponse.json({ user: payload.user });
  } catch (error) {
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "Login failed" },
      { status: 500 }
    );
  }
}
