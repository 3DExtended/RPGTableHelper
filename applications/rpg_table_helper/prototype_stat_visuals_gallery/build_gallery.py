#!/usr/bin/env python3
"""Throwaway gallery builder for new character-stat visualization variants.

Copies PlayerStatsScreenWidget EN light goldens into ./shots/ and writes index.html
with stable IDs (V-HP-5, …) for feedback discussions.
"""

from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
GOLDENS = ROOT.parent / "test" / "goldens"
SHOTS = ROOT / "shots"

# Stable catalog — keep in sync with stat_visualization_variant_catalog.dart
CATALOG = [
    {"id": "V-HP-0", "valueType": "intWithMaxValue", "variant": 0, "title": "Text value / max", "isNew": False},
    {"id": "V-HP-1", "valueType": "intWithMaxValue", "variant": 1, "title": "Circular progress (accent)", "isNew": False},
    {"id": "V-HP-2", "valueType": "intWithMaxValue", "variant": 2, "title": "Pentagon", "isNew": False},
    {"id": "V-HP-3", "valueType": "intWithMaxValue", "variant": 3, "title": "Circular progress (health colors)", "isNew": False},
    {"id": "V-HP-4", "valueType": "intWithMaxValue", "variant": 4, "title": "Dot pips", "isNew": False},
    {"id": "V-HP-5", "valueType": "intWithMaxValue", "variant": 5, "title": "Heart reservoir", "isNew": True},
    {"id": "V-HP-6", "valueType": "intWithMaxValue", "variant": 6, "title": "Gem / crystal reservoir", "isNew": True},
    {"id": "V-HP-7", "valueType": "intWithMaxValue", "variant": 7, "title": "Segmented track", "isNew": True},
    {"id": "V-HP-8", "valueType": "intWithMaxValue", "variant": 8, "title": "Compact combat chip (was V-HP-9)", "isNew": True},
    {"id": "V-CALC-0", "valueType": "intWithCalculatedValue", "variant": 0, "title": "Stacked text", "isNew": False},
    {"id": "V-CALC-1", "valueType": "intWithCalculatedValue", "variant": 1, "title": "Pentagon", "isNew": False},
    {"id": "V-CALC-2", "valueType": "intWithCalculatedValue", "variant": 2, "title": "Modifier-first", "isNew": True},
    {"id": "V-CALC-3", "valueType": "intWithCalculatedValue", "variant": 3, "title": "Classic ability block", "isNew": True},
    {"id": "V-ABILITY-0", "valueType": "listOfIntWithCalculatedValues", "variant": 0, "title": "Pentagon grid", "isNew": False},
    {"id": "V-ABILITY-1", "valueType": "listOfIntWithCalculatedValues", "variant": 1, "title": "Modifier-first tiles", "isNew": True},
    {"id": "V-ABILITY-2", "valueType": "listOfIntWithCalculatedValues", "variant": 2, "title": "Hex / shield tiles", "isNew": True},
    {"id": "V-ABILITY-3", "valueType": "listOfIntWithCalculatedValues", "variant": 3, "title": "Classic ability blocks", "isNew": True},
    {"id": "V-ICON-0", "valueType": "listOfIntsWithIcons", "variant": 0, "title": "Icon + Label: value", "isNew": False},
    {"id": "V-ICON-1", "valueType": "listOfIntsWithIcons", "variant": 1, "title": "Icon + value over label", "isNew": False},
    {"id": "V-ICON-2", "valueType": "listOfIntsWithIcons", "variant": 2, "title": "Medallion / badge cluster", "isNew": True},
    {"id": "V-ICON-3", "valueType": "listOfIntsWithIcons", "variant": 3, "title": "Horizontal ribbon", "isNew": True},
    {"id": "V-ICON-4", "valueType": "listOfIntsWithIcons", "variant": 4, "title": "Primary hero + secondaries", "isNew": True},
    {"id": "V-MULTI-0", "valueType": "multiselect", "variant": 0, "title": "Selected-only list", "isNew": False},
    {"id": "V-MULTI-1", "valueType": "multiselect", "variant": 1, "title": "All options list", "isNew": False},
    {"id": "V-MULTI-2", "valueType": "multiselect", "variant": 2, "title": "Proficiency chips", "isNew": True},
    {"id": "V-MULTI-3", "valueType": "multiselect", "variant": 3, "title": "Icon / tile grid (was V-MULTI-4)", "isNew": True},
    {"id": "V-ID-0", "valueType": "characterNameWithLevelAndAdditionalDetails", "variant": 0, "title": "Level circle + detail grid", "isNew": False},
    {"id": "V-ID-1", "valueType": "characterNameWithLevelAndAdditionalDetails", "variant": 1, "title": "Banner + level seal", "isNew": True},
    {"id": "V-ID-2", "valueType": "characterNameWithLevelAndAdditionalDetails", "variant": 2, "title": "Portrait-led card (generate/save image)", "isNew": True},
    {"id": "V-ID-3", "valueType": "characterNameWithLevelAndAdditionalDetails", "variant": 3, "title": "Minimal identity line", "isNew": True},
    {"id": "V-TEXT-0", "valueType": "multiLineText", "variant": 0, "title": "Labeled markdown", "isNew": False},
    {"id": "V-TEXT-1", "valueType": "multiLineText", "variant": 1, "title": "Collapsible lore panel (expanded)", "isNew": True},
    {"id": "V-TEXT-2", "valueType": "multiLineText", "variant": 2, "title": "Parchment frame (left accent)", "isNew": True},
    {"id": "V-IMG-0", "valueType": "singleImage", "variant": 0, "title": "Bordered image", "isNew": False},
    {"id": "V-SLTEXT-0", "valueType": "singleLineText", "variant": 0, "title": "Labeled markdown", "isNew": False},
    {"id": "V-COMP-0", "valueType": "companionSelector", "variant": 0, "title": "Paw + buttons", "isNew": False},
    {"id": "V-COMP-1", "valueType": "companionSelector", "variant": 1, "title": "Mini character cards", "isNew": True},
    {"id": "V-FORM-0", "valueType": "transformIntoAlternateFormBtn", "variant": 0, "title": "Wand + transform button", "isNew": False},
    {"id": "V-FORM-1", "valueType": "transformIntoAlternateFormBtn", "variant": 1, "title": "Active-form banner", "isNew": True},
    {"id": "V-INT-0", "valueType": "int", "variant": 0, "title": "Number over label", "isNew": False},
    {"id": "V-INT-1", "valueType": "int", "variant": 1, "title": "Large numeral tile", "isNew": True},
]


# Prefer these sample folders for representative screenshots (static, not empty/edit).
PREFERRED_SAMPLES = {
    "intWithMaxValue": "intWithMaxValue, static",
    "intWithCalculatedValue": "intWithCalculatedValue, static",
    "listOfIntWithCalculatedValues": "listOfIntWithCalculatedValues, static",
    "listOfIntsWithIcons": "listOfIntsWithIcons, static",
    "multiselect": "multiselect, static",
    "characterNameWithLevelAndAdditionalDetails": "characterNameWithLevelAndAdditionalDetails, static",
    "multiLineText": "multiLineText, static",
    "singleLineText": "singleLineText, static",
    "singleImage": "singleImage, static",
    "companionSelector": "companionSelector, static",
    "transformIntoAlternateFormBtn": "transformIntoAlternateFormBtn, fastEdit",
    "int": "int, static",
}

FOLDER_RE = re.compile(
    r"^CharacterStatValueType_PlayerStatsScreenWidget_(.+?)variant(\d+)$"
)


def find_png(folder: Path) -> Path | None:
    # Prefer English light (no Darkmode in name)
    pngs = sorted(folder.glob("*.png"))
    if not pngs:
        return None
    en_light = [
        p
        for p in pngs
        if "Language en" in p.name and "Darkmode" not in p.name
    ]
    if en_light:
        return en_light[0]
    en_any = [p for p in pngs if "Language en" in p.name]
    if en_any:
        return en_any[0]
    return pngs[0]


def main() -> None:
    if not GOLDENS.exists():
        raise SystemExit(f"Goldens folder missing: {GOLDENS}")

    if SHOTS.exists():
        shutil.rmtree(SHOTS)
    SHOTS.mkdir()

    # Index available PlayerStatsScreenWidget folders
    available: dict[tuple[str, int], list[Path]] = {}
    for folder in GOLDENS.iterdir():
        if not folder.is_dir():
            continue
        m = FOLDER_RE.match(folder.name)
        if not m:
            continue
        sample_name, variant_s = m.group(1), m.group(2)
        variant = int(variant_s)
        # Infer value type as the prefix before first comma / known names
        available.setdefault((sample_name, variant), []).append(folder)

    cards = []
    missing = []
    for entry in CATALOG:
        vt = entry["valueType"]
        variant = entry["variant"]
        preferred = PREFERRED_SAMPLES.get(vt, vt)
        key = (preferred, variant)
        folders = available.get(key)
        if not folders:
            # Fallback: any folder whose name starts with valueType and ends with variant
            folders = []
            for (sample, v), flist in available.items():
                if v == variant and sample.startswith(vt):
                    folders = flist
                    break
        if not folders:
            missing.append(entry["id"])
            cards.append({**entry, "src": None, "sample": preferred})
            continue
        folder = folders[0]
        png = find_png(folder)
        if png is None:
            missing.append(entry["id"])
            cards.append({**entry, "src": None, "sample": preferred})
            continue
        dest_name = f"{entry['id']}.png"
        shutil.copy2(png, SHOTS / dest_name)
        cards.append({**entry, "src": f"shots/{dest_name}", "sample": preferred})

    (ROOT / "catalog.json").write_text(json.dumps(cards, indent=2), encoding="utf-8")

    html = build_html(cards)
    (ROOT / "index.html").write_text(html, encoding="utf-8")

    print(f"Wrote {ROOT / 'index.html'}")
    print(f"Copied {sum(1 for c in cards if c.get('src'))} shots; missing {len(missing)}")
    if missing:
        print("Missing:", ", ".join(missing))


def build_html(cards: list[dict]) -> str:
    types = []
    seen = set()
    for c in cards:
        if c["valueType"] not in seen:
            seen.add(c["valueType"])
            types.append(c["valueType"])

    cards_json = json.dumps(cards)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>PROTOTYPE — Stat visualization variants</title>
<style>
  :root {{
    --bg: #1c1a17;
    --panel: #2a2621;
    --ink: #f3ebe0;
    --muted: #b9a990;
    --accent: #f96f3d;
    --new: #3ed22b;
    --old: #8a7f6e;
  }}
  * {{ box-sizing: border-box; }}
  body {{
    margin: 0;
    font-family: "Iowan Old Style", "Palatino Linotype", Palatino, Georgia, serif;
    background: radial-gradient(1200px 600px at 20% -10%, #3a3228, var(--bg));
    color: var(--ink);
  }}
  header {{
    position: sticky; top: 0; z-index: 5;
    backdrop-filter: blur(8px);
    background: rgba(28,26,23,.92);
    border-bottom: 1px solid #3d362e;
    padding: 14px 20px 12px;
  }}
  h1 {{ margin: 0 0 4px; font-size: 1.35rem; letter-spacing: .02em; }}
  .sub {{ color: var(--muted); font-size: .92rem; margin-bottom: 10px; }}
  .controls {{ display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }}
  input[type=search], select {{
    background: var(--panel); color: var(--ink);
    border: 1px solid #52483c; border-radius: 6px; padding: 8px 10px;
  }}
  label.chk {{ display: inline-flex; gap: 6px; align-items: center; color: var(--muted); }}
  main {{ padding: 18px; }}
  .group-title {{
    margin: 22px 0 10px; font-size: 1.05rem; color: var(--accent);
    border-bottom: 1px solid #3d362e; padding-bottom: 4px;
  }}
  .grid {{
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 14px;
  }}
  .card {{
    background: var(--panel);
    border: 1px solid #3d362e;
    border-radius: 10px;
    overflow: hidden;
    display: flex; flex-direction: column;
  }}
  .card.missing {{ opacity: .55; }}
  .meta {{ padding: 10px 12px 8px; }}
  .id {{
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 1rem; color: var(--accent); font-weight: 700;
  }}
  .title {{ margin-top: 2px; }}
  .badges {{ margin-top: 6px; display: flex; gap: 6px; flex-wrap: wrap; }}
  .badge {{
    font-size: .72rem; letter-spacing: .04em; text-transform: uppercase;
    padding: 2px 7px; border-radius: 999px; border: 1px solid currentColor;
  }}
  .badge.new {{ color: var(--new); }}
  .badge.old {{ color: var(--old); }}
  .badge.vt {{ color: var(--muted); border-color: #52483c; }}
  .shot {{
    background: #0f0e0c; min-height: 180px;
    display: flex; align-items: center; justify-content: center;
    border-top: 1px solid #3d362e;
  }}
  .shot img {{ max-width: 100%; height: auto; display: block; }}
  .shot .placeholder {{ color: var(--muted); padding: 24px; text-align: center; }}
  footer {{ color: var(--muted); padding: 24px 20px 40px; font-size: .85rem; }}
  code {{ color: #e7d2b5; }}
</style>
</head>
<body>
<header>
  <h1>PROTOTYPE — Stat visualization gallery</h1>
  <div class="sub">Throwaway review UI. Refer to IDs like <code>V-HP-5</code> in feedback. Prefer NEW variants first.</div>
  <div class="controls">
    <input id="q" type="search" placeholder="Filter by id / title…" style="min-width:220px" />
    <select id="type">
      <option value="">All types</option>
      {''.join(f'<option value="{t}">{t}</option>' for t in types)}
    </select>
    <label class="chk"><input id="newOnly" type="checkbox" checked /> New only</label>
  </div>
</header>
<main id="root"></main>
<footer>
  Rebuild: <code>python3 prototype_stat_visuals_gallery/build_gallery.py</code>
  · Serve: <code>python3 -m http.server 8765</code> from this folder
</footer>
<script>
const CARDS = {cards_json};
const root = document.getElementById('root');
const q = document.getElementById('q');
const type = document.getElementById('type');
const newOnly = document.getElementById('newOnly');

function render() {{
  const query = q.value.trim().toLowerCase();
  const vt = type.value;
  const onlyNew = newOnly.checked;
  const filtered = CARDS.filter(c => {{
    if (onlyNew && !c.isNew) return false;
    if (vt && c.valueType !== vt) return false;
    if (!query) return true;
    return (c.id + ' ' + c.title + ' ' + c.valueType + ' variant' + c.variant)
      .toLowerCase().includes(query);
  }});

  const byType = new Map();
  for (const c of filtered) {{
    if (!byType.has(c.valueType)) byType.set(c.valueType, []);
    byType.get(c.valueType).push(c);
  }}

  root.innerHTML = '';
  if (!filtered.length) {{
    root.innerHTML = '<p class="sub">No matches. Uncheck “New only” or clear filters.</p>';
    return;
  }}
  for (const [group, items] of byType) {{
    const h = document.createElement('div');
    h.className = 'group-title';
    h.textContent = group;
    root.appendChild(h);
    const grid = document.createElement('div');
    grid.className = 'grid';
    for (const c of items) {{
      const card = document.createElement('article');
      card.className = 'card' + (c.src ? '' : ' missing');
      card.id = c.id;
      card.innerHTML = `
        <div class="meta">
          <div class="id">${{c.id}}</div>
          <div class="title">${{c.title}}</div>
          <div class="badges">
            <span class="badge ${{c.isNew ? 'new' : 'old'}}">${{c.isNew ? 'new' : 'existing'}}</span>
            <span class="badge vt">variant ${{c.variant}}</span>
          </div>
        </div>
        <div class="shot">
          ${{c.src
            ? `<img src="${{c.src}}" alt="${{c.id}}" loading="lazy" />`
            : `<div class="placeholder">Golden missing<br/><small>${{c.sample}} variant${{c.variant}}</small></div>`}}
        </div>`;
      grid.appendChild(card);
    }}
    root.appendChild(grid);
  }}
}}

q.addEventListener('input', render);
type.addEventListener('change', render);
newOnly.addEventListener('change', render);
render();
</script>
</body>
</html>
"""


if __name__ == "__main__":
    main()
