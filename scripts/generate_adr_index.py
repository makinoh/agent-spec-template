#!/usr/bin/env python3
"""adr/ 配下の ADR フロントマターから adr/INDEX.md を生成する。

正本は各 ADR のフロントマター。INDEX.md は手動編集しない派生サマリ（adr-rules.md「4. 索引」）。
逆方向の関係（被参照・被置換）も集約するため、Accepted ADR を改変せずに関係追跡を可能にする。

使い方:
    python scripts/generate_adr_index.py            # adr/INDEX.md を生成
    python scripts/generate_adr_index.py --check     # 生成結果と既存の差分を検査（CI 用、差分があれば exit 1）

依存: PyYAML（推奨）。未導入時はスカラ/単純リストの簡易パーサにフォールバックする。
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ADR_DIR = Path(__file__).resolve().parent.parent / "adr"
INDEX_PATH = ADR_DIR / "INDEX.md"
FILENAME_RE = re.compile(r"^adr-(\d{4})-[a-z0-9]+(?:-[a-z0-9]+)*\.md$")


def parse_frontmatter(text: str) -> dict:
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end].strip("\n")
    try:
        import yaml  # type: ignore

        data = yaml.safe_load(block) or {}
        return data if isinstance(data, dict) else {}
    except Exception:
        # 簡易フォールバック（# コメント除去、key: value とインライン [a, b] のみ）
        data: dict = {}
        for line in block.splitlines():
            line = re.sub(r"\s+#.*$", "", line).rstrip()
            m = re.match(r"^([A-Za-z0-9_\-]+):\s*(.*)$", line)
            if not m:
                continue
            key, raw = m.group(1), m.group(2).strip()
            if raw.startswith("[") and raw.endswith("]"):
                inner = raw[1:-1].strip()
                data[key] = [v.strip() for v in inner.split(",") if v.strip()] if inner else []
            else:
                data[key] = raw.strip('"').strip("'")
        return data


def collect() -> list[dict]:
    rows = []
    for path in sorted(ADR_DIR.glob("adr-*.md")):
        if not FILENAME_RE.match(path.name):
            continue
        fm = parse_frontmatter(path.read_text(encoding="utf-8"))
        fm["_file"] = path.name
        rows.append(fm)
    return rows


def render(rows: list[dict]) -> str:
    lines = [
        "# ADR 索引（自動生成 — 手動編集しない）",
        "",
        "> 本ファイルは `scripts/generate_adr_index.py` が生成する派生サマリです。",
        "> 正本は各 ADR のフロントマター（adr-rules.md「4. 索引」）。手動で編集しないでください。",
        "",
        "| ID | タイトル | Status | Scope | 最終更新 | ファイル |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for r in rows:
        rid = str(r.get("id", "")).strip()
        lines.append(
            f"| {rid} | {str(r.get('title','')).strip()} | {str(r.get('status','')).strip()} "
            f"| {str(r.get('scope','')).strip()} | {str(r.get('last_updated','')).strip()} "
            f"| [{r['_file']}]({r['_file']}) |"
        )
    # 関係グラフ（逆方向を含む集約）
    lines += ["", "## 関係グラフ", ""]
    rel_lines = []
    for r in rows:
        rid = str(r.get("id", "")).strip()
        for key in ("depends_on", "supersedes", "superseded_by", "relates_to"):
            for tgt in r.get(key) or []:
                rel_lines.append(f"- `{rid}` —{key}→ `{tgt}`")
    lines += rel_lines if rel_lines else ["（関係なし）"]
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    rows = collect()
    content = render(rows)
    if "--check" in sys.argv:
        current = INDEX_PATH.read_text(encoding="utf-8") if INDEX_PATH.exists() else ""
        if current.strip() != content.strip():
            print("adr/INDEX.md が最新ではありません。`python scripts/generate_adr_index.py` を実行してください。")
            return 1
        print("adr/INDEX.md は最新です。")
        return 0
    INDEX_PATH.write_text(content.rstrip("\n") + "\n", encoding="utf-8")
    print(f"生成: {INDEX_PATH}（{len(rows)} 件）")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
