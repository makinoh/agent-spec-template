# architecture/context-maps/ — コンテキスト図（C4 / 境界づけられたコンテキスト）

* 上位規範: [constitution.md](../../constitution.md)「アーキテクチャの完全性」／ [architecture/boundaries.md](../boundaries.md)
* 変更クラス: **B**（アーキテクチャ。原則 ADR 化）

システムの**文脈**を可視化します。C4（Context / Container / Component）と、
DDD の**境界づけられたコンテキスト**／コンテキストマップ（上流下流・腐敗防止層 等）を扱います。

> 旧 `architecture/c4/` の役割を本ディレクトリに統合しました。図は Mermaid 等のテキスト形式で版管理し、Docs as Code を維持します（SHOULD）。

## 記述の目安

- C4 Level 1（System Context）/ Level 2（Container）を最低限維持する（SHOULD）。
- 境界越えの通信は公開契約（API・イベント）で行う（[boundaries.md](../boundaries.md)・[../integrations/](../integrations/)）。
- 循環依存を導入しない（MUST NOT。憲章「アーキテクチャの完全性」）。
