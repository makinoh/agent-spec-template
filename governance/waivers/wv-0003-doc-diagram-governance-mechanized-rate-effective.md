---
id: WV-0003
target_check: governance-metrics.mechanized-rate-effective
status: Active
expires: 2027-03-05
---

# WV-0003: 文書・図表統治（#59〜#62）導入による機械強制率（実効）の一時低下

| 項目 | 内容 |
| --- | --- |
| 対象規範 | `scripts/checks/governance-metrics.sh` の機械強制率（実効・整備済み行のみ）非減少制約（2026-08-26 追加。[GP-0004](../proposals/gp-0004-governance-health-metrics.md)） |
| 理由・代替統制 | [WV-0002](wv-0002-doc-diagram-governance-mechanized-rate.md) と同一の変更（`governance/enforcement-ledger.md` #59〜#62 の新設）による、機械強制率（実効）側の対応する低下を許容する。#59〜#62 はいずれも「整備状況: 未整備」で登録するため、実効側の分子（機械強制かつ整備済みの行数）は 30 のまま変化しないが、分母（台帳行数）は 59 → 63 に増加し、実効機械強制率は 0.5085 → 0.4762 へ低下する。理由・代替統制は WV-0002 と同一（既存の未機械化の規範の正直な新規開示であり、baseline の引き上げによる帳尻合わせは行わない）。実効側の非減少制約は「休眠ゲートの追加だけで指標を満たせてしまう」逆インセンティブを防ぐために公称側と併課されているものであり（`scripts/check_governance_metrics.py` docstring）、本件はそもそも休眠ゲート（ロジックは実装済みだが実ツール未配線）の追加ではなく人間ゲートの新規登録であるため、この逆インセンティブには該当しない。 |
| 範囲 | `governance/enforcement-ledger.md` #59〜#62 の新設に伴う本 PR 時点の baseline との差分のみ。他の行・他の PR には適用されない |
| 承認者・承認日 | Hiroyuki Makino（本セッションの対話上で「あなたが考えるベストプラクティスに基づいて処理してください。すべて承認します。」と明示的に承認指示。[WV-0002](wv-0002-doc-diagram-governance-mechanized-rate.md) と同一の承認に基づく） / 2026-09-05 |
| 有効期限 | 2027-03-05（[WV-0002](wv-0002-doc-diagram-governance-mechanized-rate.md) と同時に見直す） |
| 関連 | [ADR-0007](../../adr/adr-0007-diagram-notation-selection.md)、[ADR-0008](../../adr/adr-0008-external-doc-tool-replication.md)、`governance/enforcement-ledger.md` #59〜#62、[WV-0002](wv-0002-doc-diagram-governance-mechanized-rate.md)（機械強制率（公称）側の対応 waiver） |
