# governance/ — ガバナンス決定の管理

本ディレクトリは、**憲章（constitution.md）および統治・強制機構の改正** を「ガバナンス決定」として管理する正本（SSoT）です。  
アーキテクチャ決定（ADR）とは別アーティファクトです（憲章「7. 変更管理」）。

## 構成

```text
governance/
├─ proposals/            改正提案（Proposal）
├─ decisions/            改正の確定記録（承認・却下を含む。憲章13章「改正履歴」の正本）
├─ waivers/              規則への時限的な適用除外（waiver）レジスタ
├─ exceptions/           原則・標準からの承認済み逸脱（dispensation）レジスタ
├─ risk-register/        リスク登録簿（受容リスクは waiver/exception と相互参照）
└─ enforcement-ledger.md 強制台帳（各 MUST/MUST NOT → 強制手段 → 整備状況）
```

## 何をここで扱うか（憲章「7.」対象と手続きの対応）

| 対象 | 手続き | 記録先 |
| --- | --- | --- |
| 開発憲章（constitution.md）/ `.specify/memory/constitution.md` | ガバナンス決定 | governance/ |
| 基本方針（charter / vision / scope） | ガバナンス決定 | governance/ |
| 統治・強制機構（standards/ai-governance.md、CI/CD、ブランチ保護、セキュリティ方針） | ガバナンス決定 | governance/ |
| ADR 運用規則（adr-rules.md） | ガバナンス決定 | governance/ |
| その他の技術標準・設計・実装 | ADR または通常変更 | adr/ |

## ガバナンス決定の Status 語彙

```text
Draft / Proposed / Accepted / Rejected / Superseded / Withdrawn
```

> ADR の Status 語彙（Proposed/Accepted/Rejected/Deprecated/Superseded）とは**別語彙**です。  
> 混同しないでください（憲章「7.」注、adr-rules.md「5.」）。

## 手続き（要点・正本は憲章「7.」）

1. 改正は **Proposal** として `proposals/` に起票（変更内容・理由・影響範囲を明記）。
2. 承認には、あらかじめ定めた承認者による定足数を満たす（development-process.md「5.」。AI は単独承認不可＝MUST NOT）。
3. 確定（承認/却下）した結果を `decisions/` に記録し、憲章「13. 改正履歴」へ反映。却下提案も記録を残す。
4. バージョン増分はセマンティックバージョニング（憲章「7.」バージョニング方針）。
