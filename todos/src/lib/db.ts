import { getCloudflareContext } from "@opennextjs/cloudflare";

export type Status = "open" | "in_progress" | "done";

export type Todo = {
  id: string;
  title: string;
  brain: string | null;
  status: string;
  priority: string;
  body: string | null;
  outcome: string | null;
  source: string | null;
  kind: string; // 'routine' | 'one_time'
  frequency: string | null; // routine cadence: Nd | Nw | Nm (e.g. 1w, 2w, 1m); null for one_time
  due_date: string | null;
  created_at: string;
  updated_at: string;
  completed_at: string | null;
};

function db(): D1Database {
  return getCloudflareContext().env.DB;
}

export async function listTodos(): Promise<Todo[]> {
  const { results } = await db()
    .prepare(
      `SELECT * FROM todos
       ORDER BY
         CASE status WHEN 'open' THEN 0 WHEN 'in_progress' THEN 1 ELSE 2 END,
         CASE priority WHEN 'high' THEN 0 WHEN 'normal' THEN 1 WHEN 'low' THEN 2 ELSE 1 END,
         created_at DESC`
    )
    .all<Todo>();
  return results ?? [];
}

export async function updateTodo(
  id: string,
  fields: Partial<Pick<Todo, "status" | "priority" | "outcome" | "title" | "body" | "due_date" | "kind" | "frequency">>
): Promise<Todo | null> {
  const allowed = ["status", "priority", "outcome", "title", "body", "due_date", "kind", "frequency"] as const;
  const sets: string[] = [];
  const values: (string | null)[] = [];

  for (const key of allowed) {
    if (key in fields && fields[key] !== undefined) {
      sets.push(`${key} = ?`);
      values.push(fields[key] as string | null);
    }
  }
  if (sets.length === 0) return getTodo(id);

  sets.push(`updated_at = datetime('now')`);
  // Stamp completed_at when moving to done; clear it otherwise.
  if (fields.status === "done") {
    sets.push(`completed_at = datetime('now')`);
  } else if (fields.status) {
    sets.push(`completed_at = NULL`);
  }

  values.push(id);
  await db()
    .prepare(`UPDATE todos SET ${sets.join(", ")} WHERE id = ?`)
    .bind(...values)
    .run();
  return getTodo(id);
}

export async function getTodo(id: string): Promise<Todo | null> {
  return db().prepare(`SELECT * FROM todos WHERE id = ?`).bind(id).first<Todo>();
}
