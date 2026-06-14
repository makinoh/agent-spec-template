#!/usr/bin/env python3
"""ADR 本文の必須セクション＋フロントマター値制約の検査（adr-rules.md「3.」「4.」/ constitution.md「8.」）。

frontmatter.sh が「キーの存在」を検査するのに対し、本スクリプトは「値」と「本文構造」を検査して、
憲章 8 章・adr-rules.md 4 章が要求する機械検証可能な制約を実際に強制する。

常時検査（全 status）:
  - id（ADR-NNNN）の番号がファイル名（adr-NNNN-…）と一致する
  - profile ∈ {minimal, full}
  - date / last_updated が YYYY-MM-DD 形式（未記入プレースホルダ "YYYY-MM-DD" は status≠accepted のみ許容）
  - scope ∈ {organization, division, department, product, project}（空 "" は status≠accepted のみ許容）
  - H1 が `# ADR-NNNN:` 形式で番号が一致する
  - プロファイル別の必須セクション見出しが存在する

status==accepted のとき追加で検査:
  - decision-makers が非空
  - review_after が非空かつ YYYY-MM-DD 形式

proposed 段階のテンプレート ADR（adr-0000 等。scope/date 未記入）を不合格にしないため、厳格な値検査
（実日付・scope enum・承認メタの非空）は accepted に限定する（adr-rules.md「4.」の条件設計に整合）。

使い方:
    python scripts/check_adr_content.py      # 違反があれば exit 1
"""
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

# 同じ scripts/ にある索引生成器のフロントマター parser を再利用（PyYAML→簡易 parser フォールバック）。
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from generate_adr_index import parse_frontmatter, FILENAME_RE  # noqa: E402

ADR_DIR = Path(__file__).resolve().parent.parent / "adr"
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
PLACEHOLDER_DATE = "YYYY-MM-DD"
SCOPE_ENUM = {"organization", "division", "department", "product", "project"}
PROFILE_ENUM = {"minimal", "full"}

# adr-rules.md「3. 必須セクション」より（タイトル H1 は別途検査）。
COMMON_SECTIONS = ["変更履歴", "コンテキスト", "意思決定事項", "選択肢", "決定（案）", "承認", "結果"]
FULL_SECTIONS = ["適用スコープ", "評価観点", "検討項目", "評価", "関連ADR", "参考資料"]


def _s(v) -> str:
    return str(v).strip().strip('"').strip("'")


def split_body(text: str) -> str:
    """先頭の YAML フロントマター（--- … ---）を除いた本文を返す。"""
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end != -1:
            nl = text.find("\n", end + 1)
            return text[nl + 1:] if nl != -1 else ""
    return text


def headings(body: str) -> list[str]:
    out = []
    for line in body.splitlines():
        m = re.match(r"^#{1,6}\s+(.*?)\s*$", line)
        if m:
            out.append(m.group(1).strip())
    return out


def has_section(hs: list[str], name: str) -> bool:
    # 完全一致、または「名称（完全プロファイルのみ）」等の補足付き見出しを許容。
    # 「評価」と「評価観点」を取り違えないよう startswith は "名称（" に限定する。
    return any(h == name or h.startswith(name + "（") for h in hs)


def check_file(path: Path) -> list[str]:
    errs: list[str] = []
    m = FILENAME_RE.match(path.name)
    if not m:
        return errs  # 命名規則違反は adr.sh が検出するため二重報告しない
    num = m.group(1)
    text = path.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    hs = headings(split_body(text))

    status = _s(fm.get("status", "")).lower()
    accepted = status == "accepted"

    rid = _s(fm.get("id", ""))
    if rid != f"ADR-{num}":
        errs.append(f"id '{rid}' がファイル名の番号 {num} と一致しません（期待: ADR-{num}）")

    profile = _s(fm.get("profile", ""))
    if profile not in PROFILE_ENUM:
        errs.append(f"profile '{profile}' が不正です（minimal | full）")

    for k in ("date", "last_updated"):
        v = _s(fm.get(k, ""))
        if DATE_RE.match(v) or ((not accepted) and v == PLACEHOLDER_DATE):
            continue
        hint = "" if accepted else "（未記入なら 'YYYY-MM-DD'）"
        errs.append(f"{k} '{v}' が YYYY-MM-DD 形式ではありません{hint}")

    scope = _s(fm.get("scope", ""))
    if scope not in SCOPE_ENUM and not ((not accepted) and scope == ""):
        errs.append(f"scope '{scope}' が不正です（organization|division|department|product|project）")

    if accepted:
        if not fm.get("decision-makers"):
            errs.append("status=accepted ですが decision-makers が空です（adr-rules.md「4.」）")
        ra = _s(fm.get("review_after", ""))
        if not DATE_RE.match(ra):
            errs.append(f"status=accepted ですが review_after '{ra}' が空または YYYY-MM-DD ではありません")

    if not any(re.match(rf"^ADR-{num}\s*[:：]", h) for h in hs):
        errs.append(f"H1 見出し『# ADR-{num}: …』が見つかりません")

    required = COMMON_SECTIONS + (FULL_SECTIONS if profile == "full" else [])
    for s in required:
        if not has_section(hs, s):
            errs.append(f"必須セクション『{s}』の見出しがありません（profile={profile or '?'}）")

    return errs


def main() -> int:
    if not ADR_DIR.is_dir():
        print("✗ adr/ ディレクトリがありません")
        return 1
    files = sorted(ADR_DIR.glob("adr-*.md"))
    total = 0
    for path in files:
        for e in check_file(path):
            total += 1
            print(f"✗ {path.name}: {e}")
    if total:
        print(f"ADR 本文・フロントマター値検査: {total} 件の違反")
        return 1
    print(f"ADR 本文・フロントマター値検査: OK（{len(files)} 件）")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
