#!/usr/bin/env node
/**
 * CSS 内に生のブレークポイント値が書かれていないことを検証する。
 *
 * なぜ必要か:
 *   CSS カスタムプロパティはメディアクエリの条件部で使えない。
 *   そのため @media (min-width: 768px) と直書きされやすく、これが
 *   「レスポンシブがデザインと違う」の最頻出原因になる。
 *   src では @media (--bp-md) だけを許可する（postcss-custom-media）。
 */

import { readFileSync, globSync } from 'node:fs';

const targets = globSync(process.argv[2] ?? 'src/**/*.css').filter(
  (f) => !/src[\\/]styles[\\/](tokens|media)\.css$/.test(f)
);

const RAW_MQ = /@media[^{]*\(\s*(?:min|max)-(?:width|height)\s*:\s*[^)]*\d/;
let failures = 0;

for (const file of targets) {
  readFileSync(file, 'utf8')
    .split('\n')
    .forEach((line, i) => {
      if (RAW_MQ.test(line)) {
        failures++;
        console.error(`${file}:${i + 1}  生のブレークポイント値\n    → ${line.trim()}`);
      }
    });
}

if (failures > 0) {
  console.error(
    `\n✗ ${failures} 件。@media (--bp-md) の形式を使ってください。` +
      `\n  利用可能な名前は src/styles/media.css を参照（tokens.json の breakpoint から生成）。`
  );
  process.exit(1);
}

console.log(`✓ メディアクエリ OK（${targets.length} ファイル）`);
