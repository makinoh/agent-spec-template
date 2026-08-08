---
id: GP-0001
title: "UI 再現性レイヤの導入（憲章「10.1」の新設）"
status: Accepted              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-06
last_updated: 2026-08-08
proposer: "makinoh"
approvers: ["makinoh"]        # Lite プロファイル（GD-0001）により定足数 1 名。確定記録: GD-0002
target_version: 0.2.0         # 憲章のバージョン増分（MINOR）
supersedes: []
superseded_by: []
relates_to: [ADR-0005, ADR-0003, ADR-0004]
---

# GP-0001: UI 再現性レイヤの導入（憲章「10.1」の新設）

> ガバナンス決定（憲章「7. 変更管理」）。ADR とは別アーティファクトであり、Status 語彙も別です（governance/README.md）。

## 1. 提案の要旨

本テンプレートに **UI 再現性（デザインと実装の値の一致）** を機械的に保証するレイヤを追加します。

既存の品質ゲートは秘密情報・依存脆弱性・テスト・ADR 記載・統治設定の無断変更を検出しますが、「`padding` が `24px` ではなく `20px` になっている」を検出できません。本提案は、値を書ける場所を `tokens/tokens.json` 一箇所に閉じ、逸脱を `task verify` の内側で検出可能にします。

## 2. 変更内容

### 2.1 憲章（constitution.md）— Class A

- 「10.1 UI 再現性（UI Reproducibility）」を新設（10.1.1〜10.1.7）。
- 「2. 文書管理階層」に、機能仕様内部の優先順位（`spec.md` → `design-spec.md` → `plan.md`）の補足を追加。
- バージョン: 0.1.0 → **0.2.0**（MINOR。後方互換な原則・節の追加）。

### 2.2 統治・強制機構 — Class A

| 対象 | 変更 |
| --- | --- |
| [.specify/memory/constitution.md](../../.specify/memory/constitution.md) | 原則 X（UI 再現性）を追加し、本体「10.1」と同期 |
| [AGENTS.md](../../AGENTS.md) | 「8. UI 実装のルール」を追加（着手前チェック・値の扱い・禁止コマンド） |
| [development-process.md](../../development-process.md) | 変更クラス表に UI・デザイン領域の行を追加 |
| [standards/design-tokens.md](../../standards/design-tokens.md) | 新規（トークン規約の実装標準） |
| [standards/frontend-ui.md](../../standards/frontend-ui.md) | 新規（Astro / Storybook / Cloudflare の技術標準） |
| [Taskfile.yml](../../Taskfile.yml) | `Taskfile.ui.yml` を include し、`verify` / `verify:fast` に UI ゲートを接続 |
| `scripts/checks/ui.sh`・`scripts/check-*.mjs`・`tokens/build.mjs` | 新規（強制機構の実体） |
| `.stylelintrc.json` | 新規（トークン外の値を error にする強制機構） |
| [governance/enforcement-ledger.md](../enforcement-ledger.md) | 規範 #23〜#26 を追加 |

### 2.3 設計判断 — Class A / B（ADR）

| ADR | 内容 | Status |
| --- | --- | --- |
| [ADR-0003](../../adr/adr-0003-storybook-astro-rendering.md) | Storybook における Astro コンポーネントの描画方式 | Proposed（採用時に確定） |
| [ADR-0004](../../adr/adr-0004-cloudflare-deployment-target.md) | Cloudflare のデプロイ先 | Proposed（採用時に確定） |
| [ADR-0005](../../adr/adr-0005-css-token-enforcement.md) | CSS の記述方式とトークン強制の手段 | Proposed（本提案の承認と同時に Accepted へ遷移する想定） |

## 3. 理由

1. **自然言語の禁止事項は機能しない。** 「色を変更しないこと」という指示はレビューの疲労で漏れる。機械は疲労しない（憲章「1.1 義務レベルと強制手段」の機械強制優先）。
2. **既存の骨格が適している。** `task verify` の一元化（Local = AI = CI）と変更クラス A/B/C/D は、UI ゲートを追加登録なしで必須化できる形になっている。
3. **基準画像の更新権限の分離が要。** 視覚回帰は差分検出の本体だが、`--update-snapshots` を AI が自由に実行できる状態では検出器として機能しない。これを Class B とし AI の実行を禁止することが、他の機構が空回りしないための前提となる（憲章「10.1.5-4」）。

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転・意味変更なし**（後方互換。MINOR 増分の根拠） |
| UI を持たない採用 | 影響なし。「10.1」は `package.json` と `src/` の存在で活性化し、それまでは休眠（`scripts/checks/ui.sh` が skip して緑を返す） |
| CI | `.github/workflows/verify.yml` は変更不要。UI ゲートは `task verify` の内側に入る。ブランチ保護の必須チェックも `verify` のまま |
| AI エージェントの権限 | **縮小**（視覚回帰の基準画像更新を禁止、トークン追加を Class B 化）。拡大はない |

## 5. 検討した代替案

| 代替案 | 却下理由 |
| --- | --- |
| 憲章に触れず standards/ のみで規定する | 「10.1.5 自己申告を成果と認めない」「10.1.3 推測の禁止」は AI の自律境界に関わる規範であり、憲章「6.」と同格の位置づけが必要 |
| UI ゲートを独立ワークフロー（`verify-ui.yml`）として CI に追加する | 「CI は独自ロジックを持たず `task verify` を実行する」という既存原則（Taskfile.yml・verify.yml のヘッダ）に反する。ブランチ保護への追加登録も必要になる |
| 視覚回帰の基準画像更新を Class C に留める | AI が基準を書き換えられる状態では視覚回帰が検出器として機能せず、他の機構がすべて空回りする |

## 6. 承認

> 憲章の改正は **憲章承認者グループ 2 名以上**の承認を要します（development-process.md「5.」）。AI エージェントは単独で承認・反映してはなりません（MUST NOT。憲章「7.」）。

| 項目 | 内容 |
| --- | --- |
| 承認者・承認日 | `makinoh`（リポジトリオーナー） / 2026-08-08 |
| 定足数の充足 | 充足（Lite プロファイル: 1 名。[GD-0001](../decisions/gd-0001-adoption-profile-lite.md)） |
| 確定結果（Accepted / Rejected） | **Accepted**（確定記録: [GD-0002](../decisions/gd-0002-constitution-0-2-0-approval.md)） |

承認後の手続き:

1. 本提案の `status` を `Accepted` に更新し、`governance/decisions/` に確定記録を作成する。
2. 憲章「13. 改正履歴」の `[0.2.0]` エントリから「承認待ち」の注記を外す。
3. [ADR-0005](../../adr/adr-0005-css-token-enforcement.md) を `accepted` へ遷移させる（`decision-makers` / `review_after` を同時更新。Class A・人間必須）。

## 7. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-06 | makinoh | 初版作成、Proposed に設定 | UI 再現性レイヤの導入提案 |
| 2026-08-08 | makinoh | Accepted へ遷移（確定記録: [GD-0002](../decisions/gd-0002-constitution-0-2-0-approval.md)） | 定足数 1 名（Lite）を充足 |
