#!/usr/bin/env python3
"""統治健全性メトリクス（機械強制率・暫定人間ゲート残数・期限超過件数）の算出、および
機械強制率の非減少制約を検査する。

governance/proposals/gp-0004-governance-health-metrics.md（統治改訂プロンプト WU-03）。
constitution.md「7. 変更管理」定期見直し／governance/enforcement-ledger.md（強制台帳）に基づく。

--- 算出する3指標 ---

機械強制率
    = (構造的強制 または 機械強制 を「強制手段」列に含む台帳行の件数) / (台帳の全行数)
    強制手段は「＋」で複数手段を併記できる（例: 機械強制（...)＋人間ゲート（不可避））。
    本スクリプトは **inclusive カウント** を採用する: 構造的強制／機械強制のいずれかを
    「含む」時点で分子に算入し、同じ行に人間ゲートが併記されていても減点しない。
    理由: Machine-First Verification（constitution.md「3. 基本原則」）の目的は、既存の人間ゲートに
    機械層を **追加** する漸進的な改善を促すことにある。人間ゲートを完全に除去できた行のみを
    分子に数える exclusive カウントを採ると、「機械層を追加したが人間ゲートは責任の引受のため
    意図的に残す」（例: 台帳 #8, #10, #11, #21, #28。理由区分 (a)/(b) により恒久的に正当）という
    健全な defense-in-depth の追加が指標に反映されず、かえって「人間ゲートを剥がすことだけが
    指標を動かす」という誤ったインセンティブを生む。inclusive カウントはこれを避ける
    （この判断は WU-03 の設計判断であり、strict/exclusive カウントとの比較は
    governance/proposals/gp-0004-governance-health-metrics.md に記録する）。

暫定人間ゲート残数
    = 「強制手段」列に「人間ゲート（暫定）」を含む台帳行の件数。

期限超過件数
    = 上記のうち失効期限（実日付 YYYY-MM-DD）が本日を過ぎている行の件数。
    この値を 0 に強制する（hard fail）のは scripts/check_enforcement_ledger.py の役目
    （台帳 #34）であり、本スクリプトはその値を **観測・報告するのみ** で、重複した
    exit 1 は行わない（WU-03 プロンプトの指示: 「観測性/推移メトリクスの追加であり、
    二重ゲートではない」ことの実装上の反映）。

--- 非減少制約（WU03-01） ---

現在の機械強制率が metrics/governance-health-snapshot.json に保持する baseline を
（分数として厳密に）下回った場合、governance/waivers/ に本チェック向けの有効な waiver
（後述）が存在しない限り exit 1 とする。分数比較は浮動小数点誤差を避けるため
整数の交差乗算で行う。

baseline の更新は本スクリプトの通常実行（verify / verify:fast）では行わない。
`--write-baseline` を明示的に付けて実行した場合のみ、現在値で
metrics/governance-health-snapshot.json を上書きする（基準値の意図的な引き上げ用。
CI からは呼ばれない）。

--- waiver 連携規約（WU03-02） ---

governance/waivers/*.md のうち、フロントマターが次をすべて満たすものを
「本チェック向けの有効な waiver」とみなす（governance/waivers/README.md
「機械可読な紐付け」節を参照。詳細規約はそちらを正本とする）。

    target_check: governance-metrics.mechanized-rate   （本チェックの固定識別子）
    status: Active                                      （大小文字を区別しない）
    expires: YYYY-MM-DD 形式の実日付で、本日以降であること

`expires` に `TBD-HUMAN` 等のプレースホルダを許さない。強制台帳のスキーマ（未確定は
`TBD-HUMAN` を「非空」として扱う）とは異なり、ここでは waiver 自体が「低下を正当化する
恒久的な逃げ道」になってはならない（waivers/README.md「有効期限は必須・無期限禁止」の
実質化。WU03-02 の MUST NOT：無条件のバイパスを設けない）。該当する waiver が1件でも
見つかれば低下を許容し WARN で通過する（exit 0）。無ければ exit 1 とする。

使い方:
    python scripts/check_governance_metrics.py                # 違反があれば exit 1
    python scripts/check_governance_metrics.py --write-baseline
        # 現在のライブ値で metrics/governance-health-snapshot.json を上書きする。
"""
from __future__ import annotations

import datetime
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPTS = ROOT / "scripts"
SNAPSHOT = ROOT / "metrics" / "governance-health-snapshot.json"
WAIVERS_DIR = ROOT / "governance" / "waivers"

sys.path.insert(0, str(SCRIPTS))
from check_enforcement_ledger import DATE_RE, GATE_BOOTSTRAP, load_rows  # noqa: E402  (WU-02 のパーサ/正規表現を再利用)
from generate_adr_index import parse_frontmatter  # noqa: E402  (既存のフロントマター簡易パーサを再利用)

MECH_TOKENS = ("構造的強制", "機械強制")
TARGET_CHECK_ID = "governance-metrics.mechanized-rate"


def compute_metrics() -> dict:
    rows = load_rows()
    total = len(rows)
    mechanized = sum(1 for r in rows if any(t in r["means"] for t in MECH_TOKENS))
    bootstrap_rows = [r for r in rows if GATE_BOOTSTRAP in r["means"]]
    today = datetime.date.today().isoformat()
    expired = [r for r in bootstrap_rows if DATE_RE.match(r["expiry"]) and r["expiry"] < today]
    return {
        "total_norms": total,
        "mechanized_norms": mechanized,
        "bootstrap_gate_count": len(bootstrap_rows),
        "expired_bootstrap_count": len(expired),
    }


def load_snapshot() -> dict:
    if not SNAPSHOT.exists():
        print(f"✗ {SNAPSHOT} not found — baseline スナップショットが未作成", file=sys.stderr)
        sys.exit(1)
    return json.loads(SNAPSHOT.read_text(encoding="utf-8"))


def write_snapshot(metrics: dict) -> None:
    today = datetime.date.today().isoformat()
    doc = {
        "schema_version": 1,
        "metric": "governance-health.mechanized_rate",
        "source": "governance/enforcement-ledger.md",
        "counting_method": (
            "inclusive: a ledger row counts toward the numerator if its 強制手段 field "
            "contains 構造的強制 or 機械強制, even when a 人間ゲート layer is combined via ＋. "
            "See scripts/check_governance_metrics.py module docstring for rationale."
        ),
        "baseline": {
            "captured_date": today,
            "captured_by": "scripts/check_governance_metrics.py --write-baseline",
            "total_norms": metrics["total_norms"],
            "mechanized_norms": metrics["mechanized_norms"],
            "mechanized_rate": metrics["mechanized_norms"] / metrics["total_norms"],
        },
    }
    SNAPSHOT.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"✓ wrote baseline: {metrics['mechanized_norms']}/{metrics['total_norms']} → {SNAPSHOT}")


def find_active_waiver(today: str) -> str | None:
    if not WAIVERS_DIR.exists():
        return None
    for f in sorted(WAIVERS_DIR.glob("*.md")):
        if f.name == "README.md":
            continue
        fm = parse_frontmatter(f.read_text(encoding="utf-8"))
        if not fm:
            continue
        if str(fm.get("target_check", "")).strip() != TARGET_CHECK_ID:
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


def main() -> int:
    if "--write-baseline" in sys.argv[1:]:
        write_snapshot(compute_metrics())
        return 0

    metrics = compute_metrics()
    snapshot = load_snapshot()
    baseline = snapshot.get("baseline", {})
    base_num = int(baseline.get("mechanized_norms", 0))
    base_den = int(baseline.get("total_norms", 0))
    cur_num = metrics["mechanized_norms"]
    cur_den = metrics["total_norms"]

    if base_den <= 0 or cur_den <= 0:
        print("✗ ledger/baseline の分母が0です（行が検出できていません）", file=sys.stderr)
        return 1

    cur_rate = cur_num / cur_den
    base_rate = base_num / base_den
    print(
        f"機械強制率: {cur_num}/{cur_den} = {cur_rate:.4f}"
        f"（baseline: {base_num}/{base_den} = {base_rate:.4f}, captured {baseline.get('captured_date', '?')}）"
    )
    print(f"暫定人間ゲート残数: {metrics['bootstrap_gate_count']} 件")
    print(f"期限超過件数（観測。強制は check_enforcement_ledger.py が担う）: {metrics['expired_bootstrap_count']} 件")

    # 非減少制約: 整数の交差乗算で厳密比較（浮動小数点誤差を避ける）
    regressed = (cur_num * base_den) < (base_num * cur_den)
    if not regressed:
        print("✓ Governance health metrics（機械強制率は非減少）")
        return 0

    today = datetime.date.today().isoformat()
    waiver = find_active_waiver(today)
    if waiver:
        print(
            f"⚠ 機械強制率が baseline を下回っていますが、有効な waiver を検出しました: "
            f"governance/waivers/{waiver}（低下を許容）",
            file=sys.stderr,
        )
        print("✓ Governance health metrics（waiver により許容）")
        return 0

    print(
        f"✗ 機械強制率が baseline を下回っています（{cur_rate:.4f} < {base_rate:.4f}）。"
        f"governance/waivers/ に target_check={TARGET_CHECK_ID} の有効な waiver がありません。",
        file=sys.stderr,
    )
    print(
        "  正当な低下（新規 MUST 追加に伴う一時的な低下等）であれば governance/waivers/ へ登録してください"
        "（governance/waivers/README.md「機械可読な紐付け」）。",
        file=sys.stderr,
    )
    print(
        "  低下が実装ミス・誤った台帳編集によるものであれば、原因側（enforcement-ledger.md の当該行）を"
        "修正してください（自己修正ループの防止。constitution.md「6.」）。",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
