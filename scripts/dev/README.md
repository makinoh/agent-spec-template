# scripts/dev/ — 非ゲートの開発補助スクリプト

* 変更クラス: **C**（[development-process.md](../../development-process.md)「1.」対象パス対応表）
* 上位規範: [constitution.md](../../constitution.md)／[AGENTS.md](../../AGENTS.md)「7. 品質ゲート」

`scripts/**` は既定で **Class A**（品質ゲートの実体）です。本ディレクトリはその唯一の例外で、
**ゲート・CI・統治に関与しない**開発補助のみを置きます（過剰ゲートの回避）。
ゲートに少しでも関与するスクリプトを本ディレクトリに置いてはなりません（MUST NOT）。
強制を弱める抜け道になるためです（憲章「自己修正ループの防止」）。

---

## ツール差し替えフック（採用組織が配線する）

`task verify` の一部のゲートは、**採用スタックが決まらないと正しいコマンドを決められない**ため、
特定製品名を固定せず、環境変数または本ディレクトリの実行可能スクリプトで解決します。
どちらも無い場合、当該ゲートは「不合格」ではなく「未配線」として正直に警告します
（憲章「8. ブートストラップ規定」：未整備の強制手段を整備済みであるかのように扱わない）。

| フック | 環境変数 | 呼び出し元 | 未配線時の挙動 |
| --- | --- | --- | --- |
| `scripts/dev/sast-tool.sh` | `SAST_CMD` | [scripts/checks/sast.sh](../checks/sast.sh) | 警告して通過（強制台帳 #40） |
| `scripts/dev/arch-boundary-tool.sh` | `ARCH_BOUNDARY_CMD` | [scripts/checks/arch-boundaries.sh](../checks/arch-boundaries.sh) | 警告して通過（強制台帳 #52） |
| `scripts/dev/build-tool.sh` | `BUILD_CMD` | [scripts/checks/build.sh](../checks/build.sh) | スタック自動検出へフォールバック |

規約:

* 環境変数が優先されます。次に本ディレクトリの実行可能スクリプト（`chmod +x` が必要）。
* **終了コードはそのまま伝播します。** 差し替えはゲートの緩和ではありません（失敗は失敗）。
* 何を実行したかは常に出力されます（黙って別物を実行したように見せない）。

`BUILD_CMD` は特に、既にビルド・テストの入口を持つ既存リポジトリへ本テンプレートを導入する際に
使います（`npm ci` や `pytest` をリポジトリ直下で素で叩く自動検出が実態と合わないケース）。
詳細は既存プロジェクト向けの導入手順書 `ADOPTION-EXISTING.md` を参照してください。

例（コミットして版管理します。実行権限を忘れないこと）:

```bash
cat > scripts/dev/build-tool.sh <<'SH'
#!/usr/bin/env bash
set -eu
make lint
make test
SH
chmod +x scripts/dev/build-tool.sh
```
