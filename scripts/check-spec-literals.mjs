#!/usr/bin/env node
/**
 * design-spec.md に生の値（HEX / px / rem / ms）が書かれていないことを検証する。
 *
 * なぜ必要か:
 *   design-spec に「padding: 24px」と書かれた瞬間、tokens.json と design-spec の
 *   二重管理が始まり、どちらが正か分からなくなる。design-spec は必ずトークン名で
 *   参照させ、値の真実源を tokens.json 一箇所に保つ。
 *
 * 例外:
 *   行内に <!-- literal-ok: 理由 --> があるか、直前行が同コメントなら見逃す。
 *
 * 使い方: node scripts/check-spec-literals.mjs [glob...]
 */

import { readFileSync, globSync } from 'node:fs';

const patterns = process.argv.slice(2);
const targets =
  patterns.length > 0
    ? patterns.flatMap((p) => globSync(p))
    : globSync('specs/**/design-spec.md');

const FORBIDDEN = /#[0-9a-fA-F]{3,8}\b|\b\d+(?:\.\d+)?(?:px|rem|em|ms|s)\b|\brgba?\(|\bhsla?\(/g;
const EXEMPT = /<!--\s*literal-ok/;

let failures = 0;

for (const file of targets) {
  const lines = readFileSync(file, 'utf8').split('\n');
  let inFence = false;

  lines.forEach((line, i) => {
    if (/^\s*```/.test(line)) { inFence = !inFence; return; }
    // Gherkin / コード例のフェンス内は対象外（受入基準に単位が出るのは許容）
    if (inFence) return;
    if (EXEMPT.test(line)) return;
    if (i > 0 && EXEMPT.test(lines[i - 1])) return;

    const hits = line.match(FORBIDDEN);
    if (hits) {
      failures++;
      console.error(`${file}:${i + 1}  生の値: ${[...new Set(hits)].join(', ')}`);
      console.error(`    → ${line.trim()}`);
    }
  });
}

if (targets.length === 0) {
  console.error('検査対象の design-spec.md が見つかりません（specs/**/design-spec.md）');
  process.exit(1);
}

if (failures > 0) {
  console.error(
    `\n✗ ${failures} 件。design-spec.md は tokens.json のトークン名で参照してください。` +
      `\n  例: padding: 24px  →  padding: var(--space-5)` +
      `\n  意図的な例外は行の直前に <!-- literal-ok: 理由 --> を置いてください。`
  );
  process.exit(1);
}

console.log(`✓ design-spec に生の値なし（${targets.length} ファイル）`);
