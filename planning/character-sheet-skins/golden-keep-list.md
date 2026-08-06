# Golden keep-list (skin-01)

Canonical device for Flutter golden_toolkit screenshots:

| Device name | Size | Notes |
|-------------|------|--------|
| `ipad pro 12-9 landscape` | 1366×1024 @3x | Sole device in `testDevices` |

Player/DM page goldens still use **en + de** and **light + dark** until classic skins land in skin-02.

Removed device sizes: portrait, iPad 6th gen, iPad 11", iPhone 16.

## CharacterStatValueType goldens (slim)

Only **variant 0**, **en**, **light**, **iPad Pro 12.9 landscape** (~75 PNGs = 15 configs × 5 surfaces).

Obsolete variant/Darkmode/DE/portrait CharacterStat PNGs were deleted from git. **Please regenerate the slim set locally** (agent will not — log volume):

```bash
cd applications/rpg_table_helper
flutter test --update-goldens \
  test/components/character_stats_value_types/all_character_stat_value_type_test.dart \
  test/screens/user_settings_screen_test.dart
```
