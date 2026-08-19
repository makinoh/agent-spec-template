#!/usr/bin/env python3
"""強制台帳のスキーマ整合性検査（constitution.md「3. 基本原則」検証手段の選択／「8.」ブートストラップ規定の機械化）。

WU-02（governance/proposals/gp-0003-enforcement-ledger-schema.md）。

governance/enforcement-ledger.md の表本体について、以下を検査する:

  1. 強制手段が「人間ゲート（不可避）」を含む行は、理由区分（(a)/(b)/(c)）が空でない。
  2. 強制手段が「人間ゲート（暫定）」を含む行は、失効期限・担当・移行先ゲートがすべて空でない
     （未確定を示す `TBD-HUMAN` は「空でない」として扱う。空欄・「—」・「-」は不可）。
  3. 失効期限が実日付（YYYY-MM-DD）である行は、本日以前であってはならない（超過ゼロ）。

あわせて、憲章本文の（MUST）／（MUST NOT）出現数と台帳行数を突合する非ブロッキングの助言を出す
（「AIエージェント向けクイックリファレンス」節は憲章「1.」により明示的に非規範とされているため除外）。
この突合は 1 MUST = 1 行の厳密な対応を保証するものではなく、定期見直し（憲章「7.」）を補助する目安に
とどまる（過大な精度を主張しない。constitution.md「10.1.5」の趣旨に整合）。

使い方:
    python scripts/check_enforcement_ledger.py      # 違反があれば exit 1
"""
from __future__ import annotations

import datetime
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LEDGER = ROOT / "governance" / "enforcement-ledger.md"
CONSTITUTION = ROOT / "constitution.md"

# 表本体の行のみを対象とする。# 列が数字（**強調**の有無を許容）であることで
# ヘッダ行（"| # | ..."）・区切り行（"| --- | ..."）・改正履歴中の箇条書きを除外する。
ROW_RE = re.compile(
    r"^\|\s*\*{0,2}(?P<num>\d+[a-z]?)\*{0,2}\s*\|"
    r"(?P<norm>[^|]*)\|(?P<level>[^|]*)\|(?P<means>[^|]*)\|"
    r"(?P<reason>[^|]*)\|(?P<status>[^|]*)\|"
    r"(?P<expiry>[^|]*)\|(?P<owner>[^|]*)\|(?P<target>[^|]*)\|"
    r"(?P<verify_loc>[^|]*)\|?\s*$"
)
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
EMPTY = {"", "—", "-", "―"}
GATE_PERMANENT = "人間ゲート（不可避）"
GATE_BOOTSTRAP = "人間ゲート（暫定）"


def _s(v: str) -> str:
    return v.strip()


def load_rows() -> list[dict]:
    rows = []
    for line in LEDGER.read_text(encoding="utf-8").splitlines():
        m = ROW_RE.match(line)
        if not m:
            continue
        row = {k: _s(v) for k, v in m.groupdict().items()}
        rows.append(row)
    return rows


def check_rows(rows: list[dict]) -> list[str]:
    errors = []
    today = datetime.date.today().isoformat()
    for r in rows:
        means = r["means"]
        num = r["num"]
        if GATE_PERMANENT in means and r["reason"] in EMPTY:
            errors.append(f"#{num}: {GATE_PERMANENT}だが理由区分が空")
        if GATE_BOOTSTRAP in means:
            for field, label in (("expiry", "失効期限"), ("owner", "担当"), ("target", "移行先ゲート")):
                if r[field] in EMPTY:
                    errors.append(f"#{num}: {GATE_BOOTSTRAP}だが{label}が空")
            expiry = r["expiry"]
            if DATE_RE.match(expiry) and expiry < today:
                errors.append(f"#{num}: 失効期限 {expiry} を超過（本日 {today}）")
    return errors


def advisory_must_count() -> int:
    """クイックリファレンス節（非規範）を除いた（MUST）／（MUST NOT）出現数。"""
    skip = False
    count = 0
    for line in CONSTITUTION.read_text(encoding="utf-8").splitlines():
        if line.startswith("## AIエージェント向けクイックリファレンス"):
            skip = True
            continue
        if line.startswith("## 用語定義"):
            skip = False
        if skip:
            continue
        count += line.count("（MUST）") + line.count("（MUST NOT）")
    return count


def main() -> int:
    if not LEDGER.exists():
        print(f"✗ {LEDGER} not found", file=sys.stderr)
        return 1
    if not CONSTITUTION.exists():
        print(f"✗ {CONSTITUTION} not found", file=sys.stderr)
        return 1

    rows = load_rows()
    if not rows:
        print("✗ no ledger rows matched — table format may have changed", file=sys.stderr)
        return 1

    errors = check_rows(rows)
    must_count = advisory_must_count()
    print(
        f"advisory: constitution.md 中の（MUST）/（MUST NOT）出現数 {must_count} 件 ／ "
        f"台帳行数 {len(rows)} 件（1 MUST = 1 行の厳密な対応は求めない。定期見直しで確認する）",
        file=sys.stderr,
    )

    if errors:
        for e in errors:
            print(f"✗ {e}", file=sys.stderr)
        print(f"✗ Enforcement ledger schema violations: {len(errors)} 件", file=sys.stderr)
        return 1

    print(f"✓ Enforcement ledger schema ({len(rows)} rows checked)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
