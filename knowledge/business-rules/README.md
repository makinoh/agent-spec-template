# knowledge/business-rules/ — 業務ルール・不変条件

> サンプル構造（テンプレートの実演）。採用時に実プロジェクトの業務ルールを追加する。

業務上の不変条件・ポリシー・計算規則を集約する。spec の機能要求（FR）の**根拠**となり、ADR の判断材料になる。  
実装方法（How）は書かず、規則（What/Why）に徹する。

## 規約

- 1ルール = 1見出しで、ルール ID・内容・根拠（出典／規制／ADR）・関連 spec を記すべきである（SHOULD）。
- 本番の個人データ・機密を例に含めてはならない（MUST NOT。standards/security-standards.md「2.」）。
- 変更クラス: 既定 Class D。規範的で他文書が依拠する場合はレビューアが Class B へ引き上げる（development-process.md「1.」）。
