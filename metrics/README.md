# metrics/ — 計測（DORA × AI 有効性）

* 上位規範: [constitution.md](../constitution.md)（「監査証跡」「完了条件」）／ DORA・Accelerate
* 変更クラス: **D**（参照ドキュメント）。ある指標を**強制閾値**にする場合は [standards/](../standards/) へ移し Class A 化する

本ディレクトリは、開発の健全性とAI駆動開発の**有効性・追跡可能性**を測る指標の定義置き場です。
計測は「計測できないものは出さない」を支え、AI生成変更の品質を可視化します。

## 構成

```text
metrics/
├─ dora.md         デリバリー4指標（DORA / Accelerate）
└─ ai-metrics.md   AI 駆動開発の有効性・追跡可能性指標
```

## 位置づけ

- 指標は**観測**が目的であり、初期から強制ゲートにはしません（過剰ゲートの回避。[development-process.md](../development-process.md)「8.」）。
- 完了条件（憲章「9.」）では、設計変更が**重大な性能劣化を導入していない**ことの確認に [standards/performance-standards.md](../standards/performance-standards.md) を用い、本ディレクトリはデリバリー／AI有効性の継続観測を担います（SHOULD）。
- 本番の個人データ・機密を指標値やダッシュボード定義に含めてはなりません（MUST NOT）。
