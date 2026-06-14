# governance/risk-register/ — リスク登録簿（Risk Register）

* 上位規範: [constitution.md](../../constitution.md)「3. 原則の競合と裁定」「変更の可逆性とインシデント対応」
* 変更クラス: **A**（統治・強制機構。CODEOWNERS＋権限影響ラベル必須）

本ディレクトリは、プロジェクト／アーキテクチャ／AI運用に関わる**リスク**を識別・評価・追跡する正本（SSoT）です。
受容したリスクは [waivers/](../waivers/) ／ [exceptions/](../exceptions/) と相互参照します。

## 記録項目（各リスク）

| 項目 | 内容 |
| --- | --- |
| リスク ID | `RISK-NNNN` |
| 説明 | 事象と発生条件 |
| 区分 | セキュリティ / アーキテクチャ / 運用 / AI（例: プロンプトインジェクション、機密漏えい、過度の自律） |
| 影響 × 可能性 | 評価（例: 高/中/低） |
| 対応方針 | 低減 / 受容 / 移転 / 回避 |
| オーナー・見直し期日 | 担当と次回評価日 |
| 関連 | 関連 ADR・waiver・exception・[standards/security-standards.md](../../standards/security-standards.md) |

## AI 固有リスクの例（初期セット・採用組織が拡張）

- 間接的プロンプトインジェクション（ツール出力・外部文書経由）。
- 機密区分未定義データの誤入力（憲章「データ保護とAI入力境界」）。
- 権限昇格（軽微変更の組合せによる事実上の自律拡大。憲章「6.」）。
- 自己修正ループによるゲートの形骸化（憲章「自己修正ループの防止」）。

## 規約

- 受容（受容＝対応しない判断）は承認と期限付き再評価を必須とします（MUST）。
- 重大リスクが顕在化した場合は [playbooks/incident-response.md](../../playbooks/incident-response.md) に接続します。
