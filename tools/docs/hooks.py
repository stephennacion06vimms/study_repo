"""Render PlantUML diagrams to SVG locally, before MkDocs builds the site.

Used two ways:
  * MkDocs hook (mkdocs.yml -> hooks:), runs on every build / serve rebuild.
  * CLI: python tools/docs/hooks.py [--force]

Diagram text never leaves the machine: the pinned PlantUML jar runs on the
local Java runtime. No PlantUML server is used.
"""

from __future__ import annotations

import hashlib
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path

PLANTUML_VERSION = "1.2026.9"
PLANTUML_SHA256 = "aa4a1d06f8911c4b842beff4828dd955be431692b631a312d04c0e9fab9581de"
PLANTUML_URL = (
    "https://github.com/plantuml/plantuml/releases/download/"
    f"v{PLANTUML_VERSION}/plantuml-{PLANTUML_VERSION}.jar"
)

REPO_ROOT = Path(__file__).resolve().parents[2]
DOCS_DIR = REPO_ROOT / "docs"
CACHE_DIR = Path(__file__).resolve().parent / ".cache"
JAR_PATH = CACHE_DIR / f"plantuml-{PLANTUML_VERSION}.jar"
# Shared includes: a change here re-renders every diagram.
INCLUDE_DIR = DOCS_DIR / "_plantuml"


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def ensure_jar() -> Path:
    """Download the pinned PlantUML jar once and verify its SHA-256."""
    if JAR_PATH.exists() and _sha256(JAR_PATH) == PLANTUML_SHA256:
        return JAR_PATH
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    tmp = JAR_PATH.with_suffix(".part")
    print(f"[plantuml] downloading {PLANTUML_URL}")
    with urllib.request.urlopen(PLANTUML_URL, timeout=120) as r, tmp.open("wb") as f:
        shutil.copyfileobj(r, f)
    digest = _sha256(tmp)
    if digest != PLANTUML_SHA256:
        tmp.unlink(missing_ok=True)
        raise RuntimeError(
            f"PlantUML jar checksum mismatch: got {digest}, expected {PLANTUML_SHA256}"
        )
    tmp.replace(JAR_PATH)
    return JAR_PATH


def _stale(sources: list[Path], force: bool) -> list[Path]:
    if force:
        return sources
    include_mtime = max(
        (p.stat().st_mtime for p in INCLUDE_DIR.glob("*.puml")), default=0.0
    )
    out = []
    for src in sources:
        svg = src.with_suffix(".svg")
        if not svg.exists():
            out.append(src)
            continue
        newest_input = max(src.stat().st_mtime, include_mtime)
        if svg.stat().st_mtime < newest_input:
            out.append(src)
    return out


def render_all(force: bool = False) -> int:
    """Render every docs/**/diagrams/*.puml whose SVG is missing or older."""
    sources = sorted(DOCS_DIR.glob("**/diagrams/*.puml"))
    todo = _stale(sources, force)
    if not todo:
        return 0
    java = shutil.which("java")
    if not java:
        raise RuntimeError("Java not found on PATH; install a JRE 11+ to render diagrams")
    jar = ensure_jar()
    cmd = [
        java,
        "-Djava.awt.headless=true",
        "-jar",
        str(jar),
        "-tsvg",
        "-charset",
        "UTF-8",
        "-failfast2",
        *[str(p) for p in todo],
    ]
    print(f"[plantuml] rendering {len(todo)} diagram(s)")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise RuntimeError(f"PlantUML failed (exit {res.returncode})")
    return len(todo)


# --- MkDocs hook ----------------------------------------------------------
def on_pre_build(config, **kwargs):  # noqa: ARG001 (MkDocs hook signature)
    render_all()


if __name__ == "__main__":
    n = render_all(force="--force" in sys.argv)
    print(f"[plantuml] {n} diagram(s) rendered")
