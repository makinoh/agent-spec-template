#!/usr/bin/env python3
"""constitution.md（正本）のバージョン番号を .specify/memory/constitution.md（簡潔ビュー）へ同期する。

WU09-01（GP-0010、未確定）: 簡潔ビューは spec-kit の Constitution Check（/speckit.plan）が参照する
派生サマリだが、追従は SHOULD にとどまり乖離を検知する仕組みが無かった（scripts/checks/constitution-sync.sh
が MUST 相当の検証を追加した）。本スクリプトはその SHOULD 対応（「可能なら生成処理を置く」）として、
"* Version: X.Y.Z" のバージョン番号のみを正本から簡潔ビューへ機械的にコピーする。

意図的なスコープ限定:
  簡潔ビューのバージョン行は "* Version: 0.3.0（Proposed / ドラフト）" のように、正本とは異なる独自の
  注記（括弧内）を持つ。本スクリプトは semver 番号だけを書き換え、注記および他の手書き内容
  （SYNC IMPACT REPORT・原則本文等）には一切触れない。フルコンテンツ生成（原則本文の再生成）は
  本 WU の対象外（GP-0010「WU09-01」参照。理想だが本スクリプトはその最小実装にとどめる）。

使い方:
    python scripts/sync_constitution_version.py            # 簡潔ビューのバージョン行を書き換える
    python scripts/sync_constitution_version.py --check    # 差分の有無のみ検査する（CI 用。差分があれば exit 1）
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "constitution.md"
VIEW = ROOT / ".specify" / "memory" / "constitution.md"

SOURCE_VERSION_RE = re.compile(r"^\* Version:\s*(\d+\.\d+\.\d+)")
VIEW_LINE_RE = re.compile(r"^(\* Version:\s*)(\d+\.\d+\.\d+)(.*)$")


def extract_source_version(text: str) -> str:
    for line in text.splitlines():
        m = SOURCE_VERSION_RE.match(line)
        if m:
            return m.group(1)
    raise SystemExit(f"{SOURCE}: '* Version: X.Y.Z' 形式のバージョン行が見つかりません")


def sync(check: bool) -> int:
    source_version = extract_source_version(SOURCE.read_text(encoding="utf-8"))
    view_text = VIEW.read_text(encoding="utf-8")
    lines = view_text.splitlines(keepends=True)

    changed = False
    found = False
    new_lines: list[str] = []
    for line in lines:
        stripped = line[:-1] if line.endswith("\n") else line
        m = VIEW_LINE_RE.match(stripped) if not found else None
        if m:
            found = True
            prefix, current_version, suffix = m.groups()
            if current_version != source_version:
                changed = True
                newline = "\n" if line.endswith("\n") else ""
                new_lines.append(f"{prefix}{source_version}{suffix}{newline}")
                continue
        new_lines.append(line)

    if not found:
        raise SystemExit(f"{VIEW}: '* Version: X.Y.Z' 形式のバージョン行が見つかりません")

    if check:
        if changed:
            print(
                f"drift: {VIEW.relative_to(ROOT)} は {SOURCE.relative_to(ROOT)} "
                f"(v{source_version}) に追従していません",
                file=sys.stderr,
            )
            return 1
        print(f"OK: {VIEW.relative_to(ROOT)} は v{source_version} と一致しています")
        return 0

    if changed:
        VIEW.write_text("".join(new_lines), encoding="utf-8")
        print(
            f"更新しました: {VIEW.relative_to(ROOT)} のバージョン番号を v{source_version} に"
            " 同期しました（注記・他の内容は変更していません）"
        )
    else:
        print(f"変更なし: {VIEW.relative_to(ROOT)} は既に v{source_version} と一致しています")
    return 0


def main() -> int:
    check = "--check" in sys.argv[1:]
    return sync(check)


if __name__ == "__main__":
    raise SystemExit(main())
