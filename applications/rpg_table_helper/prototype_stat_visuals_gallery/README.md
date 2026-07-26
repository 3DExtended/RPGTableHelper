# PROTOTYPE — Stat visualization gallery (throwaway)

Browse new/existing player-stat visualization variants with stable IDs for feedback (`V-HP-5`, `V-ABILITY-2`, …).

## Run

```bash
cd applications/rpg_table_helper/prototype_stat_visuals_gallery
python3 build_gallery.py   # refresh shots from test/goldens
python3 -m http.server 8765
```

Open http://localhost:8765/

## Notes

- Prefer **New only** filter when reviewing.
- Refer to card IDs in chat feedback.
- Delete this folder when the review is done.
