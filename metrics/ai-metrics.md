# AI 有効性・追跡可能性指標（AI Effectiveness & Traceability）

* 上位規範: [constitution.md](../constitution.md)（「監査証跡」「AIDD」）
* 位置づけ: AI駆動開発の有効性と統制の継続観測（強制閾値ではない）

AI を継続的な開発メンバーとして扱う以上、その**生産性・品質・統制**を測れる状態を保ちます
（憲章「AI駆動開発」）。本番の個人データ・機密を指標やダッシュボードに含めてはなりません（MUST NOT）。

## 1. 有効性（Effectiveness）

| 指標 | 定義 | 測定元 |
| --- | --- | --- |
| AI 生成変更率（AI-Generated Change Rate） | 全変更のうち AI 起案の割合 | PR ラベル `ai-generated`・コミットトレーラ |
| 人間レビュー受理率（Human Review Acceptance Rate） | AI 起案 PR が大幅修正なく承認された割合 | PR レビュー記録 |
| 手戻り率（Rework Rate） | マージ後に再修正を要した AI 変更の割合 | 追従コミット／revert |
| 自律比率（Autonomy Ratio） | Class C/D で人間介入なく完了した割合 | 変更クラス × 介入記録 |

## 2. 統制・追跡可能性（Traceability）

| 指標 | 定義 | 測定元 |
| --- | --- | --- |
| ADR カバレッジ | Class A/B 変更のうち ADR 参照（または不要理由）を伴う割合 | [scripts/checks/pr_governance.sh](../scripts/checks/pr_governance.sh) |
| Spec カバレッジ | Class A/B 実装のうち対応 spec を持つ割合 | `specs/` × 機能 |
| プロンプト再利用率（Prompt Reuse Rate） | アドホックでなく [prompts/](../prompts/) 資産を用いた割合 | プロンプト資産参照 |
| 権限影響開示率 | 統治パス変更 PR のうち `permission-impact` ラベルを持つ割合 | PR ラベル（憲章「6.」） |

## 3. 運用

- 監査証跡（憲章「監査証跡」）の実効性を測る指標として用い、低下時は原因を [memory/lessons-learned/](../memory/) に記録します（SHOULD）。
- 指標は AI 統制の改善に用い、ゲートの回避や見かけ上の達成（自己修正ループ）に用いてはなりません（MUST NOT。憲章「自己修正ループの防止」）。
