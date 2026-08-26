#!/usr/bin/env python3
"""統治健全性メトリクス（機械強制率・暫定人間ゲート残数・期限超過件数）の算出、および
機械強制率の非減少制約を検査する。

governance/proposals/gp-0004-governance-health-metrics.md（統治改訂プロンプト WU-03）。
constitution.md「7. 変更管理」定期見直し／governance/enforcement-ledger.md（強制台帳）に基づく。

--- 算出する指標 ---

機械強制率（公称・nominal）
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

機械強制率（実効・effective。2026-08-26 追加。外部レビュー指摘）
    = (構造的強制 または 機械強制 を含み、かつ「整備状況」列が「整備済み」で始まる台帳行の件数)
      / (台帳の全行数)
    公称の機械強制率は「整備状況」列を一切参照しないため、#40（SAST）・#52（アーキ境界）・
    #55（ライセンス）・#56（lint）のような「休眠/活性化のロジックは実装済みだが実ツールは
    未配線＝整備中」の行が満額で分子に計上される。この結果、実際に稼働しているゲートの割合
    （2026-08-26 時点で計測すると公称 74% に対し実効 52% ——約22ポイントの乖離）を公称値が
    覆い隠し、さらに**休眠ゲートの雛形を追加するだけで公称の機械強制率が上昇する**という
    逆インセンティブを生んでいた（正直に人間ゲート行を追加すると公称率は下降し #44 の非減少
    制約に抵触するため、休眠ゲートの追加の方が「安全」になってしまう）。これが理論上の懸念で
    ないことは development-process.md「5.1」が自ら示していた: 力量要件の MUST NOT
    （台帳には未登録だった。#58 として新設）を台帳へ登録しない理由として「登録すれば機械強制率の
    分母だけが増え、実態に反して低下する」と明記しており、指標を守るために規範の可視性を
    犠牲にする自己言及的な事例だった。実効機械強制率を公称値と併記し、非減少制約を**両方**へ
    課すことで、休眠ゲートの追加だけでは指標を満たせないようにする
    （公称側の非減少制約も維持する: defense-in-depth の追加を評価する inclusive カウントの
    利点は失わない。実効側の追加はそれを補完する）。

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
「機械可読な紐付け」節を参照。詳細規約はそちらを正本とする）。照合ロジックそのものは
scripts/waivers.py へ集約した（check_diff_size.py と共有する。規約の解釈が2箇所へ
分岐することを防ぐ。SSoT）。

    target_check: governance-metrics.mechanized-rate             （公称機械強制率。本チェックの固定識別子）
    target_check: governance-metrics.mechanized-rate-effective   （実効機械強制率。2026-08-26 追加）
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

sys.path.insert(0, str(SCRIPTS))
from check_enforcement_ledger import DATE_RE, GATE_BOOTSTRAP, load_rows  # noqa: E402  (WU-02 のパーサ/正規表現を再利用)
from waivers import find_active_waiver  # noqa: E402  (gate-linked waiver の照合は scripts/waivers.py が正本)

MECH_TOKENS = ("構造的強制", "機械強制")
READY_PREFIX = "整備済み"
TARGET_CHECK_ID = "governance-metrics.mechanized-rate"
TARGET_CHECK_ID_EFFECTIVE = "governance-metrics.mechanized-rate-effective"


def _is_ready(status: str) -> bool:
    """整備状況セルが「整備済み」で始まるか（先頭の Markdown 強調 `**` は無視する）。"""
    return status.lstrip("*").strip().startswith(READY_PREFIX)


def compute_metrics() -> dict:
    rows = load_rows()
    total = len(rows)
    mechanized_rows = [r for r in rows if any(t in r["means"] for t in MECH_TOKENS)]
    mechanized = len(mechanized_rows)
    mechanized_effective = sum(1 for r in mechanized_rows if _is_ready(r["status"]))
    bootstrap_rows = [r for r in rows if GATE_BOOTSTRAP in r["means"]]
    today = datetime.date.today().isoformat()
    expired = [r for r in bootstrap_rows if DATE_RE.match(r["expiry"]) and r["expiry"] < today]
    return {
        "total_norms": total,
        "mechanized_norms": mechanized,
        "mechanized_norms_effective": mechanized_effective,
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
        "schema_version": 2,
        "metric": "governance-health.mechanized_rate",
        "source": "governance/enforcement-ledger.md",
        "counting_method": (
            "inclusive (nominal): a ledger row counts toward the numerator if its 強制手段 field "
            "contains 構造的強制 or 機械強制, even when a 人間ゲート layer is combined via ＋, "
            "and regardless of the 整備状況 (readiness) column. "
            "effective: same, but additionally requires 整備状況 to start with 整備済み — a row "
            "whose tool resolution logic exists but has no real tool wired ('整備中'/'未整備', "
            "e.g. dormant SAST/arch-boundary/license/lint gates) does not count. "
            "See scripts/check_governance_metrics.py module docstring for rationale "
            "(2026-08-26: added after an external review found the nominal-only rate could be "
            "satisfied by adding dormant gates alone)."
        ),
        "baseline": {
            "captured_date": today,
            "captured_by": "scripts/check_governance_metrics.py --write-baseline",
            "total_norms": metrics["total_norms"],
            "mechanized_norms": metrics["mechanized_norms"],
            "mechanized_rate": metrics["mechanized_norms"] / metrics["total_norms"],
            "mechanized_norms_effective": metrics["mechanized_norms_effective"],
            "mechanized_rate_effective": metrics["mechanized_norms_effective"] / metrics["total_norms"],
        },
    }
    SNAPSHOT.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"✓ wrote baseline: nominal {metrics['mechanized_norms']}/{metrics['total_norms']}"
        f"、effective {metrics['mechanized_norms_effective']}/{metrics['total_norms']} → {SNAPSHOT}"
    )


def _check_non_decreasing(
    label: str, cur_num: int, cur_den: int, base_num: int, base_den: int, target_check: str
) -> list[str]:
    """非減少制約を検査する（整数の交差乗算で厳密比較。浮動小数点誤差を避ける）。

    違反かつ有効な waiver が無い場合のみエラーメッセージのリストを返す（空リスト＝合格）。
    """
    cur_rate = cur_num / cur_den
    base_rate = base_num / base_den
    regressed = (cur_num * base_den) < (base_num * cur_den)
    if not regressed:
        print(f"✓ {label}は非減少（{cur_rate:.4f} >= {base_rate:.4f}）")
        return []

    today = datetime.date.today().isoformat()
    waiver = find_active_waiver(target_check, today)
    if waiver:
        print(
            f"⚠ {label}が baseline を下回っていますが、有効な waiver を検出しました: "
            f"governance/waivers/{waiver}（低下を許容）",
            file=sys.stderr,
        )
        return []

    return [
        f"✗ {label}が baseline を下回っています（{cur_rate:.4f} < {base_rate:.4f}）。"
        f"governance/waivers/ に target_check={target_check} の有効な waiver がありません。",
        "  正当な低下（新規 MUST 追加に伴う一時的な低下等）であれば governance/waivers/ へ登録してください"
        "（governance/waivers/README.md「機械可読な紐付け」）。",
        "  低下が実装ミス・誤った台帳編集によるものであれば、原因側（enforcement-ledger.md の当該行）を"
        "修正してください（自己修正ループの防止。constitution.md「6.」）。",
    ]


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
    # effective 系フィールドが無い旧スキーマ（schema_version 1）の baseline は 0/1 として扱い、
    # 「効いているゲートが皆無だった」下限からの比較にする（非減少制約が誤って合格しないように、
    # 移行直後は 0 を基準にする＝実効側は初回だけほぼ確実に「非減少」となる）。
    base_num_eff = int(baseline.get("mechanized_norms_effective", 0))
    base_den_eff = base_den if "mechanized_norms_effective" in baseline else 1
    cur_num_eff = metrics["mechanized_norms_effective"]
    cur_den_eff = cur_den

    if base_den <= 0 or cur_den <= 0:
        print("✗ ledger/baseline の分母が0です（行が検出できていません）", file=sys.stderr)
        return 1

    cur_rate = cur_num / cur_den
    base_rate = base_num / base_den
    cur_rate_eff = cur_num_eff / cur_den_eff
    print(
        f"機械強制率（公称・inclusive）: {cur_num}/{cur_den} = {cur_rate:.4f}"
        f"（baseline: {base_num}/{base_den} = {base_rate:.4f}, captured {baseline.get('captured_date', '?')}）"
    )
    print(
        f"機械強制率（実効・整備済み行のみ）: {cur_num_eff}/{cur_den_eff} = {cur_rate_eff:.4f}"
        f"（公称との差: {cur_rate - cur_rate_eff:.4f} ポイント。休眠ゲートで水増しされている割合）"
    )
    print(f"暫定人間ゲート残数: {metrics['bootstrap_gate_count']} 件")
    print(f"期限超過件数（観測。強制は check_enforcement_ledger.py が担う）: {metrics['expired_bootstrap_count']} 件")

    # 非減少制約は公称・実効の両方へ課す（2026-08-26。外部レビュー指摘）。公称のみだと、
    # 休眠ゲート（#40/#52/#55/#56 のような「ロジックは実装済みだが実ツール未配線」の行）を
    # 追加するだけで指標を満たせてしまい、正直に人間ゲート行を登録するほうが指標上「不利」に
    # なる逆インセンティブを生んでいた（development-process.md「5.1」が力量要件の MUST NOT を
    # 台帳に登録しなかった理由として、まさにこれを明記していた）。実効側の非減少制約を追加する
    # ことで、休眠ゲートの追加だけでは指標を満たせなくなる。公称側もそのまま維持し、
    # defense-in-depth（人間ゲートに機械層を追加する行為）を評価する inclusive カウントの
    # 利点は失わない。
    errors = _check_non_decreasing(
        "機械強制率（公称）", cur_num, cur_den, base_num, base_den, TARGET_CHECK_ID
    )
    errors += _check_non_decreasing(
        "機械強制率（実効）", cur_num_eff, cur_den_eff, base_num_eff, base_den_eff, TARGET_CHECK_ID_EFFECTIVE
    )

    if errors:
        for line in errors:
            print(line, file=sys.stderr)
        return 1

    print("✓ Governance health metrics（機械強制率は公称・実効ともに非減少）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
