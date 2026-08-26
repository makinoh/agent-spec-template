---
id: GP-0012
title: "外部セキュリティ・統治フレームワークとの整合性評価（CoSAI CodeGuard / OSPS Baseline / OPA・Semgrep+Allstar / NIST SP 800-218A・CoSAI-RM）"
status: Proposed              # Draft | Proposed | Accepted | Rejected | Superseded | Withdrawn
date: 2026-08-24
last_updated: 2026-08-24
proposer: "claude-code (Sonnet 5)"
approvers: []                 # 承認待ち。Lite プロファイル（GD-0001）により定足数 1 名（オーナー）
target_version: "standards/ai-governance.md 0.2.0 → 0.3.0（提案・MINOR、本 PR で反映済み）／governance/enforcement-ledger.md への新規候補行は本提案が内容を提示するのみで、実際の採番・反映は同時並行の別セッション（scripts/checks/pr_governance.sh 等の regex 是正／license ゲート実装を担当）に委ねる（「7. 未解決事項」Q-03）"
supersedes: []
superseded_by: []
relates_to: [GP-0005]
---

# GP-0012: 外部セキュリティ・統治フレームワークとの整合性評価

> ガバナンス決定（憲章「7. 変更管理」）。外部レビュー「現実的な推奨構成」（層別のツール採用表と、pr_governance.sh の regex 欠落指摘）への対応。

## 0. 背景（何が持ち込まれたか）

ユーザーが持ち込んだ外部レビューは、次の表で本テンプレートの構成を再編することを提案していた。

| 層 | 採るもの | agent-spec-template から残すもの |
| --- | --- | --- |
| セキュリティ規範 | CoSAI Project CodeGuard（108 ルール＋translator） | — |
| 統制カタログ | OpenSSF OSPS Baseline（YAML/OSCAL/スキャナ） | 台帳の思想は同じ。移行先はこちら |
| 強制エンジン | OPA または Semgrep ＋ Allstar | ゲートの実装のみ移す |
| 監査アンカー | NIST SP 800-218A / CoSAI-RM | 憲章から参照を張る |
| ライセンス | Trivy `--scanners license` 等 | （どこにも無いので自前） |
| SDLC統治プロセス | 該当なし | 変更クラス判定・承認マトリクス・ADR・差分規模上限はここにしかない |

レビューは「丸ごと乗り換えることはできない」という結論を自ら明記しており、加えて「`pr_governance.sh` の regex 欠落は、どの外部ツールを入れても直らない。手で直す必要がある」という具体的な指摘を含んでいた。

**本提案作成と並行して**、同一リポジトリ・同一ブランチ（`fix/governance-fail-open-and-license-gate`）で別セッション（agent-spec-template-65）が稼働しており、以下を確認・是正済みである（本提案は重複させず、以下は既知の前提として扱う）。

* `pr_governance.sh` の regex 欠落（`CODEX.md` / `OPENHANDS.md` / `TAKT.md` / `agents/**` / `development-process.md` が `$gov`/`$ab` から漏れ、これらのみを変更する PR が統治ゲートを素通りしていた）は、隔離クローンでの再現確認のうえ是正済み（`scripts/checks/pr_governance.sh`・`scripts/check_diff_size.py`・`.github/CODEOWNERS`・`development-process.md`・`selftest.sh` 陰性テスト6件）。→ **レビューの当該指摘は妥当であり、既に対応済み。**
* ライセンススキャン（`Trivy --scanners license` 相当）は `scripts/checks/deps.sh` に休眠/活性化パターン（`LICENSE_SCAN_CMD` / `scripts/dev/license-tool.sh` / `LICENSE_FAIL_SEVERITY`）で実装済み、`standards/security-standards.md「6.1」`・`governance/enforcement-ledger.md #55` も新設済み。→ **レビューの当該指摘（「どこにも無い」）も妥当であり、既に対応済み。**

したがって本提案は、レビュー表の**残り3行**（セキュリティ規範・統制カタログ・強制エンジン・監査アンカー）を対象に、主張の事実確認と、採用可否の評価に限定する。

---

## 1. 提案の要旨

各ツール・標準の実在性と機能を一次情報で検証した結果（「2.」）、レビューの事実関係は概ね正確だった。ただし、**表が示唆する「層の入れ替え」は、実際にはどの項目も「置き換え」ではなく「補完」または「情報提供の参照」としてのみ妥当**である。理由は次のとおり。

* CoSAI Project CodeGuard はコード**生成時点**のガイダンス（予防的）であり、本テンプレートの SAST ゲート（`scripts/checks/sast.sh`。governance/proposals/gp-0005-sast-gate.md）が担う**生成後の検出**（事後的）とは異なるレイヤであり、代替関係にない。
* OpenSSF OSPS Baseline は汎用 OSS プロジェクトの**衛生度**（ブランチ保護・脆弱性開示窓口・SBOM 等）を測るベンチマークであり、`governance/enforcement-ledger.md` が担う「**この組織固有の**憲章 MUST/MUST NOT の強制状況追跡」とは対象範囲が異なる。「台帳の思想は同じ」は部分的に正しいが、台帳を OSPS Baseline に置き換えると、本テンプレート固有の規範（変更クラス判定・ADR要否・差分規模上限など）を追跡する手段が消える。
* OPA・Semgrep・Allstar はいずれも実在し技術的に有効だが、特に **Allstar は本テンプレートの現行アーキテクチャに構造的な穴を突く**具体的な価値がある（「3.2」で詳述）。一方 OPA/Semgrep による `scripts/checks/*.sh` 全体の書き換えは、実装言語・実行基盤の選定を伴う Class B（architecture）相当の決定であり、本提案の範囲を超える。
* NIST SP 800-218A・CoSAI-RM は実在する規範・分類法であり、`standards/ai-governance.md` の情報提供の参照として追加する価値がある（機械強制ゲートではない）。

**レビュー自身の結論（SDLC 統治プロセスに外部の同等物は無く、agent-spec-template の骨格は残す前提になる）は、本検証でも追認される。** 変更クラス判定（Class A/B/C/D）・承認定足数・ADR 必須化トリガ・差分規模上限のいずれも、CodeGuard／OSPS Baseline／OPA・Semgrep・Allstar／NIST SP 800-218A のどれにも同等の概念が存在しない。これらは「変更の内容に応じてどれだけの人間承認を要求するか」という**変更管理**の関心事であり、上記5件はいずれも「コードやリポジトリ設定が特定の基準を満たすか」という**状態検証**の関心事である。次元が異なるため統合できない。

---

## 2. 検証した個別主張（一次情報での裏取り）

**検証方法の開示**: 2026-08-24、WebSearch で一次情報（公式サイト・GitHub リポジトリ・NIST 公表文書）に当たった。検証記録の URL は「6.」に列挙する。数値等は本テンプレートの既存規約（constitution.md「10.1.3 推測の禁止」・governance/proposals/gp-0005-sast-gate.md の CON-05/IMP-05 と同趣旨）に従い、一次情報で再現できない場合はその旨を明記し、発明しない。

| 主張 | 検証結果 | 本提案での扱い |
| --- | --- | --- |
| CoSAI Project CodeGuard（108 ルール＋translator） | **実在**。2025年10月に Cisco が OSS 化し CoSAI（OASIS Open Project）へ寄贈。「モデル非依存のセキュアコーディング規範を AI コーディングエージェントのワークフローに埋め込む」フレームワークで、ルール定義（平文の指示ファイル）と、各コーディングエージェントのネイティブ形式へ変換する translator を持つ。ルール数は内訳に依存する（core 22 件＋ OWASP 補完 88 件 ≈ 110 件、Claude Code プラグイン単体では 23 件）。**「108」という厳密値は一次情報で再現できなかった**が、「100件規模の規範ルール＋エージェント別 translator」という主張の骨子（構造・規模感）は正確。 | SAST とは代替関係でなく補完関係。standards/ai-governance.md「8.」に位置づけを明記（本 PR で反映済み）。スキルとしての採用可否は TBD-HUMAN（「7.」Q-01）。 |
| OpenSSF OSPS Baseline（YAML/OSCAL/スキャナ） | **実在**。統制は YAML（Gemara Layer 2 スキーマ）で定義され、NIST の OSCAL 形式へネイティブに変換できる。3段階の成熟度（sandbox/incubating/graduated）で構成され、CRA・SSDF・OpenSSF Scorecard に対応付けられている。GitHub Action 版のスキャナ（LFX Insights と同一エンジン）が存在し、個別リポジトリの自動評価が可能。 | 「台帳の思想は同じ」は部分的に妥当（詳細は「1.」）。enforcement-ledger.md の置き換えではなく、advisory な外部ベンチマークとしての併用を提案（採用可否は TBD-HUMAN。「7.」Q-02）。 |
| OPA（Open Policy Agent） | **実在**。汎用ポリシーエンジン（Rego 言語）。本テンプレートは特定のポリシーエンジンを採用していない。 | `scripts/checks/*.sh` の書き換えは Class B 相当（architecture-standards.md 選定）。本提案の範囲外。 |
| Semgrep | **実在**。パターンベースの静的解析ツール。`SAST_CMD` の候補ツールの一つとして gp-0005-sast-gate.md の枠組みで既に受け入れ可能（製品名を規範に固定しない設計のため、採用組織が `$SAST_CMD` に指定すればそのまま使える）。 | 追加のゲート新設は不要。既存の SAST ゲート（#40）の配線先候補として ADR で検討可能である旨を記録するにとどめる。 |
| Allstar（OpenSSF、旧 Google 製） | **実在**。GitHub App で、リポジトリのブランチ保護・`SECURITY.md` の存在・管理者のOrg所属・バイナリ混入等を**継続的に**（一時点でなく）ポリシーと突合し、乖離時に issue 起票または設定復元を行う。「ブランチ保護を一時的に無効化して不正変更を混入後、元に戻す」という攻撃への対抗を明示的な設計目的とする。 | **最も具体的で妥当な指摘**。本テンプレートの現行実装には同種の継続監視が構造的に欠落している（「3.2」で詳述）。 |
| NIST SP 800-218A | **実在**。2024-07-26公開。SP 800-218（SSDF）を生成AI・基盤モデル向けに拡張したコミュニティプロファイル。Executive Order 14110 に基づき NIST が策定。 | standards/ai-governance.md「8.」に情報提供の参照として追加（本 PR で反映済み）。 |
| CoSAI Risk Map（CoSAI-RM） | **実在**。Google の SAIF を起源とし CoSAI へ移管。Data/Infrastructure/Model/Application の4層×25以上のリスク分類。Persona（Model Creator/Consumer/Application Developer 等）ごとにリスク・コントロールを関連付ける動的グラフ構造。MITRE ATLAS・NIST AI RMF に相互参照。 | 同上。standards/ai-governance.md「8.」に反映済み。 |
| Trivy `--scanners license` | **実在・正確**。別セッションが `scripts/checks/deps.sh` に実装済み（本提案の対象外。「0.」参照）。 | 対応不要。 |
| 「SDLC統治プロセスは agent-spec-template にしかない」 | **妥当**。上記いずれも「変更管理」（承認定足数・ADR要否・差分上限）の概念を持たない。 | development-process.md「1.」対象パス表・承認マトリクスは変更しない。 |

---

## 3. 変更内容

### 3.1 standards/ai-governance.md「8. 外部監査アンカー（参照規範）」（新設）— Class A・本 PR で反映済み

NIST SP 800-218A・CoSAI Risk Map を **SHOULD** の情報提供参照として追加し、CoSAI Project CodeGuard 等のガイダンス資産が SAST と補完関係（代替でない）であることを明記した。**特定製品を MUST/MUST NOT の対象にしていない**（NG-05 と同趣旨。gp-0005-sast-gate.md 同様の設計判断）。バージョン: 0.2.0 → **0.3.0（提案・MINOR）**。

### 3.2 governance/enforcement-ledger.md — 新規候補行（未反映。担当セッションへ引き渡し）

**指摘の核心**: 現行の #5（Class A/B の人間承認）・#12（作成者≠承認者・ブランチ保護設定）・#19（必須ステータスチェック）・#22（採用配線の完遂点検）は、いずれも「**設定されていること**」を確認する。しかし、設定**後**にブランチ保護や CODEOWNERS の実体（GitHub 側の設定）が誰かに一時的に解除・変更され、不正な変更を混入後に元へ戻された場合、これを検出する継続監視は**本テンプレートのどの機構にも存在しない**（`scripts/checks/*.sh` はローカル/CI 実行時にリポジトリのファイル内容と PR コンテキストのみを検査し、GitHub 側のライブなリポジトリ設定を継続的にはポーリングしない。#22 の検証箇所欄も「CI の `GITHUB_TOKEN` では実行できない」ことを既に開示している）。Allstar のようなツールはこの穴を正確に埋める設計目的を持つ。

以下は**私が書く提案内容**であり、実際の台帳への追加・採番・整合性検証（機械強制率の非減少制約との整合）は台帳を保持する担当セッション（agent-spec-template-65）に委ねる（同セッションの依頼どおり）。

> 候補行（番号は担当セッションが確定。想定 #57 以降）:
>
> | 規範（出所） | レベル | 強制手段 | 理由区分 | 整備状況 | 失効期限 | 担当 | 移行先ゲート | 検証箇所 |
> | --- | --- | --- | --- | --- | --- | --- | --- | --- |
> | GitHub 上のブランチ保護・CODEOWNERS・必須ステータスチェック等の実設定が、設定完了後も継続的にポリシーと突合されること（config drift 検出。#5/#12/#19/#22 はいずれも一時点の設定確認にとどまり、設定後の乖離を継続検出しない） | MUST | 人間ゲート（暫定）（継続的ポリシー監視ツール未配線。現行の `scripts/checks/*.sh` は GitHub のライブ設定を観測できない構造的制約を持つ） | — | 未整備（機械検証手段が存在しない。#22 の検証箇所欄が既に開示する「CI の `GITHUB_TOKEN` では管理者読み取り権限が付与できない」という制約と同根） | TBD-HUMAN | TBD-HUMAN | ADR で継続的ポリシー監視ツールを選定し配線する（能力要件: GitHub App またはスケジュール実行によりリポジトリ設定を定期的に読み取り、期待ポリシーとの乖離を検出・通知できること。特定製品名は本行に固定しない。NG-05） | 未実装（本提案作成時点） |

### 3.3 明確に採用しない・人間判断が必要な点

* OSPS Baseline スキャナを blocking gate として `task verify` に追加することは**しない**。ネットワーク依存の新規外部ツール導入は ADR 対象であり、advisory 運用（採用組織の任意実行）にとどめることを推奨する（TBD-HUMAN。「7.」Q-02）。
* OPA/Semgrep による `scripts/checks/*.sh` 全体の再実装は**しない**。既存のシェルスクリプト実装を置き換える判断は architecture-standards.md の技術選定に該当し、ADR が必要（Class B）。本提案はこの選択肢の存在を記録するにとどめる。
* CoSAI Project CodeGuard を正式にスキルとして採用するかどうかは確定しない（TBD-HUMAN。「7.」Q-01）。

---

## 4. 影響範囲

| 観点 | 影響 |
| --- | --- |
| 既存の義務 | **撤廃・反転なし**。standards/ai-governance.md「8.」はすべて SHOULD の参照案内であり、既存の MUST/MUST NOT を変更しない |
| `task verify` | 変更なし（本提案は新規ゲートを追加しない。3.2 は候補提示のみで未実装） |
| コードを含まない採用 | 影響なし |
| 強制台帳 | 新規候補1行を提示（担当セッションが採番・反映するまで未反映） |
| AI エージェントの権限 | 変更なし |
| 外部ツール・ネットワーク依存 | 新規導入なし（本提案は参照追加と評価記録にとどまる） |

---

## 5. バージョン増分の判定

| 文書 | 増分 |
| --- | --- |
| standards/ai-governance.md | 0.2.0 → **0.3.0（提案・MINOR。本 PR で反映済み）** |
| governance/enforcement-ledger.md | 未反映（担当セッションが確定） |

根拠: 既存の MUST/MUST NOT の撤廃・反転・意味変更はない。新設節（外部監査アンカーの参照）は既存ルールに対する後方互換な追加情報であり、憲章「7. 変更管理」バージョニング方針の MINOR 例示に該当する。この判定は提案であり、確定は人間に委ねる。

---

## 6. 検証記録（一次情報の出典）

2026-08-24 に WebSearch で確認した情報源:

* [Cisco's Donation of Project CodeGuard to CoSAI](https://www.coalitionforsecureai.org/ciscos-donation-of-project-codeguard-to-cosai-a-new-chapter-in-securing-ai-generated-code/)
* [GitHub - cosai-oasis/project-codeguard](https://github.com/cosai-oasis/project-codeguard)
* [Project CodeGuard 公式サイト](https://project-codeguard.org/)
* [Cisco's Project CodeGuard Brings OWASP-grade Security To AI Coding Assistants（ルール内訳の記述）](https://dataconomy.com/2025/10/17/ciscos-project-codeguard-brings-owasp-grade-security-to-ai-coding-assistants/)
* [Open Source Project Security Baseline（公式）](https://baseline.openssf.org/)
* [GitHub - ossf/security-baseline](https://github.com/ossf/security-baseline)
* [OpenSSF Tech Talk Recap: Using the OSPS Baseline to Navigate Standards and Regulations](https://openssf.org/blog/2025/05/06/openssf-tech-talk-recap-using-the-osps-baseline-to-navigate-standards-and-regulations/)
* [GitHub - ossf/allstar](https://github.com/ossf/allstar)
* [Introducing the Allstar GitHub App – OpenSSF](https://openssf.org/blog/2021/08/11/introducing-the-allstar-github-app/)
* [NIST: Secure Software Development Practices for Generative AI and Dual-Use Foundation Models（SP 800-218A 発表）](https://www.nist.gov/news-events/news/2024/07/secure-software-development-practices-generative-ai-and-dual-use-foundation)
* [NIST SP 800-218A（final）— CSRC](https://csrc.nist.gov/pubs/sp/800/218/a/final)
* [GitHub - cosai-oasis/secure-ai-tooling（CoSAI Risk Map）](https://github.com/cosai-oasis/secure-ai-tooling)
* [Operationalizing the CoSAI Risk Map (CoSAI-RM) – Coalition for Secure AI](https://www.coalitionforsecureai.org/operationalizing-the-cosai-risk-map-cosai-rm/)

---

## 7. 未解決事項

| ID | 種別 | 内容 | 必要な判断 |
| --- | --- | --- | --- |
| Q-01 | 採用可否未確定 | CoSAI Project CodeGuard を SKILLS.md の枠組みでスキルとして正式採用するか | 採用組織が評価（ライセンス・保守状況・自組織のエージェント構成との適合性を含む）。本提案は「補完関係にある」ことの確認までにとどめる |
| Q-02 | 採用可否未確定 | OSPS Baseline スキャナを advisory ジョブとして CI に配線するか | 採用組織が判断。ネットワーク依存・新規外部アクション導入のため ADR 推奨 |
| Q-03 | 台帳の反映 | 「3.2」の候補行の実際の採番・反映 | 担当セッション（台帳を保持）が、並行実装中の他行（lint 等）との採番調整後に反映 |
| Q-04 | OPA/Semgrep による強制エンジンの刷新 | `scripts/checks/*.sh` を OPA/Semgrep ベースへ再実装するか | Class B（architecture-standards.md の技術選定）。本提案の範囲外。着手する場合は別途 ADR |

**上記が未解決の間、本提案の値を確定として扱いません**（governance/proposals/gp-0005-sast-gate.md「7.」の OUT-03 と同じ方針）。

---

## 8. 承認

| 項目 | 内容 |
| --- | --- |
| 起案者 | claude-code（Sonnet 5） |
| 承認者・承認日 | 未承認（本提案は Proposed） |
| 定足数の充足 | 未充足（承認待ち） |
| 確定結果 | 未確定 |

## 9. 変更履歴

| 日付 | 変更者 | 変更内容 | 理由 |
| --- | --- | --- | --- |
| 2026-08-24 | claude-code (Sonnet 5) | 初版作成、Proposed に設定 | ユーザーが持ち込んだ外部レビュー（層別フレームワーク採用の推奨構成）の妥当性検証と対応 |
