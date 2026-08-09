#!/usr/bin/env python3
"""依存・ツールチェーンの版数と既知脆弱性を監査する（standards/security-standards.md「6.」）。

なぜ必要か:
    trivy は「マニフェストがあるプロジェクト」を対象とする。本テンプレートのように
    `package.json` / lockfile を持たない段階では実質的に空振りする。一方で、
    `.mise.toml`（ツールチェーン）・`requirements-docs.txt`（docs 依存）・
    `package.ui.json`（採用者向け推奨値）・ワークフローの `uses:` は実在する依存宣言であり、
    LTS 追随と既知脆弱性の確認対象になる。本スクリプトはその空白を埋める。

判定:
    - 既知脆弱性を検出 → exit 1（err）
    - 版数の陳腐化・上限のないレンジ → warn（exit 0）
    - ネットワーク不通・API 失敗 → warn して skip（exit 0）。落とさないが「確認できていない」と明示する

外部依存なし（標準ライブラリのみ）。使い方: python3 scripts/audit_deps.py [--json]
"""
from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TIMEOUT = 20
UA = {"User-Agent": "agent-spec-template-deps-audit"}

warnings: list[str] = []
errors: list[str] = []
skipped: list[str] = []
rows: list[dict] = []


def get_json(url: str, data: bytes | None = None, headers: dict | None = None):
    h = dict(UA)
    if headers:
        h.update(headers)
    if data is not None:
        h.setdefault("Content-Type", "application/json")
    req = urllib.request.Request(url, data=data, headers=h)
    with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
        return json.load(r)


def vkey(v: str):
    """比較用のバージョンキー。プレリリースは除外済みの前提。"""
    return tuple(int(x) if x.isdigit() else 0 for x in re.split(r"[.\-+]", v)[:4])


def add(kind: str, name: str, declared: str, latest: str, note: str = "") -> None:
    rows.append({"kind": kind, "name": name, "declared": declared, "latest": latest, "note": note})


# ---------------------------------------------------------------- ランタイム LTS
def audit_runtime_lts(mise: dict) -> None:
    node = mise.get("node")
    if not node:
        return
    try:
        cycles = get_json("https://endoflife.date/api/nodejs.json")
    except Exception as e:  # noqa: BLE001
        skipped.append(f"Node.js の LTS 状況を確認できません（{e}）")
        return
    import datetime

    today = datetime.date.today().isoformat()
    active = [
        c for c in cycles
        if isinstance(c.get("lts"), str) and c["lts"] <= today
        and isinstance(c.get("eol"), str) and c["eol"] > today
    ]
    if not active:
        skipped.append("Node.js の Active LTS を判定できません（API 応答の形式変化）")
        return
    newest_lts = max(active, key=lambda c: vkey(str(c["cycle"])))
    cur = str(node).split(".")[0]
    add("runtime", "node", str(node), f"{newest_lts['cycle']} (Active LTS, EOL {newest_lts['eol']})")
    if vkey(cur) < vkey(str(newest_lts["cycle"])):
        mine = next((c for c in cycles if str(c["cycle"]) == cur), None)
        eol = mine.get("eol") if mine else "?"
        warnings.append(
            f"Node.js {cur} は Active LTS ではありません（EOL {eol}）。"
            f"Active LTS は {newest_lts['cycle']}（EOL {newest_lts['eol']}）— "
            f"standards/security-standards.md「6.」ランタイムの LTS 追随"
        )


# ---------------------------------------------------------------- .mise.toml
def parse_mise() -> dict:
    p = ROOT / ".mise.toml"
    if not p.exists():
        return {}
    tools: dict[str, str] = {}
    in_tools = False
    for line in p.read_text(encoding="utf-8").splitlines():
        s = line.strip()
        if s.startswith("["):
            in_tools = s == "[tools]"
            continue
        if not in_tools or not s or s.startswith("#"):
            continue
        m = re.match(r'^"?([^"=\s]+)"?\s*=\s*"([^"]+)"', s)
        if m:
            tools[m.group(1)] = m.group(2)
    return tools


GH_REPO_FOR_TOOL = {
    "task": "go-task/task",
    "lefthook": "evilmartians/lefthook",
    "lychee": "lycheeverse/lychee",
    "gitleaks": "gitleaks/gitleaks",
    "trivy": "aquasecurity/trivy",
}


def gh_latest_tag(repo: str) -> str | None:
    headers = {}
    tok = os.environ.get("GITHUB_TOKEN")
    if tok:
        headers["Authorization"] = f"Bearer {tok}"
    try:
        return get_json(f"https://api.github.com/repos/{repo}/releases/latest", headers=headers).get("tag_name")
    except Exception:  # noqa: BLE001
        return None


def audit_mise_tools(tools: dict) -> None:
    for name, spec in tools.items():
        if name == "node":
            continue
        if name.startswith("npm:"):
            audit_npm(name[4:], spec, kind="toolchain")
            continue
        repo = GH_REPO_FOR_TOOL.get(name)
        if not repo:
            continue
        tag = gh_latest_tag(repo)
        if tag is None:
            skipped.append(f"{name} の最新版を確認できません（GitHub API）")
            continue
        add("toolchain", name, spec, tag)
        if spec == "latest":
            continue  # 意図的な浮動（.mise.toml のヘッダに理由を明記済み）
        latest_major = re.sub(r"^[^0-9]*", "", tag).split(".")[0]
        if latest_major.isdigit() and spec.split(".")[0].isdigit():
            if int(spec.split(".")[0]) < int(latest_major):
                warnings.append(f"{name}: 指定 {spec} に対し最新は {tag}（メジャー更新あり）")


# ---------------------------------------------------------------- npm / PyPI
def npm_versions(pkg: str) -> list[str] | None:
    try:
        data = get_json(f"https://registry.npmjs.org/{urllib.parse.quote(pkg, safe='@')}")
    except Exception:  # noqa: BLE001
        return None
    return [v for v in data.get("versions", {}) if "-" not in v]


def resolve_caret(versions: list[str], spec: str) -> str | None:
    """`^X` / `X` / `X.Y` を、その major（0.x は minor）内の最大版へ解決する。"""
    base = spec.lstrip("^~>=< ")
    if not base or not base[0].isdigit():
        return None
    parts = base.split(".")
    if parts[0] == "0" and len(parts) > 1:
        prefix = f"0.{parts[1]}."
        cand = [v for v in versions if v.startswith(prefix)]
    else:
        prefix = parts[0] + "."
        cand = [v for v in versions if v.startswith(prefix)]
    return max(cand, key=vkey) if cand else None


def audit_npm(pkg: str, spec: str, kind: str = "npm") -> None:
    versions = npm_versions(pkg)
    if versions is None:
        skipped.append(f"npm:{pkg} の版数を確認できません")
        return
    latest = max(versions, key=vkey)
    resolved = resolve_caret(versions, spec)
    add(kind, pkg, spec, latest, f"解決={resolved or '—'}")
    if resolved is None:
        return
    if vkey(latest.split(".")[0]) > vkey(resolved.split(".")[0]):
        warnings.append(f"npm:{pkg}: 宣言 {spec}（解決 {resolved}）に対し最新は {latest}（メジャー更新あり）")
    osv_targets.append(("npm", pkg, resolved))


def audit_pypi(pkg: str, spec: str) -> None:
    try:
        info = get_json(f"https://pypi.org/pypi/{pkg}/json")["info"]
    except Exception:  # noqa: BLE001
        skipped.append(f"PyPI:{pkg} の版数を確認できません")
        return
    latest = info["version"]
    add("pypi", pkg, spec, latest)
    if "<" not in spec:
        warnings.append(
            f"PyPI:{pkg}: 宣言 '{spec}' に上限がありません。上流のメジャー更新を無警告で取り込みます"
            f"（standards/security-standards.md「6.」バージョンレンジの上限）"
        )
    osv_targets.append(("PyPI", pkg, latest))


# ---------------------------------------------------------------- GitHub Actions
def audit_actions() -> None:
    wf_dir = ROOT / ".github" / "workflows"
    if not wf_dir.is_dir():
        return
    seen: dict[str, str] = {}
    for f in sorted(wf_dir.glob("*.yml")):
        for m in re.finditer(r"uses:\s*([A-Za-z0-9._-]+/[A-Za-z0-9._-]+)@(v?[0-9][^\s]*)", f.read_text(encoding="utf-8")):
            seen.setdefault(m.group(1), m.group(2))
    for repo, ref in seen.items():
        tag = gh_latest_tag(repo)
        if tag is None:
            skipped.append(f"{repo} の最新リリースを確認できません（GitHub API）")
            continue
        add("action", repo, ref, tag)
        cur_major = re.sub(r"^v", "", ref).split(".")[0]
        new_major = re.sub(r"^v", "", tag).split(".")[0]
        if cur_major.isdigit() and new_major.isdigit() and int(cur_major) < int(new_major):
            warnings.append(f"{repo}: 使用中 {ref} に対し最新は {tag}（メジャー更新あり）")


# ---------------------------------------------------------------- OSV
osv_targets: list[tuple[str, str, str]] = []


def audit_osv() -> None:
    if not osv_targets:
        return
    queries = [{"package": {"name": n, "ecosystem": e}, "version": v} for e, n, v in osv_targets]
    try:
        res = get_json("https://api.osv.dev/v1/querybatch", data=json.dumps({"queries": queries}).encode())
    except Exception as e:  # noqa: BLE001
        skipped.append(f"OSV への照会に失敗しました（{e}）— 既知脆弱性は未確認")
        return
    for (eco, name, ver), r in zip(osv_targets, res.get("results", [])):
        vulns = r.get("vulns") or []
        if vulns:
            ids = ", ".join(v.get("id", "?") for v in vulns[:5])
            errors.append(f"{eco}:{name}@{ver} に既知脆弱性 {len(vulns)} 件: {ids}")


# ---------------------------------------------------------------- main
def main() -> int:
    mise = parse_mise()
    audit_runtime_lts(mise)
    audit_mise_tools(mise)

    req = ROOT / "requirements-docs.txt"
    if req.exists():
        for line in req.read_text(encoding="utf-8").splitlines():
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            m = re.match(r"^([A-Za-z0-9._-]+)\s*(.*)$", s)
            if m:
                audit_pypi(m.group(1), m.group(2) or "(制約なし)")

    pui = ROOT / "package.ui.json"
    if pui.exists():
        for pkg, spec in json.loads(pui.read_text(encoding="utf-8")).get("devDependencies", {}).items():
            if re.match(r"^[\^~>=<0-9]", spec):
                audit_npm(pkg, spec)
            else:
                add("npm", pkg, spec, "—", "版数未確定（ADR 待ちのプレースホルダ）")

    audit_actions()
    audit_osv()

    if "--json" in sys.argv:
        print(json.dumps({"rows": rows, "warnings": warnings, "errors": errors, "skipped": skipped},
                         ensure_ascii=False, indent=2))
    else:
        print(f"{'種別':<10} {'名前':<34} {'宣言':<22} {'最新':<28} 備考")
        for r in rows:
            print(f"{r['kind']:<10} {r['name']:<34} {r['declared']:<22} {r['latest']:<28} {r['note']}")
        print()
        for s in skipped:
            print(f"⚠ 確認できず: {s}")
        for w in warnings:
            print(f"⚠ {w}")
        for e in errors:
            print(f"✗ {e}")
        print(f"\n監査対象 {len(rows)} 件 / 警告 {len(warnings)} 件 / 脆弱性 {len(errors)} 件 / 未確認 {len(skipped)} 件")

    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
