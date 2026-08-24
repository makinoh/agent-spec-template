#!/usr/bin/env python3
"""gate-linked waiver（機械可読な適用除外）の共通ローダ。

正本規約: governance/waivers/README.md「機械可読な紐付け」。本モジュールは規約を再定義せず、
その照合ロジックだけを一箇所に集約する（SSoT。憲章「3. 基本原則」）。

なぜ共通化するか（外部レビュー指摘・2026-08-24）:
    waiver 照合は当初 scripts/check_governance_metrics.py の内部関数として実装され、
    対象ゲート識別子（target_check）がモジュール定数にハードコードされていた。その後
    scripts/check_diff_size.py が「上限を超える場合は変更を分割するか governance/waivers/ に
    登録された時限的な適用除外を要する」（development-process.md「5.」／台帳 #46）と
    **エラーメッセージと統治文書の両方で案内しながら、waiver を一切読まない**状態のまま
    出荷されていた。つまり文書上の逃げ道が実装に存在せず、上限超過 PR は分割以外に
    合法的な通過手段が無かった（統治文書と実装の乖離。憲章「8. ブートストラップ規定」が
    禁じる「整備済みに見えて機能していない」状態）。
    2つ目の利用者が現れた時点で、規約の解釈が2箇所へ分岐する前に共通化する。

有効な waiver の条件（すべて満たすもののみ「有効」）:
    target_check: 呼び出し側が指定するゲート識別子と完全一致
    status:       Active（大小文字を区別しない）
    expires:      YYYY-MM-DD 形式の実日付で、本日以降

`expires` に `TBD-HUMAN` 等のプレースホルダ・空欄・「—」を書いた waiver は**常に無効**として
扱う。強制台帳のスキーマ（未確定を `TBD-HUMAN` で「非空」と扱う）とは意図的に異なる規約であり、
waiver 自体が「恒久的な逃げ道」になることを構造的に防ぐ（governance/waivers/README.md
「有効期限は必須・無期限禁止」の実質化。無条件のバイパスを設けない MUST NOT）。
"""
from __future__ import annotations

import datetime
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"
WAIVERS_DIR = ROOT / "governance" / "waivers"

sys.path.insert(0, str(SCRIPTS))
from check_enforcement_ledger import DATE_RE  # noqa: E402  (日付書式の定義を再利用。独自に発明しない)
from generate_adr_index import parse_frontmatter  # noqa: E402  (既存のフロントマター簡易パーサを再利用)


def find_active_waiver(target_check: str, today: str | None = None) -> str | None:
    """`target_check` に対する有効な waiver のファイル名を返す。無ければ None。

    `today` は省略時に本日（ローカル日付）。テスト・selftest からの注入を可能にするため引数に取る。
    """
    if today is None:
        today = datetime.date.today().isoformat()
    if not WAIVERS_DIR.exists():
        return None
    for f in sorted(WAIVERS_DIR.glob("*.md")):
        if f.name == "README.md":
            continue
        fm = parse_frontmatter(f.read_text(encoding="utf-8"))
        if not fm:
            continue
        if str(fm.get("target_check", "")).strip() != target_check:
            continue
        if str(fm.get("status", "")).strip().lower() != "active":
            continue
        expires = str(fm.get("expires", "")).strip()
        if not DATE_RE.match(expires):
            continue  # プレースホルダ・空欄は無効（無期限バイパスの防止）
        if expires < today:
            continue  # 失効済み
        return f.name
    return None
