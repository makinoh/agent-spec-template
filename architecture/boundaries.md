# モジュール境界・依存規則（Boundaries）

* Version: 0.1.0（Proposed / ドラフト）
* Date: 2026-04-01
* 上位規範: constitution.md（開発憲章「アーキテクチャの完全性」）／ standards/architecture-standards.md

本書は、レイヤ構成・モジュール境界・依存規則の正本（SSoT）です。

---

## レイヤ構成（例・採用組織が確定）

```text
（例: presentation → application → domain ← infrastructure）
依存は内側（domain）へ向き、domain は外側に依存しない。
```

## 依存規則

- 循環依存を導入してはなりません（MUST NOT）。対応スタックで検証可能になり次第、憲章8章へ登録します（MUST）。
- 境界を越える通信は公開契約（API・イベント）を通じて行うべきです（SHOULD）。

---

## 改正履歴

（初版ドラフトのため履歴なし）
