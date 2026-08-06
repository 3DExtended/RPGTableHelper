# Golden keep-list (skin-01)

Canonical device for Flutter golden_toolkit screenshots:

| Device name | Size | Notes |
|-------------|------|--------|
| `ipad pro 12-9 landscape` | 1366×1024 @3x | Sole device in `testDevices` |

Still generated per test configuration:

- Locales: `en`, `de` (unless `disableLocals`)
- Brightness: light + dark (`Darkmode` suffix) — rename to classic skins in **skin-02**

Removed from matrix (PNGs deleted where present):

- `ipad pro 12-9 portrait`
- `ipad 6th gen landscape`
- `ipad pro 11inch 4th gen`
- `iphone 16`

## CharacterStatValueType goldens (slim)

Only **variant 0**, **one locale**, **light mode** — no `variant1..N`, no Darkmode matrix.

```bash
cd applications/rpg_table_helper
flutter test --update-goldens \
  test/components/character_stats_value_types/all_character_stat_value_type_test.dart \
  test/screens/user_settings_screen_test.dart
```

Then verify without update:

```bash
flutter test \
  test/test_configuration_device_set_test.dart \
  test/screens/pageviews/player_page_screen_test.dart \
  test/screens/pageviews/dm_page_screen_test.dart \
  test/components/character_stats_value_types/all_character_stat_value_type_test.dart \
  test/screens/user_settings_screen_test.dart
```