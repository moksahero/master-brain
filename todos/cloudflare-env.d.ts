/// <reference types="@cloudflare/workers-types" />
// Cloudflare bindings available to the Worker / Next.js runtime.
// Regenerate with: npm run cf-typegen
interface CloudflareEnv {
  DB: D1Database;
  ASSETS: Fetcher;
}
