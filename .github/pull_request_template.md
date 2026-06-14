<!--
本テンプレートは constitution.md「5. ADRポリシー」「6. 承認マトリクス」「9. 完了条件」に対応する。
AIエージェントが起案する PR も本テンプレートを満たすこと。
-->

## 概要

<!-- 変更の目的・背景。関連 spec: specs/<feature>/spec.md があれば参照 -->

## 変更クラス（development-process.md「1.」の対応表で判定）

- [ ] Class A（統治・セキュリティ・本番重大／不可逆）
- [ ] Class B（アーキテクチャ・公開インターフェース）
- [ ] Class C（機能・不具合修正）
- [ ] Class D（ドキュメント・整形）
- [ ] 不明 → **Class A として扱う**

## ADR（Class A / B の場合は必須。constitution.md「5.」）

次のいずれかを必ず記載すること（CI が実体の記載を検査。プレースホルダ・案内文のままは不可）:

- 対応 ADR: `ADR-____`  （← `____` を実際の4桁番号に置換）
- または ADR不要理由: （← 理由を1行で記載し、この案内文（`（←` 以降）は削除する）

## 権限・統治への影響（該当時）

- [ ] 本 PR は統治・強制機構（constitution / governance / standards / .github / AGENTS.md / CLAUDE.md / GEMINI.md / SKILLS.md / adr-rules / adr-template / adr-template-minimal）に触れる
  → `permission-impact` ラベルを付与し、CODEOWNERS の承認を得る（Class A）

## 完了条件チェック（constitution.md「9.」/「8.」）

- [ ] ビルド・型チェック・自動テスト・カバレッジに合格
- [ ] シークレットスキャン・依存脆弱性スキャンに合格
- [ ] Markdown Lint / Link Check に合格（ドキュメント変更時）
- [ ] 関連ドキュメント（spec / AGENTS.md / standards 等）を必要に応じ更新
- [ ] 監査証跡（作成者・承認者・根拠）が追跡可能

## 監査・AI 開示

- [ ] この PR は AI エージェントが起案・生成した（該当時、`ai-generated` ラベル＋コミットトレーラ）
- 作成者と承認者は分離されている（AI は自らが関与した権限拡大を承認・自己マージしない）
