---
title: 用語集
description: AIDD・SDD・ADR・Constitution・Governanceをはじめ、本テンプレートで使う専門用語と略語を網羅した辞書。コア概念・略語・統治用語・ADR用語・RFC2119・ツール・エージェント用語・外部標準を分類して解説。
---

# 用語集

本テンプレートと本サイトで使う専門用語・略語を分類してまとめました。迷ったらここを引いてください。

> 製品ドメイン固有の用語（あなたのアプリの言葉）は、リポジトリ同梱の `glossary.md` が正本です。
> ここは**統治・プロセス・開発手法**の用語を扱います。

## コア概念

| 用語 | 正式名 / 読み | 説明 | 関連 |
| --- | --- | --- | --- |
| AIDD | AI-Driven Development | AI エージェントを継続的な開発メンバーとして扱う開発の進め方 | [解説](../concepts/ai-driven-development.md) |
| SDD | Spec-Driven Development | コードの前に「何を・なぜ」を仕様として書く、仕様ファーストの開発 | [解説](../concepts/spec-driven-development.md) |
| ADR | Architecture Decision Record | 「なぜこの設計にしたか」を 1 ファイルに残す設計判断の記録 | [解説](../concepts/adr.md) |
| spec | Specification（仕様） | 「何を・なぜ（What/Why）」の正本。`specs/<feature>/spec.md` | [解説](../concepts/spec-driven-development.md) |
| plan | プラン | 「どう作るか（How）」の文書。`specs/<feature>/plan.md` | — |
| tasks | タスク | 実行可能な作業に分解した一覧。各タスクに変更クラスを付す | — |
| Constitution | 開発憲章 | 人間も AI も従う最上位の統治文書。`constitution.md` | [解説](../concepts/constitution.md) |
| Governance | ガバナンス | 変更を仕分け、承認境界と強制を定める統治の総称 | [解説](../concepts/governance.md) |
| spec-kit | — | `/speckit.*` コマンドで SDD フローを実行するツールキット | [解説](../concepts/spec-kit.md) |
| Constitution Check | — | `/speckit.plan` で設計を憲章の原則（Gate）に照らす点検 | [解説](../concepts/spec-kit.md) |

## 略語

| 略語 | 正式名 | 説明 |
| --- | --- | --- |
| SSoT | Single Source of Truth | 信頼できる唯一の情報源。同じ情報を複数箇所で管理しない原則 |
| DaC | Documentation as Code | ドキュメントをコードと同等に（レビュー・Git 管理）扱う原則 |
| HITL | Human-in-the-Loop | 要所で人間が判断・承認する仕組み |
| DoD | Definition of Done | 完了条件。マージ・リリースに必要な条件の集合（憲章9章） |
| FR | Functional Requirement | 機能要求。spec に書くテスト可能な要求 |
| NFR | Non-Functional Requirement | 非機能要求。性能・セキュリティ・可用性など |
| US | User Scenario / Story | ユーザーシナリオ。Given/When/Then で受け入れ基準化 |
| PII | Personally Identifiable Information | 個人データ。AI 入力境界で特に厳重に扱う |
| SBOM | Software Bill of Materials | ソフトウェア部品表。依存の出所追跡に使う |
| SLSA | Supply-chain Levels for Software Artifacts | サプライチェーン完全性のレベル指標 |
| SemVer | Semantic Versioning | セマンティックバージョニング（MAJOR.MINOR.PATCH） |
| DORA | DevOps Research and Assessment | 開発の健全性を測る 4 指標の枠組み |
| MTTR | Mean Time To Recovery | 平均復旧時間（DORA 指標の 1 つ） |
| C4 | C4 model | Context/Container/Component/Code のアーキテクチャ図法 |
| DDD | Domain-Driven Design | ドメイン駆動設計。境界づけられたコンテキスト等 |
| MCP | Model Context Protocol | AI のツール接続規格。実行境界は ai-governance.md で統治 |
| RFC | Request for Comments | 標準仕様文書。本書は RFC 2119 / 8174 を採用 |
| CI | Continuous Integration | 継続的インテグレーション。ここでは品質ゲートの実行基盤 |

## 統治・プロセス用語

| 用語 | 説明 | 関連 |
| --- | --- | --- |
| 変更クラス（Class A/B/C/D） | 変更の重さの 4 分類。AI 自律範囲・承認・ADR 要否・ゲートを決める | [解説](../concepts/governance.md) |
| 保護対象ブランチ | ブランチ保護を有効化したブランチ（`main`、`release/*`）。反映に承認・ゲートが要る | — |
| 承認マトリクス | 行為・クラスごとに必要な承認を定めた表 | [詳説](../governance/index.md) |
| 作成者 ≠ 承認者（職務分掌） | 変更の作成者と承認者を分ける原則。AI は自己承認・自己マージ禁止 | [解説](../concepts/governance.md) |
| 権限昇格（の防止） | 軽微変更の積み重ねで AI が事実上権限を広げるのを防ぐ統制 | — |
| 自己修正ループ（の防止） | AI が自分の失敗ゲートを回避目的で弱めるのを封じる統制 | [解説](../concepts/governance.md) |
| ガバナンス決定 | 憲章・基本方針・統治機構の改正手続き（ADR とは別物） | [詳説](../governance/index.md) |
| ブートストラップ規定 | 強制手段が未整備の間、人間レビューで暫定担保する規定 | [解説](../concepts/constitution.md) |
| 強制台帳 | 各 MUST に強制手段を割り当て網羅性を管理する台帳 | [詳説](../governance/index.md) |
| 構造的強制 / 機械強制 / 人間ゲート | 強制手段の三分類。違反不可能化 / CI / 必須レビュア | [解説](../concepts/constitution.md) |
| Break-glass（緊急時例外） | 緊急時に事前検証を事後検証へ切替（人間承認は免除されない） | [詳説](../governance/index.md) |
| 段階導入プロファイル | Lite / Standard / Regulated。統治の重さを規模・規制で選ぶ | [詳説](../governance/index.md) |
| 監査証跡（Auditability） | 作成者・承認者・根拠を後から追跡可能にすること | — |
| 機密区分（データ分類） | データの機密度の区分（例: Restricted）。取り扱い基準を決める | — |
| AI 入力境界 | 本番 PII・機密を AI / 外部 AI に入力しない境界（構造的強制を第一） | [解説](../concepts/ai-driven-development.md) |
| doc-churn | 実装を伴わず文書だけ更新して反復を空費すること（避ける） | [解説](../concepts/spec-kit.md) |
| 完了条件（DoD） | マージ・リリースに必要な条件（品質ゲート＋クラス固有条件） | — |

## ADR 用語

| 用語 | 説明 |
| --- | --- |
| Status（ADR） | Proposed / Accepted / Rejected / Deprecated / Superseded のいずれか |
| Status 遷移 | Proposed→Accepted\|Rejected、Accepted→Deprecated\|Superseded のみ許容 |
| プロファイル（ADR） | minimal（最小）/ full（完全）。必須セクションが異なる |
| scope（適用スコープ） | organization / division / department / product / project |
| フロントマター | ファイル冒頭の YAML。機械可読メタデータの唯一の正本 |
| 命名規則 | `adr-NNNN-short-title.md`（4 桁連番、`0000` は予約） |
| 不変性（Accepted） | Accepted 後は本文を実質変更しない。変更時は新 ADR で Superseded |
| Superseded | 後継 ADR により置き換えられた状態。`superseded_by` で後継を参照 |
| 自動索引 | `adr/INDEX.md`。フロントマターから生成、手編集しない |

## RFC 2119 キーワード

| 用語 | 意味 |
| --- | --- |
| MUST / MUST NOT | 必須 / 禁止 |
| SHOULD / SHOULD NOT | 強く推奨 / 原則非推奨 |
| MAY | 任意 |

> 大文字のときだけ規範的意味を持ちます。RFC 8174 はこの大文字小文字の扱いを明確化した補足。

## ツール・仕組み

| 用語 | 説明 |
| --- | --- |
| Task（taskfile） | 品質ゲートの統一入口（`task verify`）。`Taskfile.yml` |
| mise | ツールチェーンのバージョン固定（`.mise.toml`） |
| lefthook | Git フック管理（commit/push 時に自動チェック） |
| markdownlint | Markdown の Lint（`.markdownlint.jsonc`） |
| lychee | リンク切れ検査 |
| シークレットスキャン | 秘密情報のハードコード検出（例: gitleaks） |
| Dependabot / Renovate | 依存の自動更新の仕組み |
| CODEOWNERS | パスごとの必須レビュアを定義（`.github/CODEOWNERS`） |
| 権限影響ラベル | `permission-impact`。統治・強制機構に触れる PR に付与 |
| 変更クラスラベル | `class:A` / `class:B` / `class:C` / `class:D` |
| AI 生成ラベル | `ai-generated`。AI が起案した変更の識別 |

## エージェント用語

| 用語 | 説明 |
| --- | --- |
| AI エージェント | コード/ドキュメントを生成・編集する AI システムの総称 |
| 自律エージェント | 人間の逐次介入なしに複数ステップを継続実行しうる AI |
| 対話型エージェント | 人間の指示・確認を逐次受けて動く AI |
| エージェント指示ファイル | AI が自動読込する実行指示（`AGENTS.md` が正本、`CLAUDE.md` 等を含む） |
| マシンアカウント / マシンアイデンティティ | AI 専用の識別可能なアカウント（人間の認証情報を使わせない） |
| ハンドオフ | エージェント間の引き継ぎ。成果物とコミットトレーラで行う |

## 外部標準・参考

| 用語 | 説明 |
| --- | --- |
| Nygard ADR | Michael Nygard 提唱の最小構成 ADR（Status/Context/Decision/Consequences） |
| MADR | Markdown Architectural Decision Records。複数案比較を重視した公開テンプレート |
| Y-Statements | 1 文で決定を記述する簡潔な ADR 記法 |
| Keep a Changelog | 変更履歴の記述形式 |
| GDPR | EU 一般データ保護規則。同梱サンプルの題材（エクスポート・削除） |
| OpenAPI / Prisma / Terraform | SSoT の生成元の例（API / スキーマ / IaC を正本に） |

## 関連

- 文書の関係: [文書マップ](document-map.md)
- コマンド: [コマンド集](commands.md)
- 概念の入口: [コンセプト](../concepts/index.md)
