#!/usr/bin/env bash
# Prompt asset lifecycle check (prompts/README.md): プロンプト資産のフロントマター規約を機械点検する。
#
# 各プロンプト資産（prompts/ 配下の .md。README・_TEMPLATE・サブディレクトリの README を除く）は
# status / owner / last_review を持つべき（SHOULD）。資産が無い間は no-op（緑）。
#
# 2026-08-24 の是正（外部レビュー指摘・再現確認済み）:
#   旧実装の判定は awk の `index($0, k":")==1`、すなわち行が「キー:」で始まるかだけを見ており、
#     - 値が空でも通過した（`owner:` だけの行が合格）
#     - `status` が管理語彙の外でも通過した
#     - `last_review` は「陳腐化検知に用いる」と自ら書いておきながら、日付として解釈すらしていなかった
#   ＝ ライフサイクル統治があるように見えて、実際にはキーの存在しか保証していない状態だった。
#   同一リポジトリ内で check_enforcement_ledger.py は失効期限の日付比較を実装し、waivers.py は
#   TBD-HUMAN を無効な期限として扱っているのに、プロンプト資産だけ厳格さが不揃いだった。
#
# 陳腐化の閾値について:
#   「何日でレビューが陳腐化するか」は採用組織が決める運用値であり、AI が発明してはならない
#   （憲章「10.1.3 推測の禁止」。差分規模上限が TBD-HUMAN から始まったのと同じ扱い）。
#   環境変数 PROMPT_REVIEW_MAX_AGE_DAYS（整数）が設定されている場合のみ hard-fail する。
#   未設定時は日付の妥当性のみ検証し、経過日数は参考表示にとどめる（黙って緑にはしない）。
set -eu
. scripts/lib/common.sh
say "Prompt asset lifecycle (status/owner/last_review)"

py - "${PROMPT_REVIEW_MAX_AGE_DAYS:-}" <<'PY'
import datetime
import re
import sys
from pathlib import Path

ROOT = Path.cwd()
PROMPTS = ROOT / "prompts"
STATUS_VOCAB = {"draft", "active", "deprecated", "superseded"}
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
# 採用時に置換される意図的なプレースホルダ（CODEOWNERS の @org/* と同じ扱い。warn であって fail ではない）
PLACEHOLDER_RE = re.compile(r"(採用時に確定|TBD-HUMAN|TODO|<[^>]*>)")

raw_max_age = sys.argv[1].strip() if len(sys.argv) > 1 else ""
max_age = None
if raw_max_age:
    try:
        max_age = int(raw_max_age)
    except ValueError:
        print(f"✗ PROMPT_REVIEW_MAX_AGE_DAYS は整数である必要があります（受領: {raw_max_age!r}）", file=sys.stderr)
        sys.exit(1)


def front_matter(text: str) -> dict[str, str] | None:
    """先頭の --- ブロックを key -> 値（インラインコメント・引用符を除去）で返す。"""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    fm: dict[str, str] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return fm
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*):(.*)$", line)
        if not m:
            continue
        key, val = m.group(1), m.group(2)
        # 引用符で囲まれた値を優先的に取り出す（値の中の # をコメントと誤認しないため）
        q = re.match(r"""\s*(['"])(.*?)\1\s*(#.*)?$""", val)
        if q:
            fm[key] = q.group(2).strip()
        else:
            fm[key] = val.split("#", 1)[0].strip()
    return None  # 閉じ --- が無い＝不正なフロントマター


def assets() -> list[Path]:
    if not PROMPTS.is_dir():
        return []
    out = []
    for p in sorted(PROMPTS.rglob("*.md")):
        if p.name == "README.md" or p.name == "_TEMPLATE.md":
            continue
        out.append(p)
    return out


today = datetime.date.today()
errors: list[str] = []
warns: list[str] = []
placeholder_owners: list[str] = []
ages: list[tuple[int, str]] = []
found = assets()

for p in found:
    rel = p.relative_to(ROOT)
    fm = front_matter(p.read_text(encoding="utf-8"))
    if fm is None:
        errors.append(f"{rel}: フロントマター（--- で囲まれたブロック）が見つかりません")
        continue

    for k in ("status", "owner", "last_review"):
        if k not in fm:
            errors.append(f"{rel}: プロンプト資産に front-matter '{k}' がありません（prompts/README.md ライフサイクル規約）")
        elif fm[k] == "":
            errors.append(f"{rel}: front-matter '{k}' の値が空です（キーの存在だけでは規約を満たしません）")

    status = fm.get("status", "")
    if status and status not in STATUS_VOCAB:
        errors.append(f"{rel}: status '{status}' は管理語彙の外です（{'/'.join(sorted(STATUS_VOCAB))}）")

    owner = fm.get("owner", "")
    if owner and PLACEHOLDER_RE.search(owner):
        placeholder_owners.append(str(rel))

    lr = fm.get("last_review", "")
    if lr and not DATE_RE.match(lr):
        errors.append(f"{rel}: last_review '{lr}' が YYYY-MM-DD 形式ではありません（陳腐化検知に用いるため実日付が必要）")
    elif lr:
        try:
            d = datetime.date.fromisoformat(lr)
        except ValueError:
            errors.append(f"{rel}: last_review '{lr}' は実在しない日付です")
            continue
        if d > today:
            errors.append(f"{rel}: last_review '{lr}' が未来日です（本日 {today.isoformat()}）")
            continue
        age = (today - d).days
        if max_age is not None and age > max_age:
            errors.append(
                f"{rel}: last_review から {age} 日経過（上限 {max_age} 日）— 内容を再確認し last_review を更新してください"
            )
        elif max_age is None:
            ages.append((age, str(rel)))

for w in warns:
    print(f"⚠ {w}", file=sys.stderr)

if placeholder_owners:
    print(
        f"⚠ owner がプレースホルダのままのプロンプト資産が {len(placeholder_owners)} 件"
        f"（例: {placeholder_owners[0]}）— 採用時に保守責任者へ置換してください",
        file=sys.stderr,
    )

if not found:
    print("⚠ no prompt assets yet — lifecycle check skipped (activates when prompts are added)", file=sys.stderr)
elif max_age is None:
    oldest = max(ages)[0] if ages else 0
    print(
        f"⚠ 陳腐化の上限日数が未設定です（PROMPT_REVIEW_MAX_AGE_DAYS。最古の last_review は {oldest} 日前）。"
        "経過日数は表示のみで hard-fail しません。採用組織が値を確定するまで、プロンプト資産の鮮度は"
        "人間レビューで担保してください（強制台帳 #21）。",
        file=sys.stderr,
    )

if errors:
    for e in errors:
        print(f"✗ {e}", file=sys.stderr)
    sys.exit(1)
PY

ok "Prompt asset lifecycle"
