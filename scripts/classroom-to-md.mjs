#!/usr/bin/env node
// Convert the scraped Skool classroom raw JSON into a structured Markdown knowledge base.
// Source: classroom-raw.json (TipTap/ProseMirror rich-text in each module's `desc`).
// Usage: node scripts/classroom-to-md.mjs <raw.json> <outDir>

import fs from 'node:fs';
import path from 'node:path';

const RAW = process.argv[2] || 'classroom-raw.json';
const OUT = process.argv[3] || 'classroom';
const GROUP_URL = 'https://www.skool.com/ai-marketing-hub-pro/classroom';

const slugify = (s) =>
  (s || 'untitled')
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^\p{L}\p{N}]+/gu, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase()
    .slice(0, 60) || 'untitled';

// ---- TipTap -> Markdown ---------------------------------------------------
function marksWrap(text, marks = []) {
  let t = text;
  let href = null;
  for (const m of marks) {
    if (m.type === 'bold') t = `**${t}**`;
    else if (m.type === 'italic') t = `*${t}*`;
    else if (m.type === 'code') t = `\`${t}\``;
    else if (m.type === 'strike') t = `~~${t}~~`;
    else if (m.type === 'link') href = m.attrs?.href || null;
  }
  if (href) t = `[${t}](${href})`;
  return t;
}

function inline(nodes = []) {
  return nodes
    .map((n) => {
      if (n.type === 'text') return marksWrap(n.text ?? '', n.marks);
      if (n.type === 'hardBreak') return '  \n';
      if (n.type === 'image') return `![${n.attrs?.alt || ''}](${n.attrs?.src || ''})`;
      if (n.content) return inline(n.content);
      return '';
    })
    .join('');
}

function block(node, depth = 0) {
  const t = node.type;
  const c = node.content || [];
  switch (t) {
    case 'paragraph': {
      const s = inline(c).trim();
      return s ? s + '\n\n' : '';
    }
    case 'heading': {
      const lvl = Math.min(6, node.attrs?.level || 2);
      return `${'#'.repeat(lvl)} ${inline(c).trim()}\n\n`;
    }
    case 'bulletList':
      return c.map((li) => listItem(li, depth, '-')).join('') + (depth === 0 ? '\n' : '');
    case 'orderedList': {
      let i = node.attrs?.start || 1;
      return c.map((li) => listItem(li, depth, `${i++}.`)).join('') + (depth === 0 ? '\n' : '');
    }
    case 'blockquote':
      return (
        c
          .map((n) => block(n, depth))
          .join('')
          .trim()
          .split('\n')
          .map((l) => `> ${l}`)
          .join('\n') + '\n\n'
      );
    case 'codeBlock':
      return '```' + (node.attrs?.language || '') + '\n' + inline(c) + '\n```\n\n';
    case 'horizontalRule':
      return '---\n\n';
    case 'image':
      return `![${node.attrs?.alt || ''}](${node.attrs?.src || ''})\n\n`;
    case 'text':
    case 'hardBreak':
      return inline([node]);
    default:
      // unknown container: recurse
      return c.length ? c.map((n) => block(n, depth)).join('') : '';
  }
}

function listItem(li, depth, marker) {
  const inner = (li.content || []).map((n) => block(n, depth + 1)).join('').trim();
  const lines = inner.split('\n');
  const pad = '  '.repeat(depth);
  const first = `${pad}${marker} ${lines[0] || ''}`;
  const rest = lines.slice(1).map((l) => (l ? `${pad}  ${l}` : l));
  return [first, ...rest].join('\n') + '\n';
}

function descToMd(desc) {
  if (!desc) return '';
  let raw = desc;
  if (raw.startsWith('[v2]')) raw = raw.slice(4);
  let doc;
  try {
    doc = JSON.parse(raw);
  } catch {
    return desc; // fallback: leave as-is
  }
  const nodes = Array.isArray(doc) ? doc : doc.content || [doc];
  return nodes.map((n) => block(n)).join('').replace(/\n{3,}/g, '\n\n').trim() + '\n';
}

// ---- Build the tree -------------------------------------------------------
const data = JSON.parse(fs.readFileSync(RAW, 'utf8'));
fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(path.join(OUT, '.raw'), { recursive: true });
fs.copyFileSync(RAW, path.join(OUT, '.raw', 'classroom-raw.json'));

const indexLines = [
  '# AI Marketing Hub Pro — Classroom (captured)',
  '',
  `Source: ${GROUP_URL}`,
  `Captured: ${new Date().toISOString().slice(0, 10)} · ${data.courses.length} courses · ` +
    `${data.courses.reduce((a, c) => a + c.modules.filter((m) => m.desc).length, 0)} lessons with content`,
  '',
  'This is a verbatim capture of the member classroom, converted to Markdown so the',
  'Master Brain (and you) can grep, link, and route against the canonical docs.',
  '',
];

data.courses.forEach((course, ci) => {
  const cnum = String(ci + 1).padStart(2, '0');
  const cdir = `${cnum}-${slugify(course.title)}`;
  fs.mkdirSync(path.join(OUT, cdir), { recursive: true });

  indexLines.push(`## ${ci + 1}. ${course.title}`);
  if (course.desc) indexLines.push('', `_${course.desc}_`);
  indexLines.push('');

  course.modules.forEach((m, mi) => {
    const mnum = String(mi + 1).padStart(2, '0');
    const fname = `${mnum}-${slugify(m.title)}.md`;
    const url = `${GROUP_URL}/${course.slug}?md=${m.id}`;
    const body = descToMd(m.desc);
    const fm = [
      '---',
      `course: "${(course.title || '').replace(/"/g, "'")}"`,
      `lesson: "${(m.title || '').replace(/"/g, "'")}"`,
      `type: ${m.type || 'module'}`,
      `skool_url: ${url}`,
      `course_slug: ${course.slug}`,
      `module_id: ${m.id}`,
      m.video ? `has_video: true` : null,
      '---',
      '',
    ]
      .filter((x) => x !== null)
      .join('\n');
    const content = `${fm}# ${m.title || 'Untitled'}\n\n${body || '_(no text content — see Skool for video/embed)_\n'}`;
    fs.writeFileSync(path.join(OUT, cdir, fname), content);

    const flag = m.desc ? '' : ' _(no text)_';
    indexLines.push(`- [${m.title}](${cdir}/${fname})${flag}`);
  });
  indexLines.push('');
});

fs.writeFileSync(path.join(OUT, 'README.md'), indexLines.join('\n'));

const files = data.courses.reduce((a, c) => a + c.modules.length, 0);
console.log(`Wrote ${files} lesson files across ${data.courses.length} courses into ${OUT}/`);
