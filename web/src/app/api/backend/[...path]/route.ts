import { cookies } from "next/headers";
import { NextRequest, NextResponse } from "next/server";

import { SESSION_COOKIE } from "@/lib/session";

const API_BASE_URL = process.env.INTERNAL_API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3001";

async function proxy(request: NextRequest, path: string[]) {
  const token = cookies().get(SESSION_COOKIE)?.value;
  const url = new URL(`${API_BASE_URL}/${path.join("/")}`);
  url.search = new URL(request.url).search;

  const headers = new Headers(request.headers);
  headers.set("Accept", "application/json");
  headers.delete("host");
  headers.delete("cookie");
  headers.delete("content-length");

  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  const upstream = await fetch(url.toString(), {
    method: request.method,
    headers,
    body: ["GET", "HEAD"].includes(request.method) ? undefined : await request.text(),
    cache: "no-store"
  });

  if (upstream.status === 204) {
    return new NextResponse(null, { status: 204 });
  }

  const contentType = upstream.headers.get("content-type") || "application/json";
  const body = await upstream.text();

  return new NextResponse(body, {
    status: upstream.status,
    headers: {
      "Content-Type": contentType
    }
  });
}

export async function GET(request: NextRequest, { params }: { params: { path: string[] } }) {
  return proxy(request, params.path);
}

export async function POST(request: NextRequest, { params }: { params: { path: string[] } }) {
  return proxy(request, params.path);
}

export async function PATCH(request: NextRequest, { params }: { params: { path: string[] } }) {
  return proxy(request, params.path);
}

export async function DELETE(request: NextRequest, { params }: { params: { path: string[] } }) {
  return proxy(request, params.path);
}
