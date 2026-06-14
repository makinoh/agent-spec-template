# memory/ — エージェント作業記憶（Agent Working Memory）

* 上位規範: [constitution.md](../constitution.md)（「ドキュメントファースト」「SSoT」）
* 変更クラス: 既定 **D**（非規範の作業メモ）。規範的知識へ昇格した項目はレビューアが昇格先のクラスへ引き上げる（[development-process.md](../development-process.md)「1.」）

本ディレクトリは、AIエージェントが**セッションをまたいで参照する作業記憶**の置き場です。
会話履歴に消えがちな知見を残し、マルチエージェントの継続性とコンテキスト圧縮を支えます
（憲章「ドキュメントファースト」）。

> **重要（SSoT 非重複の原則）**: `memory/` は**いかなる情報の正本でもありません**。
> 確定した知見は速やかに正式アーティファクトへ**昇格**させ、ここに滞留させないでください（SHOULD）。
> `memory/` は「まだ正式な居場所を得ていない、揮発的・暫定的な知見」のステージング領域です。

---

## 1. 置くもの / 昇格先（正本）

| サブディレクトリ | 用途 | 昇格先（正本） |
| --- | --- | --- |
| `lessons-learned/` | 反省・再発防止・運用上の学び | 確定知識→ [knowledge/](../knowledge/) ／ 規範→ [standards/](../standards/) ／ 手順→ [playbooks/](../playbooks/) |
| `rejected-options/` | 検討の末に却下した案のメモ（ADR 化前） | [adr/](../adr/) の「選択肢」節へ転記 |
| `handoff/` | エージェント間の申し送り（次担当への引き継ぎ） | [specs/](../specs/) ／ tasks ／ PR 本文 |
| `session-notes/` | 長期コンテキストの圧縮メモ・調査の中間成果 | 確定後に上記いずれかへ昇格 |

## 2. ここに置かないもの（既存の正本があるため重複させない・MUST NOT）

| 情報 | 正本 |
| --- | --- |
| 確定した設計判断（なぜ） | [adr/](../adr/)（Accepted・不変。系譜は Superseded 連鎖で表現） |
| 憲章・統治の改正記録 | [governance/decisions/](../governance/decisions/) |
| インシデント対応**手順** | [playbooks/incident-response.md](../playbooks/incident-response.md) |
| アーキテクチャの**確定**履歴 | [adr/](../adr/) の Superseded 連鎖／[architecture/roadmaps/](../architecture/) |
| ドメイン用語 | [glossary.md](../glossary.md) |

## 3. 規約

- 各メモは「日付・起案エージェント・要旨・昇格先（未定可）」を先頭に記すべきです（SHOULD）。
- 本番の個人データ・顧客機密・秘密情報を書き込んではなりません（MUST NOT。[standards/security-standards.md](../standards/security-standards.md)「2.」）。合成・匿名データのみ。
- 昇格が済んだメモは削除または「Promoted → <リンク>」と記し、二重管理を避けます（SHOULD）。
- AI は `memory/**/*.md`（Class D）を品質ゲート全通過時に自己反映してよい（MAY。[standards/ai-governance.md](../standards/ai-governance.md)「2.」）。これによりエージェントが自らの記憶を維持できます。
