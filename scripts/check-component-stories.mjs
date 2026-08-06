#!/usr/bin/env node
/**
 * src/components/<Name>/ 配下に必須ファイルが揃っているかを検証する。
 *
 * なぜ必要か:
 *   Story の無いコンポーネントは Visual Regression にも a11y テストにも乗らない。
 *   つまり「デザインと違っても誰も気づかない」領域が生まれる。ここを塞ぐ。
 *
 * 必須: <Name>.astro | <Name>.tsx / <Name>.module.css / types.ts / <Name>.stories.*
 */

import { readdirSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';

const ROOT = 'src/components';
if (!existsSync(ROOT)) {
  console.log('src/components が未作成のためスキップします');
  process.exit(0);
}

const dirs = readdirSync(ROOT).filter((d) => statSync(join(ROOT, d)).isDirectory());
let failures = 0;

for (const name of dirs) {
  const files = readdirSync(join(ROOT, name));
  const has = (re) => files.some((f) => re.test(f));

  const checks = [
    [new RegExp(`^${name}\\.(astro|tsx|jsx|vue|svelte)$`), `${name}.astro（または .tsx 等）`],
    [/\.module\.css$/, `${name}.module.css`],
    [/^types\.ts$/, 'types.ts（variant / size の as const + union）'],
    [new RegExp(`^${name}\\.stories\\.(ts|tsx|js|mjs)$`), `${name}.stories.ts`],
  ];

  for (const [re, label] of checks) {
    if (!has(re)) {
      failures++;
      console.error(`✗ ${ROOT}/${name}/ に ${label} がありません`);
    }
  }
}

if (failures > 0) {
  console.error(
    `\n${failures} 件。constitution.md「10.1.4 Story 無きコンポーネントの禁止」に違反しています。`
  );
  process.exit(1);
}

console.log(`✓ コンポーネント構成 OK（${dirs.length} 件）`);
