# governance/exceptions/ — 例外・逸脱（dispensation）レジスタ

* 上位規範: [constitution.md](../../constitution.md)「7. 変更管理」／ TOGAF Architecture Governance（Dispensation）
* 変更クラス: **A**（統治・強制機構。CODEOWNERS＋権限影響ラベル必須）

本ディレクトリは、アーキテクチャ原則・標準・ADR からの**承認済みの逸脱（dispensation）**を記録する正本（SSoT）です。
TOGAF のアーキテクチャ・ガバナンスにおける「逸脱の申請・承認・追跡」に対応します。

> [waivers/](../waivers/) が「規範を**時限的に満たさない**」のに対し、本レジスタは
> 「特定の文脈で**意図的に別解を採る**（標準からの逸脱）」を扱います。両者は重複しても構いませんが、
> いずれも**承認**と**追跡**を必須とします（MUST）。

## 記録項目

| 項目 | 内容 |
| --- | --- |
| 逸脱対象 | どの原則/標準/ADR から逸脱するか |
| 文脈・正当化 | なぜこの文脈で逸脱が妥当か（より単純な準拠案を却下した理由を含む） |
| 影響・是正計画 | 影響範囲／将来の収束計画（恒久化するなら ADR・標準改正へ） |
| 承認者・承認日 | 作成者≠承認者（MUST） |
| 関連 | 関連 ADR・[risk-register/](../risk-register/) |

## 規約

- 逸脱は ADR の「決定（案）」「結果」や plan.md「Complexity Tracking」と整合させます（重複ではなく相互参照）。
- 安全・統治の核は逸脱対象にできません（MUST NOT。[development-process.md](../../development-process.md)「8.」）。
