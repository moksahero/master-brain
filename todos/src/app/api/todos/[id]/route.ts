import { NextRequest, NextResponse } from "next/server";
import { getTodo, updateTodo } from "@/lib/db";

export const dynamic = "force-dynamic";

export async function GET(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const todo = await getTodo(id);
  if (!todo) return NextResponse.json({ error: "not found" }, { status: 404 });
  return NextResponse.json({ todo });
}

export async function PATCH(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const body = (await req.json().catch(() => ({}))) as Record<string, unknown>;

  const fields: Record<string, string> = {};
  for (const key of ["status", "priority", "outcome", "title", "body", "due_date", "kind", "frequency"]) {
    if (typeof body[key] === "string") fields[key] = body[key] as string;
  }

  const todo = await updateTodo(id, fields);
  if (!todo) return NextResponse.json({ error: "not found" }, { status: 404 });
  return NextResponse.json({ todo });
}
