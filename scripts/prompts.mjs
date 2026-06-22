#!/usr/bin/env node
// master-brain :: parse the captured Prompt Library into a queryable catalog of
// runnable prompts, so routing can hand back the blessed prompt for a skill —
// not a guess. Source: classroom/09-prompt-library/*.md.
//
// Usage:
//   node prompts.mjs list                 # every skill bucket + prompt count
//   node prompts.mjs skill <key>          # list the prompts in one bucket
//   node prompts.mjs get <key> [index]    # print prompt(s), ready to fill + run
//   node prompts.mjs search <query>       # match across label / command / body
// Add --json to list/skill/search for machine output.
//
// <key> is fuzzy: "ads", "local", "research"/"marketing", "video", "client",
// "install" all resolve to the right bucket.

import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.env.CLAUDE_PLUGIN_ROOT
  || path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const DIR = path.join(ROOT, 'classroom', '09-prompt-library'); // captured library
const SUPP = path.join(ROOT, 'prompts');                       // repo-owned supplements (e.g. mb commands)

// The universal "three context lines" the library tells you to prepend.
const CONTEXT_HEADER = [
  'Business: <what you sell and to whom>',
  'Goal: <the one outcome you want>',
  'Voice: <how it should sound, e.g. plain, expert, friendly>',
].join('\n');

const ALIASES = {
  paid: 'ads', 'paid-ads': 'ads', ppc: 'ads',
  marketing: 'research-brain', 'marketing-brain': 'research-brain', research: 'research-brain',
  walt: 'video-content', video: 'video-content',
  gbp: 'local-seo', maps: 'local-seo', local: 'local-seo',
  client: 'client-agency', agency: 'client-agency',
  'master-brain': 'mb', commands: 'mb', 'mb-commands': 'mb',
  install: 'install-by-prompt-first-run-playbooks', 'first-run': 'install-by-prompt-first-run-playbooks',
  strategy: 'ai-strategy-research-tools', 'ai-strategy': 'ai-strategy-research-tools',
  build: 'build-your-own',
};

function skillKey(file) {
  return file.replace(/^\d+-/, '').replace(/\.md$/, '').replace(/-prompts?$/, '');
}

function firstCommand(body) {
  const first = body.split('\n').map((l) => l.trim()).find((l) => l.length);
  return first && first.startsWith('/') ? first : null;
}

function parseLesson(fullPath, file) {
  const raw = fs.readFileSync(fullPath, 'utf8');
  const lines = raw.split('\n');
  const skill = skillKey(file);
  let title = skill;
  const out = [];
  let inFence = false, lang = '', buf = [], lastBold = null, lastHeading = null;

  for (const line of lines) {
    const fence = line.match(/^```(.*)$/);
    if (fence) {
      if (!inFence) { inFence = true; lang = fence[1].trim(); buf = []; }
      else {
        inFence = false;
        if (lang === 'text' || lang === '') {
          const body = buf.join('\n').trim();
          if (body) {
            out.push({
              skill, lesson: title, file,
              label: lastBold || lastHeading || firstCommand(body) || 'Prompt',
              command: firstCommand(body),
              body,
            });
            lastBold = null; // consumed
          }
        }
      }
      continue;
    }
    if (inFence) { buf.push(line); continue; }
    const h1 = line.match(/^#\s+(.+)/); if (h1) { title = h1[1].trim(); continue; }
    const bold = line.match(/^\*\*(.+?):?\*\*\s*$/); if (bold) { lastBold = bold[1].trim(); continue; }
    const h = line.match(/^#{2,4}\s+(.+)/); if (h && h[1].trim().toLowerCase() !== 'prompts') lastHeading = h[1].trim();
  }
  return out;
}

function loadCatalog() {
  const sources = [];
  // Repo-owned supplements first (e.g. the mb command bucket) so they lead the list.
  if (fs.existsSync(SUPP)) {
    for (const f of fs.readdirSync(SUPP).filter((f) => f.endsWith('.md')).sort()) {
      sources.push([path.join(SUPP, f), f]);
    }
  }
  // The captured Prompt Library (skip intro + how-to-use lessons).
  if (fs.existsSync(DIR)) {
    for (const f of fs.readdirSync(DIR).filter((f) => f.endsWith('.md') && !/^0[12]-/.test(f)).sort()) {
      sources.push([path.join(DIR, f), f]);
    }
  }
  if (!sources.length) {
    console.error(`No prompt sources found (looked in ${SUPP} and ${DIR})`);
    process.exit(1);
  }
  return sources.flatMap(([p, f]) => parseLesson(p, f));
}

function resolve(input, keys) {
  const q = (input || '').toLowerCase();
  if (keys.includes(q)) return q;
  if (ALIASES[q] && keys.includes(ALIASES[q])) return ALIASES[q];
  return keys.find((k) => k.startsWith(q)) || keys.find((k) => k.includes(q)) || null;
}

// ---- CLI ------------------------------------------------------------------
const [cmd, ...rest] = process.argv.slice(2);
const json = rest.includes('--json');
const args = rest.filter((a) => a !== '--json');
const catalog = loadCatalog();
const keys = [...new Set(catalog.map((p) => p.skill))];

function bucket(key) { return catalog.filter((p) => p.skill === key); }

switch (cmd) {
  case undefined:
  case 'list': {
    if (json) { console.log(JSON.stringify(keys.map((k) => ({ skill: k, lesson: bucket(k)[0]?.lesson, count: bucket(k).length })), null, 2)); break; }
    console.log(`Prompt Library — ${catalog.length} runnable prompts across ${keys.length} buckets\n`);
    for (const k of keys) {
      const b = bucket(k);
      console.log(`  ${k.padEnd(38)} ${String(b.length).padStart(2)}  ${b[0]?.lesson || ''}`);
    }
    console.log(`\nNext: node prompts.mjs skill <key>   (e.g. ads, seo, local, research)`);
    break;
  }
  case 'skill': {
    const key = resolve(args[0], keys);
    if (!key) { console.error(`No bucket for "${args[0]}". Buckets: ${keys.join(', ')}`); process.exit(1); }
    const b = bucket(key);
    if (json) { console.log(JSON.stringify(b, null, 2)); break; }
    console.log(`# ${b[0].lesson}  (${key}) — ${b.length} prompts\n`);
    b.forEach((p, i) => console.log(`  [${i}] ${p.label}${p.command ? `   → ${p.command}` : ''}`));
    console.log(`\nGet one ready to run: node prompts.mjs get ${key} <index>`);
    break;
  }
  case 'get': {
    const key = resolve(args[0], keys);
    if (!key) { console.error(`No bucket for "${args[0]}". Buckets: ${keys.join(', ')}`); process.exit(1); }
    const b = bucket(key);
    const idx = args[1] !== undefined ? Number(args[1]) : null;
    const picks = idx === null ? b : [b[idx]].filter(Boolean);
    if (!picks.length) { console.error(`Index out of range (0–${b.length - 1}).`); process.exit(1); }
    console.log(`Fill the <brackets>. Prepend these three lines if the prompt has no slash command:\n`);
    console.log('```text');
    console.log(CONTEXT_HEADER);
    console.log('```\n');
    for (const p of picks) {
      console.log(`## ${p.label}${p.command ? `  (${p.command})` : ''}\n`);
      console.log('```text');
      console.log(p.body);
      console.log('```\n');
    }
    break;
  }
  case 'markdown':
  case 'doc': {
    const L = [];
    L.push('# Master Brain — Prompt Library');
    L.push('');
    L.push(`> ${catalog.length} runnable prompts across ${keys.length} buckets, parsed from the`);
    L.push('> captured classroom (`classroom/09-prompt-library/`). Copy a prompt, swap the');
    L.push('> `<angle brackets>` for your real values, and run.');
    L.push('');
    L.push('_Generated by `scripts/prompts.mjs markdown` — do not hand-edit; re-run to refresh._');
    L.push('');
    L.push('Pull any of these from the CLI:');
    L.push('');
    L.push('```bash');
    L.push('SCRIPTS="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/master-brain}/scripts"');
    L.push('bash "$SCRIPTS/classroom.sh" prompts skill ads      # list a bucket');
    L.push('bash "$SCRIPTS/classroom.sh" prompts get ads 0      # one prompt, ready to run');
    L.push('bash "$SCRIPTS/classroom.sh" prompts search audit   # search all buckets');
    L.push('```');
    L.push('');
    L.push('The library recommends prepending these three lines to any prompt without a slash command:');
    L.push('');
    L.push('```text');
    L.push(CONTEXT_HEADER);
    L.push('```');
    L.push('');
    L.push('## Contents');
    L.push('');
    for (const k of keys) {
      const b = bucket(k);
      L.push(`- [${b[0]?.lesson || k}](#${k}) — ${b.length} prompts`);
    }
    L.push('');
    for (const k of keys) {
      const b = bucket(k);
      L.push(`<a id="${k}"></a>`);
      L.push('');
      L.push(`## ${b[0]?.lesson || k}`);
      L.push('');
      L.push(`Bucket key: \`${k}\` · ${b.length} prompts`);
      L.push('');
      b.forEach((p, i) => {
        L.push(`### ${i}. ${p.label}`);
        if (p.command) L.push('', `Command: \`${p.command}\``);
        L.push('');
        L.push('```text');
        L.push(p.body);
        L.push('```');
        L.push('');
      });
    }
    process.stdout.write(L.join('\n'));
    break;
  }
  case 'search': {
    const q = args.join(' ').toLowerCase();
    if (!q) { console.error('usage: prompts.mjs search <query>'); process.exit(1); }
    const hits = catalog.filter((p) => `${p.label} ${p.command || ''} ${p.body}`.toLowerCase().includes(q));
    if (json) { console.log(JSON.stringify(hits, null, 2)); break; }
    if (!hits.length) { console.log(`No prompts match "${q}".`); break; }
    for (const p of hits) console.log(`${p.skill.padEnd(20)} ${p.label}${p.command ? `  → ${p.command}` : ''}`);
    break;
  }
  default:
    console.error('usage: prompts.mjs {list | skill <key> | get <key> [index] | search <q>} [--json]');
    process.exit(2);
}
