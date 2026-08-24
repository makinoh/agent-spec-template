#!/usr/bin/env python3
"""Class A/B PR の差分規模計測（development-process.md「1.」新設 MUST NOT／WU-08）。

governance/proposals/gp-0009-human-gate-diff-size-limit.md（GP-0009）。

根拠: 承認は「作成者以外1名」で定義されているが、AI 駆動で PR 量が増えると承認は形骸化する
（人間がレビューし切れない規模の差分を「承認」しても、実質的なレビューは行われていない）。
対策は人間を増やすことではなく、**人間ゲートが機能する条件（レビュー可能な差分規模）を
機械的に強制すること**である（constitution.md「3. 基本原則」検証手段の選択）。

現時点では上限値そのものが未確定（WU08-01: 数値の発明を禁止。TBD-HUMAN）であるため、
本スクリプトは既定では **advisory（助言のみ・非ブロッキング）** で動作する。
環境変数 DIFF_SIZE_LIMIT_CLASS_A / DIFF_SIZE_LIMIT_CLASS_B が整数として設定された場合に限り、
実際に上限超過を検査して非ゼロ終了する（hard-fail）。どちらの環境変数も
Taskfile.yml / .github/workflows/verify.yml では設定していない（＝現状は常に advisory）。
人間が上限値を確定した時点で、当該ワークフロー側にこれらの環境変数を設定することで
そのまま hard-fail ゲートへ移行できる（強制台帳の「移行先ゲート」列を参照）。

計測方法:
  - 変更行数 = 追加行数 + 削除行数（git diff --numstat の加算）。
    追加のみを数える設計も検討したが、削除もレビュアの検証コスト（既存動作を壊さないかの
    確認）を要するため、レビュー負荷への近似としては加算+削除の方が実態に近いと判断した
    （governance/proposals/gp-0009-human-gate-diff-size-limit.md「設計判断」参照）。
  - 対象パスの Class A/B 判定は scripts/checks/pr_governance.sh の $gov（Class A 相当）／
    $ab（Class A∪B 相当）正規表現を Python へ概念的に移植したもの（重複だが独自に発明しない。
    development-process.md「1.」対象パス表との既知の近似の限界は gp-0009 に明記する）。
  - 生成物・ロックファイル等、レビュー対象外の差分は除外する（WU08-02）。除外リストの変更は
    Class A として扱う（scripts/** は development-process.md「1.」表により既定で Class A）。

waiver 連携（外部レビュー指摘・2026-08-24。文書と実装の乖離の是正）:
  development-process.md「5.」と強制台帳 #46、および本スクリプト自身のエラーメッセージは、
  上限超過時の合法的な通過手段として「変更を分割するか、governance/waivers/ に登録された
  時限的な適用除外を要する」と案内していた。しかし本スクリプトは waiver を一切読んでおらず、
  案内された逃げ道は実装上存在しなかった（統治文書が「整備済み」と述べる手段が実際には
  機能しない状態＝憲章「8. ブートストラップ規定」が禁じる状態）。
  この乖離は既存リポジトリへの導入（brownfield）で最初に顕在化する: テンプレート一式を
  既存リポジトリへ重ねる導入 PR は、それ自体が数千行規模の Class A 変更になり、分割しても
  「統治文書一式」という不可分な単位を Class A 200行に収めることはできない。逃げ道が
  無ければ、採用者は上限を引き上げるか governance-gate.yml を外すしかなく、いずれも
  「自らの変更で失敗したゲートを回避目的で弱める」（憲章「6.」MUST NOT）に該当してしまう。
  そこで governance/waivers/README.md「機械可読な紐付け」の既存規約（check_governance_metrics.py
  が先行実装）を、共通ローダ scripts/waivers.py 経由で本チェックにも適用する。
  対象ゲート識別子は Class ごとに分ける（Class B 向けの waiver が Class A を素通しさせない）:
      diff-size.class-a  /  diff-size.class-b
  waiver は期限必須（無期限禁止）で、`expires` にプレースホルダを書いたものは常に無効。

使い方:
    python scripts/check_diff_size.py
    BASE_SHA=<sha> HEAD_SHA=<sha> python scripts/check_diff_size.py
    DIFF_SIZE_LIMIT_CLASS_A=800 DIFF_SIZE_LIMIT_CLASS_B=1500 python scripts/check_diff_size.py
"""
from __future__ import annotations

import datetime
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"

sys.path.insert(0, str(SCRIPTS))
from waivers import find_active_waiver  # noqa: E402  (gate-linked waiver の照合は scripts/waivers.py が正本)

# gate-linked waiver の対象ゲート識別子（governance/waivers/README.md「機械可読な紐付け」に登録）。
# Class ごとに分けることで、Class B 向けに発行した waiver が Class A の超過まで通過させることを防ぐ。
TARGET_CHECK_ID = {"A": "diff-size.class-a", "B": "diff-size.class-b"}

# --- パス分類（scripts/checks/pr_governance.sh の $gov / $ab を概念的に移植。独自発明ではない） ---
# GOV_RE: 統治・強制機構の中核（development-process.md「1.」対象パス表の Class A 行の近似）。
# AB_RE : Class A ∪ B の近似（同表の Class A 行 + architecture/・adr/ を追加）。
# 既知の限界: 両者とも development-process.md「1.」の全項目（CODEX.md/OPENHANDS.md/TAKT.md/
# agents/ 等）を網羅していない（pr_governance.sh 自身が既に持つ近似をそのまま引き継いだため）。
GOV_RE = re.compile(
    r"^(constitution\.md|adr-rules\.md|adr-template(-minimal)?\.md|"
    r"\.specify/memory/constitution\.md|governance/|standards/|\.github/|"
    r"AGENTS\.md|CLAUDE\.md|GEMINI\.md|SKILLS\.md|Taskfile\.yml|lefthook\.yml|"
    r"\.mise\.toml|scripts/)"
)
AB_RE = re.compile(
    r"^(constitution\.md|adr-rules\.md|adr-template(-minimal)?\.md|governance/|"
    r"standards/|\.github/|AGENTS\.md|CLAUDE\.md|GEMINI\.md|SKILLS\.md|"
    r"architecture/|adr/|Taskfile\.yml|lefthook\.yml|\.mise\.toml|scripts/)"
)

# --- 除外リスト（生成物・ロックファイル。WU08-02）。実例のみ列挙し仮説上のパターンは含めない。 ---
EXCLUDE_EXACT = {
    # scripts/generate_adr_index.py が生成する派生サマリ（adr-rules.md「4. 索引」）。手編集禁止。
    "adr/INDEX.md",
    # tokens/build.mjs が tokens/tokens.json から生成（standards/design-tokens.md「6.」）。
    # UI スタック未採用の現時点では存在しないが、活性化後に備えてあらかじめ除外する。
    "src/styles/tokens.css",
    "src/styles/media.css",
    "src/styles/tokens.d.ts",
}
# ロックファイルはリポジトリ内のどの階層にあってもファイル名一致で除外する
# （将来の UI スタック / パッケージマネージャ採用に備えた汎用パターン。現時点では未採用のため空振り）。
EXCLUDE_BASENAME = {
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock",
}


def is_excluded(path: str) -> bool:
    if path in EXCLUDE_EXACT:
        return True
    if Path(path).name in EXCLUDE_BASENAME:
        return True
    return False


def classify(path: str) -> str | None:
    """Class A → "A" / Class B（A以外でAB_REに該当） → "B" / 対象外 → None。"""
    if GOV_RE.match(path):
        return "A"
    if AB_RE.match(path):
        return "B"
    return None


def _run_git(args: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", *args], cwd=ROOT, capture_output=True, text=True
    )


def git_numstat() -> list[tuple[int, int, str]]:
    """(追加行数, 削除行数, パス) のリストを返す。

    BASE_SHA/HEAD_SHA は .github/workflows/verify.yml が verify:pr ステージへ既に配線済みの値
    （scripts/checks/pr_governance.sh と同一）。ローカルでは scripts/checks/pr_governance.sh と
    同じフォールバック（origin/main が無ければ HEAD~1）を用いる。新規の環境変数は追加しない。
    """
    base = os.environ.get("BASE_SHA", "origin/main")
    head = os.environ.get("HEAD_SHA", "HEAD")

    r = _run_git(["diff", "--numstat", base, head])
    if r.returncode != 0 or not r.stdout.strip():
        r = _run_git(["diff", "--numstat", "HEAD~1"])
    if r.returncode != 0 or not r.stdout.strip():
        return []

    rows: list[tuple[int, int, str]] = []
    for line in r.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) != 3:
            continue
        add_s, del_s, path = parts
        # バイナリファイルは git diff --numstat が "-" を返す。行数換算できないため 0 として扱う
        # （バイナリの差分規模はレビュー行数という尺度になじまないため計上対象外とする設計判断）。
        add = int(add_s) if add_s.isdigit() else 0
        deletion = int(del_s) if del_s.isdigit() else 0
        rows.append((add, deletion, path))
    return rows


def parse_limit(env_name: str) -> int | None:
    """未設定・空・'TBD-HUMAN' は None（advisory のみ）。整数以外は無視して advisory 継続。"""
    v = os.environ.get(env_name, "").strip()
    if not v or v == "TBD-HUMAN":
        return None
    try:
        return int(v)
    except ValueError:
        print(
            f"⚠ {env_name}={v!r} は整数として解釈できないため無視する（advisory 動作を継続）",
            file=sys.stderr,
        )
        return None


def main() -> int:
    rows = git_numstat()
    if not rows:
        print("advisory: diff not detected — skipping diff-size measurement", file=sys.stderr)
        print("✓ diff-size (no diff)")
        return 0

    totals = {"A": 0, "B": 0}
    excluded_total = 0
    per_file: list[tuple[str, int, str]] = []
    for add, deletion, path in rows:
        lines = add + deletion
        if is_excluded(path):
            excluded_total += lines
            continue
        cls = classify(path)
        if cls is None:
            continue
        totals[cls] += lines
        per_file.append((cls, lines, path))

    print(
        f"diff-size: Class A 対象変更行数（追加+削除、除外適用後） = {totals['A']} 行",
        file=sys.stderr,
    )
    print(
        f"diff-size: Class B 対象変更行数（追加+削除、除外適用後） = {totals['B']} 行",
        file=sys.stderr,
    )
    print(
        f"diff-size: 除外（生成物/ロックファイル）行数 = {excluded_total} 行（計上対象外）",
        file=sys.stderr,
    )
    for cls, lines, path in sorted(per_file, key=lambda r: (-r[1], r[2])):
        print(f"  [{cls}] {lines:>5}  {path}", file=sys.stderr)

    limit_a = parse_limit("DIFF_SIZE_LIMIT_CLASS_A")
    limit_b = parse_limit("DIFF_SIZE_LIMIT_CLASS_B")

    today = datetime.date.today().isoformat()
    failed: list[tuple[str, str]] = []  # (class, 説明)
    waived: list[str] = []

    for cls, limit in (("A", limit_a), ("B", limit_b)):
        if limit is None:
            print(
                f"diff-size: Class {cls} 上限は未設定（TBD-HUMAN）— advisory のみ、hard-fail しない",
                file=sys.stderr,
            )
            continue
        print(f"diff-size: Class {cls} 上限 = {limit} 行（設定済み・強制）", file=sys.stderr)
        if totals[cls] <= limit:
            continue
        over = f"Class {cls} 変更行数 {totals[cls]} が上限 {limit} を超過"
        # 有効な waiver（target_check 一致・status=Active・expires が実日付かつ未経過）のみ通過を許す。
        # 無条件のバイパスは設けない（governance/waivers/README.md「有効期限は必須・無期限禁止」）。
        waiver = find_active_waiver(TARGET_CHECK_ID[cls], today)
        if waiver:
            waived.append(f"{over} — governance/waivers/{waiver} により時限的に許容")
        else:
            failed.append((cls, over))

    for w in waived:
        print(f"⚠ {w}", file=sys.stderr)

    if failed:
        for cls, msg in failed:
            print(
                f"✗ {msg}。変更を分割するか、governance/waivers/ に "
                f"target_check={TARGET_CHECK_ID[cls]} の"
                "有効な適用除外（status: Active ＋ expires が未経過の実日付）を登録してください"
                "（development-process.md「5.」／governance/waivers/README.md「機械可読な紐付け」）。",
                file=sys.stderr,
            )
        print(f"✗ diff-size limit exceeded: {len(failed)} 件", file=sys.stderr)
        return 1

    if waived:
        print("✓ diff-size (上限超過を有効な waiver により許容。期限内に解消すること)")
        return 0

    print("✓ diff-size (advisory unless DIFF_SIZE_LIMIT_CLASS_A/B configured)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
