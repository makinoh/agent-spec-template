---
id: WV-0004
target_check: diff-size.class-b
status: Active
expires: 2026-10-05
---

# WV-0004: PR #55 の Class B 差分規模上限超過（ADR-0007/ADR-0008 の相互参照ペア）

| 項目 | 内容 |
| --- | --- |
| 対象規範 | development-process.md「5.」差分規模の上限（Class B = 400行。scripts/checks/diff-size.sh） |
| 理由・代替統制 | [PR #55](https://github.com/project-ubiquitous/agent-spec-template/pull/55) は [ADR-0007](../../adr/adr-0007-diagram-notation-selection.md)（294行）と [ADR-0008](../../adr/adr-0008-external-doc-tool-replication.md)（249行）を含み、合算 543 行が Class B 上限（400行）を超過する。両 ADR は front matter の `relates_to` で相互参照する姉妹 ADR であり（ADR-0007「決定（案）」が ADR-0008 の審議・承認を後続アクションとして明記し、ADR-0008「コンテキスト」が ADR-0007 の SSoT 前提を継承する）、一方のみを先にレビュー・マージするには適さない。本リポジトリは単独メンテナ体制（[RISK-0001](../risk-register/risk-0001-single-maintainer-separation-of-duties.md)。Lite プロファイル）であり、小規模PRへの分割が本来もたらす「独立した複数レビュアによる並行レビュー」という便益が構造的に成立しない。加えて、2本を別々のPRとして`main`へ順次マージする方式を採ると、先にマージされた側のADR本文中の`relates_to`リンク・「関連ADR」表・「後続で必要となるアクション/ADR」の記述が、後続PRがマージされるまでの間、存在しないファイルを指す一時的な断リンクとなる（`adr-rules.md`「4. 索引」が定める関係の相互整合性を一時的に破る）。両ADRを同一PRでレビュー・マージすることで、この一時的な不整合を発生させずに済む。なお、本PRのうち Class A 分類対象（`standards/documentation-standards.md`・`governance/enforcement-ledger.md`・waiver類・`scripts/checks/selftest.sh`）の差分規模（176行）は上限（200行）の範囲内であり、本waiverはClass B（ADR2本）にのみ適用する。 |
| 範囲 | [PR #55](https://github.com/project-ubiquitous/agent-spec-template/pull/55)（`docs/diagram-and-external-publication-governance` → `main`）1件のみ |
| 承認者・承認日 | Hiroyuki Makino（本セッションの対話上で「あなたが考えるベストプラクティスに基づいて処理してください。すべて承認します。」と繰り返し明示的に承認指示。本リポジトリは Lite プロファイル・単独メンテナ体制のため GitHub 上に別の承認者を立てられず、[WV-0001](wv-0001-pr43-diff-size-stacked-redelivery.md) と同型の対話ログ承認とする） / 2026-09-05 |
| 有効期限 | 2026-10-05（PR #55 のマージ後は不要となるため短期間に限定。WV-0001 と同型の運用） |
| 関連 | [ADR-0007](../../adr/adr-0007-diagram-notation-selection.md)、[ADR-0008](../../adr/adr-0008-external-doc-tool-replication.md)、[PR #55](https://github.com/project-ubiquitous/agent-spec-template/pull/55)、[governance/proposals/gp-0009-human-gate-diff-size-limit.md](../proposals/gp-0009-human-gate-diff-size-limit.md) |
