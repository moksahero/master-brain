"use client";

import { useState } from "react";
import type { Todo } from "@/lib/db";

const STATUS_LABEL: Record<string, string> = {
  open: "Open",
  in_progress: "In progress",
  done: "Done",
};
const STATUS_CYCLE = ["open", "in_progress", "done"];

const PRIORITY_STYLE: Record<string, string> = {
  high: "bg-red-100 text-red-700",
  normal: "bg-gold-soft/50 text-ink/70",
  low: "bg-stone-100 text-stone-500",
};

const todayStr = new Date().toISOString().slice(0, 10);

// Cadence shorthand (Nd|Nw|Nm) → friendly label, e.g. "1m" → "every 1mo", "3w" → "every 3wk".
const FREQ_UNIT: Record<string, string> = { d: "d", w: "wk", m: "mo" };
function freqLabel(freq?: string | null): string {
  if (!freq) return "";
  const m = /^(\d+)([dwm])$/.exec(freq.trim());
  return m ? `every ${m[1]}${FREQ_UNIT[m[2]] ?? m[2]}` : `every ${freq}`;
}

// Routine bodies often start with a redundant "Recurring (every 1m)." — the badge says this now.
function stripRecurringPrefix(body?: string | null): string {
  return (body ?? "").replace(/^\s*Recurring\s*\([^)]*\)\.?\s*/i, "");
}

export default function TodoBoard({ initialTodos }: { initialTodos: Todo[] }) {
  const [todos, setTodos] = useState<Todo[]>(initialTodos);
  const [busy, setBusy] = useState<string | null>(null);
  const [tab, setTab] = useState<"one_time" | "routine" | "done">(() => {
    const open = initialTodos.filter((t) => t.status !== "done");
    if (open.some((t) => t.kind !== "routine")) return "one_time";
    if (open.some((t) => t.kind === "routine")) return "routine";
    return "one_time";
  });

  async function patch(id: string, fields: Partial<Todo>) {
    setBusy(id);
    // optimistic update
    setTodos((prev) => prev.map((t) => (t.id === id ? { ...t, ...fields } : t)));
    try {
      const res = await fetch(`/api/todos/${id}`, {
        method: "PATCH",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(fields),
      });
      const data = (await res.json()) as { todo?: Todo };
      if (data.todo) setTodos((prev) => prev.map((t) => (t.id === id ? data.todo! : t)));
    } finally {
      setBusy(null);
    }
  }

  function cycleStatus(t: Todo) {
    const idx = STATUS_CYCLE.indexOf(t.status);
    const next = STATUS_CYCLE[(idx + 1) % STATUS_CYCLE.length];
    patch(t.id, { status: next });
  }

  const isRoutine = (t: Todo) => t.kind === "routine";
  const oneTimeCount = todos.filter((t) => t.status !== "done" && !isRoutine(t)).length;
  const routineCount = todos.filter((t) => t.status !== "done" && isRoutine(t)).length;
  const doneCount = todos.filter((t) => t.status === "done").length;
  const visible = todos.filter((t) =>
    tab === "done"
      ? t.status === "done"
      : tab === "routine"
        ? t.status !== "done" && isRoutine(t)
        : t.status !== "done" && !isRoutine(t)
  );

  const tabs = [
    ["one_time", "One Time", oneTimeCount],
    ["routine", "Routine", routineCount],
    ["done", "Done", doneCount],
  ] as const;

  return (
    <div>
      <nav className="mb-5 flex gap-1 border-b border-ink/10">
        {tabs.map(([key, label, count]) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`-mb-px flex items-center gap-1.5 border-b-2 px-4 py-2 text-sm font-medium transition ${
              tab === key
                ? "border-gold text-ink"
                : "border-transparent text-ink/40 hover:text-ink/70"
            }`}
          >
            {label}
            <span
              className={`rounded-full px-1.5 py-0.5 text-xs ${
                tab === key ? "bg-gold/15 text-gold" : "bg-ink/5 text-ink/40"
              }`}
            >
              {count}
            </span>
          </button>
        ))}
      </nav>

      {visible.length === 0 ? (
        <p className="rounded-lg border border-dashed border-gold/40 p-8 text-center text-sm text-ink/50">
          {tab === "done"
            ? "Nothing completed yet."
            : tab === "routine"
              ? "No routine tasks scheduled. Add cadences in todos/routines.yml."
              : "No one-time tasks — all clear."}
        </p>
      ) : (
        <ul className="space-y-3">
          {visible.map((t) => (
        <li
          key={t.id}
          className={`rounded-xl border border-ink/10 bg-white p-4 shadow-sm transition ${
            t.status === "done" ? "opacity-60" : ""
          } ${busy === t.id ? "animate-pulse" : ""}`}
        >
          <div className="flex items-start gap-3">
            <button
              onClick={() => cycleStatus(t)}
              title="Click to advance status"
              className={`mt-0.5 shrink-0 rounded-full border px-3 py-1 text-xs font-medium ${
                t.status === "done"
                  ? "border-green-300 bg-green-50 text-green-700"
                  : t.status === "in_progress"
                    ? "border-gold bg-gold/10 text-gold"
                    : "border-ink/20 text-ink/60"
              }`}
            >
              {STATUS_LABEL[t.status] ?? t.status}
            </button>

            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2">
                <h3
                  className={`truncate font-medium ${
                    t.status === "done" ? "line-through" : ""
                  }`}
                >
                  {t.title}
                </h3>
              </div>

              <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-ink/50">
                {t.brain && (
                  <span className="rounded bg-ink/5 px-1.5 py-0.5 font-mono">{t.brain}</span>
                )}
                {isRoutine(t) && (
                  <span
                    className="rounded bg-gold/10 px-1.5 py-0.5 text-gold"
                    title={`Routine (${(t.source ?? "").replace("routine:", "")})`}
                  >
                    🔁 {t.frequency ? freqLabel(t.frequency) : "routine"}
                  </span>
                )}
                <select
                  value={["high", "normal", "low"].includes(t.priority) ? t.priority : "normal"}
                  onChange={(e) => patch(t.id, { priority: e.target.value })}
                  className={`rounded px-1.5 py-0.5 text-xs ${
                    PRIORITY_STYLE[t.priority] ?? PRIORITY_STYLE.normal
                  }`}
                >
                  <option value="high">high</option>
                  <option value="normal">normal</option>
                  <option value="low">low</option>
                </select>
                <span className="text-ink/40">Created {t.created_at?.slice(0, 10)}</span>
                <label className="flex items-center gap-1 text-ink/40">
                  Due
                  <input
                    type="date"
                    value={t.due_date?.slice(0, 10) ?? ""}
                    onChange={(e) => patch(t.id, { due_date: e.target.value })}
                    className="rounded border border-ink/15 px-1 py-0.5 text-xs outline-none focus:border-gold"
                  />
                </label>
                {t.due_date && t.status !== "done" && t.due_date.slice(0, 10) < todayStr && (
                  <span className="rounded bg-red-100 px-1.5 py-0.5 text-red-700">overdue</span>
                )}
              </div>

              {(() => {
                const body = isRoutine(t) ? stripRecurringPrefix(t.body) : t.body ?? "";
                return body ? (
                  <p className="mt-2 whitespace-pre-wrap text-sm text-ink/70">{body}</p>
                ) : null;
              })()}

              <details className="mt-2">
                <summary className="cursor-pointer text-xs text-gold">
                  {t.outcome ? "Edit outcome" : "Add outcome"}
                </summary>
                <textarea
                  defaultValue={t.outcome ?? ""}
                  placeholder="What happened when this was closed out…"
                  onBlur={(e) => {
                    if (e.target.value !== (t.outcome ?? "")) patch(t.id, { outcome: e.target.value });
                  }}
                  className="mt-2 w-full rounded-lg border border-ink/15 p-2 text-sm outline-none focus:border-gold"
                  rows={2}
                />
              </details>
            </div>
          </div>
        </li>
          ))}
        </ul>
      )}
    </div>
  );
}
