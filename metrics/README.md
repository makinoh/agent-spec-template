# metrics/ — 計測（DORA × AI 有効性）

* 上位規範: [constitution.md](../constitution.md)（「監査証跡」「完了条件」）／ DORA・Accelerate
* 変更クラス: **D**（参照ドキュメント）。ある指標を**強制閾値**にする場合は [standards/](../standards/) へ移し Class A 化する

本ディレクトリは、開発の健全性とAI駆動開発の**有効性・追跡可能性**を測る指標の定義置き場です。
計測は「計測できないものは出さない」を支え、AI生成変更の品質を可視化します。

## 構成

```text
metrics/
├─ dora.md                              デリバリー4指標（DORA / Accelerate）
├─ ai-metrics.md                        AI 駆動開発の有効性・追跡可能性指標
└─ governance-health-snapshot.json      統治健全性メトリクスの baseline（下記「例外」参照）
```

## 位置づけ

- 指標は**観測**が目的であり、初期から強制ゲートにはしません（過剰ゲートの回避。[development-process.md](../development-process.md)「8.」）。
- 完了条件（憲章「9.」）では、設計変更が**重大な性能劣化を導入していない**ことの確認に [standards/performance-standards.md](../standards/performance-standards.md) を用い、本ディレクトリはデリバリー／AI有効性の継続観測を担います（SHOULD）。
- 本番の個人データ・機密を指標値やダッシュボード定義に含めてはなりません（MUST NOT）。

### 例外: 機械強制率（governance-health-snapshot.json）は強制閾値である

本 README 冒頭の変更クラス注記が定める規約（「ある指標を**強制閾値**にする場合は standards/ へ移し Class A 化する」）どおり、
`governance-health-snapshot.json` が保持する**機械強制率**は、単なる観測指標ではなく `task verify:fast` が
実際に強制する閾値です（[scripts/checks/governance-metrics.sh](../scripts/checks/governance-metrics.sh) ＋
[scripts/check_governance_metrics.py](../scripts/check_governance_metrics.py)。正本記録:
[governance/proposals/gp-0004-governance-health-metrics.md](../governance/proposals/gp-0004-governance-health-metrics.md)）。

「standards/ へ移す」という文言が想定する形（独立した standards/*.md 文書の新設）はここでは採っていません。
代わりに `scripts/checks/` 配下への新規チェックスクリプトの追加（それ自体が本リポジトリの規約上 Class A 化を伴う。
AGENTS.md「7.」）と、強制台帳（[governance/enforcement-ledger.md](../governance/enforcement-ledger.md) #36・#37）への
登録によって同じ効果（Class A・機械強制・監査可能）を達成しています。閾値の低下は
[governance/waivers/](../governance/waivers/) の有効な waiver がない限り許容しません。
本ディレクトリの他の指標（dora.md・ai-metrics.md）は引き続き観測専用であり、この例外の対象外です。
