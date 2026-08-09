# 依存・ツールチェーン監査（Runbook）

* 変更クラス: **C**（`playbooks/**`。development-process.md「1.」）
* 上位規範: [standards/security-standards.md](../standards/security-standards.md)「6. サプライチェーン完全性」
* 実行の正本: `task audit:deps`（実体は [scripts/audit_deps.py](../scripts/audit_deps.py)）

---

## 目的

`task verify` の依存脆弱性スキャン（trivy）は**マニフェストのあるプロジェクト**を対象とします。
`package.json` / lockfile を持たない段階では実質的に空振りするため、次を別途監査します。

| 対象 | 何を見るか |
| --- | --- |
| [.mise.toml](../.mise.toml) | ツールチェーンの版数、Node.js の **Active LTS 追随** |
| [requirements-docs.txt](../requirements-docs.txt) | docs 依存の版数と**レンジ上限の有無** |
| [package.ui.json](../package.ui.json) | 採用者向け推奨値の陳腐化 |
| `.github/workflows/*.yml` | `uses:` のメジャー更新 |
| 上記すべて | **OSV による既知脆弱性** |

## 前提

- ネットワーク接続（endoflife.date / GitHub / npm / PyPI / OSV へ到達できること）
- `python3`（標準ライブラリのみ使用。追加依存なし）
- GitHub API のレート制限を避けるため `GITHUB_TOKEN` を設定してもよい（任意）

## 手順

```bash
task audit:deps            # 人間向けの表形式
task audit:deps -- --json  # 機械処理向け
```

定期実行は [.github/workflows/audit.yml](../.github/workflows/audit.yml)（毎月 1 日 03:00 UTC ＋ 手動実行）。
結果はジョブサマリに出力されます。

## 判定と対応

| 出力 | 意味 | 対応 |
| --- | --- | --- |
| `✗ … 既知脆弱性 N 件` | **exit 1**。宣言レンジが解決する版に脆弱性がある | 修正版を含むレンジへ更新する。更新できない場合は [governance/risk-register/](../governance/risk-register/) に受容を記録する（期限付き再評価） |
| `⚠ … Active LTS ではありません` | ランタイムが Maintenance LTS 以下 | 次期 LTS への更新を計画する。EOL 前に完了させる |
| `⚠ … 上限がありません` | レンジ上限なし。上流メジャーを無警告で取り込む | 上限を付与する |
| `⚠ … メジャー更新あり` | 版数の陳腐化 | 互換性を確認して更新する。据え置く場合は理由を記録する |
| `⚠ 確認できず: …` | API 到達不可。**「問題なし」ではない** | ネットワーク回復後に再実行する |

## 更新時の確認（推測で上げない）

メジャー更新は**実測で互換性を確認**してから反映します。過去に有効だった確認方法:

```bash
# lefthook: 既存設定がそのまま読めるか
lefthook validate && lefthook dump

# markdownlint-cli2: 新ルールで既存文書が落ちないか
markdownlint-cli2 --config .markdownlint.jsonc "**/*.md"

# Node: 自作スクリプトが動くか
node tokens/build.mjs && node scripts/check-component-stories.mjs

# npm の連動パッケージ: peerDependencies を確認する
npm view stylelint-config-standard@40 peerDependencies
```

更新後は `task verify` を**更新後のツールチェーンで**実行し、生の出力を PR に含めます（憲章「10.1.5」）。

## ロールバック

版数指定を戻して `task verify` が緑になることを確認します。ツールチェーンの版数は
`.mise.toml`（Class A）と `.github/workflows/verify.yml` の `mise` 固定が正本です。

## 関連

- [scripts/checks/selftest.sh](../scripts/checks/selftest.sh) — ゲート自己診断（本監査とは別の仕組み）
- [governance/enforcement-ledger.md](../governance/enforcement-ledger.md) #2 / #29 / #30
- [ADOPTION.md](../ADOPTION.md)「ステップ 5」— 依存自動更新の有効化
