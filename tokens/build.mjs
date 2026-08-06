#!/usr/bin/env node
/**
 * Design Token ビルダー（依存ゼロ）
 *
 *   tokens/tokens.json  →  src/styles/tokens.css
 *                          src/styles/media.css
 *                          src/styles/tokens.d.ts
 *
 * 設計方針:
 *  - primitive は CSS に出力しない。存在しない変数は使えない ＝ 誤用が構造的に不可能。
 *  - semantic のみを --<group>-<name> として出力する。
 *  - breakpoint はメディアクエリで var() が使えないため @custom-media として別出力する。
 *
 * 使い方:  node tokens/build.mjs
 * 検証  :  node tokens/build.mjs && git diff --exit-code src/styles/
 */

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

const SRC = 'tokens/tokens.json';
const OUT_CSS = 'src/styles/tokens.css';
const OUT_MEDIA = 'src/styles/media.css';
const OUT_DTS = 'src/styles/tokens.d.ts';

const HEADER = `/**
 * 自動生成ファイル — 手編集しないこと。
 * 生成元: ${SRC}
 * 再生成: node tokens/build.mjs   (task ui:tokens)
 * このファイルの手編集は constitution.md「10.1.1」違反として CI が検出します。
 */`;

const raw = JSON.parse(readFileSync(SRC, 'utf8'));

/** {a.b.c} 参照を解決する */
function resolve(value, depth = 0) {
  if (typeof value !== 'string') return String(value);
  if (depth > 10) throw new Error(`トークン参照が循環しています: ${value}`);
  return value.replace(/\{([^}]+)\}/g, (_, path) => {
    const node = path.split('.').reduce((acc, k) => (acc ?? {})[k], raw);
    if (!node || node.$value === undefined) {
      throw new Error(`未定義のトークン参照: {${path}}`);
    }
    return resolve(node.$value, depth + 1);
  });
}

/** semantic ツリーを平坦化して [cssVarName, light, dark, description] を返す */
function flatten(node, path = []) {
  const out = [];
  for (const [key, val] of Object.entries(node)) {
    if (key.startsWith('$')) continue;
    if (val && val.$value !== undefined) {
      const name = `--${[...path, key].join('-')}`;
      const light = resolve(val.$value);
      const darkRef = val.$extensions?.mode?.dark;
      const dark = darkRef !== undefined ? resolve(darkRef) : null;
      out.push({ name, light, dark, desc: val.$description ?? '' });
    } else if (val && typeof val === 'object') {
      out.push(...flatten(val, [...path, key]));
    }
  }
  return out;
}

const tokens = flatten(raw.semantic);
const darkTokens = tokens.filter((t) => t.dark !== null);

if (tokens.length === 0) throw new Error('semantic トークンが 0 件です');

// ---------- tokens.css ----------
const decl = (t, mode) =>
  `  ${t.name}: ${mode === 'dark' ? t.dark : t.light};` + (t.desc && mode !== 'dark' ? ` /* ${t.desc} */` : '');

const css = [
  HEADER,
  '',
  ':root {',
  ...tokens.map((t) => decl(t, 'light')),
  '}',
  '',
  '/* 明示的なテーマ切替（data-theme が最優先） */',
  '[data-theme="dark"] {',
  ...darkTokens.map((t) => decl(t, 'dark')),
  '}',
  '',
  '/* OS 設定への追従。data-theme="light" が明示されている場合は追従しない */',
  '@media (prefers-color-scheme: dark) {',
  '  :root:not([data-theme="light"]) {',
  ...darkTokens.map((t) => '  ' + decl(t, 'dark')),
  '  }',
  '}',
  '',
  '/* モーション低減。duration をすべて instant に潰す */',
  '@media (prefers-reduced-motion: reduce) {',
  '  :root {',
  ...tokens
    .filter((t) => t.name.startsWith('--duration-'))
    .map((t) => `    ${t.name}: 0ms;`),
  '  }',
  '}',
  '',
].join('\n');

// ---------- media.css ----------
const bps = Object.entries(raw.breakpoint || {}).filter(([k]) => !k.startsWith('$'));
const media = [
  HEADER,
  '',
  '/* postcss-custom-media が必要です。@media (min-width: 48rem) の直書きは CI で弾かれます。 */',
  ...bps.map(([k, v]) => `@custom-media --bp-${k} (min-width: ${resolve(v.$value)});${v.$description ? ` /* ${v.$description} */` : ''}`),
  ...bps.map(([k, v]) => `@custom-media --bp-${k}-down (max-width: calc(${resolve(v.$value)} - 0.0625rem));`),
  '',
].join('\n');

// ---------- tokens.d.ts ----------
const dts = [
  HEADER.replace('/**', '/**'),
  '',
  '/** src で使用してよい CSS カスタムプロパティの全集合 */',
  'export type DesignToken =',
  ...tokens.map((t, i) => `  ${i === 0 ? '|' : '|'} '${t.name}'`),
  '  ;',
  '',
  '/** 使用可能なブレークポイント（@custom-media 名） */',
  'export type Breakpoint =',
  ...bps.map(([k]) => `  | '--bp-${k}'`),
  ...bps.map(([k]) => `  | '--bp-${k}-down'`),
  '  ;',
  '',
  'export declare const DESIGN_TOKENS: readonly DesignToken[];',
  '',
].join('\n');

for (const [path, content] of [[OUT_CSS, css], [OUT_MEDIA, media], [OUT_DTS, dts]]) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, content, 'utf8');
}

console.log(
  `✓ semantic ${tokens.length} 件 (dark 定義 ${darkTokens.length} 件) / breakpoint ${bps.length} 件 を生成しました`
);
