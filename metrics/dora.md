# DORA 指標（Delivery / Accelerate）

* 上位規範: [constitution.md](../constitution.md)／ DORA・*Accelerate*（Forsgren, Humble, Kim）
* 位置づけ: デリバリー健全性の継続観測（強制閾値ではない。閾値化時は [standards/](../standards/) へ）

> 値・目標は採用組織がガバナンス決定で確定します（プレースホルダ）。測定の自動化を推奨します（SHOULD）。

## 1. 四つの主要指標（Four Keys）

| 指標 | 定義 | 目標（例・採用時に確定） | 測定元（例） |
| --- | --- | --- | --- |
| デプロイ頻度（Deployment Frequency） | 本番反映の頻度 | [記入] | CI/CD・リリースタグ |
| 変更リードタイム（Lead Time for Changes） | コミット→本番までの時間 | [記入] | VCS＋デプロイ記録 |
| 変更失敗率（Change Failure Rate） | 本番変更のうち障害を招いた割合 | [記入] | インシデント／ロールバック記録 |
| 平均復旧時間（MTTR） | 障害から復旧までの時間 | [記入] | インシデント記録（[playbooks/incident-response.md](../playbooks/incident-response.md)） |

## 2. 信頼性指標（任意・SRE）

- 可用性 SLO、エラーバジェット（[standards/observability-standards.md](../standards/observability-standards.md) と連携）。

## 3. 運用

- 四半期ごとに傾向を確認し、悪化時は原因を [memory/lessons-learned/](../memory/) に記録、恒久対策は ADR / standards へ昇格します（SHOULD）。
- 指標を**個人評価**に用いてはなりません（SHOULD NOT。計測はシステム改善のため）。
