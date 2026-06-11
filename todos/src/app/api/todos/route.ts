import { NextResponse } from "next/server";
import { listTodos } from "@/lib/db";

export const dynamic = "force-dynamic";

export async function GET() {
  const todos = await listTodos();
  return NextResponse.json({ todos });
}
