---
id: WV-0002
target_check: governance-metrics.mechanized-rate
status: Active
expires: 2027-03-05
---

# WV-0002: 文書・図表統治（#59〜#62）導入による機械強制率（公称）の一時低下

| 項目 | 内容 |
| --- | --- |
| 対象規範 | `scripts/checks/governance-metrics.sh` の機械強制率（公称・inclusive）非減少制約（[GP-0004](../proposals/gp-0004-governance-health-metrics.md)） |
| 理由・代替統制 | [governance/enforcement-ledger.md](../enforcement-ledger.md) に #59〜#62（[standards/documentation-standards.md](../../standards/documentation-standards.md) が新設する、文書・図の SSoT／図表記法選定／外部ドキュメントツール複製の各 MUST・MUST NOT・SHOULD）を新設登録した（[ADR-0007](../../adr/adr-0007-diagram-notation-selection.md)・[ADR-0008](../../adr/adr-0008-external-doc-tool-replication.md)）。これら4行は、外部ドキュメントツール複製の技術的前提（U-1〜U-3。未検証）が解消するまで自動化を実装しないという設計上の制約により、いずれも新規の `scripts/checks/*.sh` を伴わない「人間ゲート（不可避）」または「人間ゲート（暫定）」としてのみ登録した。この結果、台帳行数（分母）が 59 → 63 に増加する一方、機械強制行数（分子）は 44 のまま変化しないため、機械強制率（公称）は 0.7458 → 0.6984 へ機械的に低下する。これは実装上の後退ではなく、既存の未機械化の規範を新たに正直に開示した結果である（強制台帳 #58 が力量要件の MUST NOT を新規登録した際と同型の事例）。baseline を `--write-baseline` で引き上げて帳尻を合わせることは、自らの変更で下げた指標を回避目的で軽くする行為（constitution.md「6. AIエージェント統治と自律境界」自己修正ループの防止）に該当するため行わない。代わりに、低下の事実を隠さず可視化したまま、時限的な waiver で通過させる。 |
| 範囲 | `governance/enforcement-ledger.md` #59〜#62 の新設に伴う本 PR 時点の baseline との差分のみ。他の行・他の PR には適用されない |
| 承認者・承認日 | Hiroyuki Makino（本セッションの対話上で「あなたが考えるベストプラクティスに基づいて処理してください。すべて承認します。」と明示的に承認指示。本リポジトリは Lite プロファイル・単独メンテナ体制（[RISK-0001](../risk-register/risk-0001-single-maintainer-separation-of-duties.md)）のため GitHub 上に別の承認者を立てられず、[WV-0001](wv-0001-pr43-diff-size-stacked-redelivery.md) と同型の対話ログ承認とする） / 2026-09-05 |
| 有効期限 | 2027-03-05（起票から6ヶ月後。#62 の乖離検出ゲート（D-8）の実装状況・U-1〜U-3 の検証状況を見直し、再延長または恒久対応（新規機械検証の実装、もしくは baseline の意図的な引き上げの是非を人間が判断）を決定する） |
| 関連 | [ADR-0007](../../adr/adr-0007-diagram-notation-selection.md)、[ADR-0008](../../adr/adr-0008-external-doc-tool-replication.md)、`governance/enforcement-ledger.md` #59〜#62、[WV-0003](wv-0003-doc-diagram-governance-mechanized-rate-effective.md)（実効機械強制率側の対応 waiver） |
