import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // This app lives inside a larger repo; pin the workspace root to this folder.
  turbopack: { root: import.meta.dirname },
};

export default nextConfig;

// Makes the Cloudflare bindings (DB, etc.) available during `next dev`.
import { initOpenNextCloudflareForDev } from "@opennextjs/cloudflare";
initOpenNextCloudflareForDev();
