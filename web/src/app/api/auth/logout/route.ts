import { cookies } from "next/headers";
import { NextResponse } from "next/server";

import { SESSION_COOKIE } from "@/lib/session";

export async function POST() {
  cookies().delete(SESSION_COOKIE);
  return NextResponse.json({}, { status: 200 });
}
