import { listTodos } from "@/lib/db";
import TodoBoard from "@/components/TodoBoard";

export const dynamic = "force-dynamic";

export default async function Home() {
  const todos = await listTodos();
  const open = todos.filter((t) => t.status !== "done").length;

  return (
    <main className="mx-auto max-w-3xl px-5 py-12">
      <header className="mb-10 border-b border-gold/30 pb-6">
        <p className="text-xs uppercase tracking-[0.3em] text-gold">NiTokyo Brain</p>
        <h1 className="mt-2 font-[family-name:var(--font-display)] text-4xl font-bold">
          Task Board
        </h1>
        <p className="mt-2 text-sm text-ink/60">
          {open} open · {todos.length} total · Master Brain writes here, you close them out.
        </p>
      </header>

      <TodoBoard initialTodos={todos} />
    </main>
  );
}
