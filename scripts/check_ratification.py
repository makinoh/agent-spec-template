#!/usr/bin/env python3
"""Warn when constitution.md's version has outrun the highest version actually
ratified in governance/decisions/ (外部レビュー指摘・2026-08-21).

なぜ必要か:
    constitution.md のヘッダは「Version: 0.8.0（Proposed / ドラフト。本増分は提案であり、
    governance/decisions/ での確定をもって発効する）」のように、自ら「発効は
    governance/decisions/ での確定をもって」と明記する。つまり governance/decisions/ に
    対応する Accepted 記録がない限り、そのバージョンが授権する内容は未発効のはずである。

    しかし本テンプレートの WU-01〜WU-10（Machine-First Verification 統治改訂）は、
    constitution.md を 0.3.0 → 0.8.0 まで進めた一方、対応する governance/decisions/ の
    確定記録（gd-0005 等）を作成していない（最新の Accepted 記録は GD-0004・target_version
    0.3.0 のまま）。それにもかかわらず、0.4.0〜0.8.0 が導入した原則が授権するはずの
    selftest / diff-size / governance-metrics / constitution-sync / SAST の各ゲートは、
    すでに main へマージされ CI で強制されている。「未発効の規範を機械強制している」状態。

    本チェックはこの乖離を検出する。是正の方法（governance/decisions/ へ遡って確定記録を
    追加するか、strictness を見直すか）は人間の判断であり（憲章「7. 変更管理」／AI は本書
    改正を単独で承認・反映してはならない MUST NOT）、本チェックは advisory（警告のみ・
    exit 0）にとどめる。hard-fail 化する場合、対象は main 自身が現に違反している状態から
    始まるため、その判断も人間に委ねる（TBD-HUMAN。diff-size.sh の閾値未確定と同型の設計）。
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CONSTITUTION = REPO_ROOT / "constitution.md"
DECISIONS_DIR = REPO_ROOT / "governance" / "decisions"

VERSION_RE = re.compile(r"^\* Version:\s*(\d+)\.(\d+)\.(\d+)")
FRONTMATTER_STATUS_RE = re.compile(r"^status:\s*(\S+)", re.MULTILINE)
FRONTMATTER_TARGET_VERSION_RE = re.compile(r"^target_version:\s*(\d+)\.(\d+)\.(\d+)", re.MULTILINE)
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.DOTALL)


def read_constitution_version() -> tuple[int, int, int] | None:
    text = CONSTITUTION.read_text(encoding="utf-8")
    for line in text.splitlines():
        m = VERSION_RE.match(line)
        if m:
            return tuple(int(x) for x in m.groups())  # type: ignore[return-value]
    return None


def read_ratified_versions() -> list[tuple[tuple[int, int, int], Path]]:
    ratified = []
    if not DECISIONS_DIR.is_dir():
        return ratified
    for path in sorted(DECISIONS_DIR.glob("gd-*.md")):
        text = path.read_text(encoding="utf-8")
        fm_match = FRONTMATTER_RE.match(text)
        if not fm_match:
            continue
        frontmatter = fm_match.group(1)
        status_match = FRONTMATTER_STATUS_RE.search(frontmatter)
        target_match = FRONTMATTER_TARGET_VERSION_RE.search(frontmatter)
        if not status_match or not target_match:
            continue
        if status_match.group(1).strip().lower() != "accepted":
            continue
        version = tuple(int(x) for x in target_match.groups())
        ratified.append((version, path))  # type: ignore[arg-type]
    return ratified


def main() -> int:
    current = read_constitution_version()
    if current is None:
        print(f"✗ {CONSTITUTION}: '* Version: X.Y.Z' 形式のバージョン行が見つかりません", file=sys.stderr)
        return 1

    ratified = read_ratified_versions()
    if not ratified:
        print(
            f"⚠ governance/decisions/ に status: Accepted かつ target_version を持つ記録が"
            f" 見つかりません。constitution.md（v{'.'.join(map(str, current))}）の批准状態を確認できません。",
            file=sys.stderr,
        )
        return 0

    highest_version, highest_path = max(ratified, key=lambda item: item[0])
    current_str = ".".join(map(str, current))
    highest_str = ".".join(map(str, highest_version))

    if current > highest_version:
        print(
            f"⚠ constitution.md は v{current_str} だが、governance/decisions/ で批准（Accepted）済みの"
            f" 最高バージョンは v{highest_str}（{highest_path.relative_to(REPO_ROOT)}）にとどまる。",
            file=sys.stderr,
        )
        print(
            "  constitution.md 自身が「Proposed / ドラフト。発効は governance/decisions/ での確定をもって」"
            "と明記する版が未批准のまま存在する。その版が授権する機械強制ゲート（selftest / diff-size /"
            " governance-metrics / constitution-sync / SAST 等）を hard-fail のまま維持してよいかは、"
            " governance/decisions/ へ確定記録を追加するか、方針を見直すか、人間が判断する"
            "（憲章「7. 変更管理」。AI は本書改正を単独で承認・反映してはならない MUST NOT）。",
            file=sys.stderr,
        )
        print(f"⚠ Ratification lag: constitution.md v{current_str} > ratified v{highest_str}（advisory）")
        return 0

    print(f"✓ Ratification sync: constitution.md v{current_str} ≤ ratified v{highest_str}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
