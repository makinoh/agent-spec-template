# アーキテクチャ標準（Architecture Standards）

* Version: 0.1.0（Proposed / ドラフト）
* Date: 2026-04-01
* 上位規範: constitution.md（開発憲章「アーキテクチャの完全性」）

本書は、憲章「アーキテクチャの完全性」が委譲する横断技術標準の正本（SSoT）です。境界・原則の内容は architecture/ を参照します。憲章と矛盾する場合は憲章が優先します（MUST）。

---

## 1. 依存規則

* 循環依存を導入してはなりません（MUST NOT。憲章「アーキテクチャの完全性」）。対応スタックで機械検証が可能になり次第、憲章8章へ登録します（MUST）。登録までは強制台帳上「ブートストラップ（人間レビュー）」とします。
* モジュール間の依存方向を明示し、境界を越える通信は公開された契約（API・イベント）を通じて行うべきです（SHOULD）。

---

## 2. レイヤ・境界

* 具体的なレイヤ構成・モジュール境界・依存規則は [../architecture/boundaries.md](../architecture/boundaries.md) を正本とします。
* アーキテクチャ原則は [../architecture/principles.md](../architecture/principles.md) を正本とします。

---

## 3. 改正履歴

（初版ドラフトのため履歴なし）
