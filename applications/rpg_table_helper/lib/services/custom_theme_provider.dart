import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest_keeper/helpers/character_sheet_skins/character_sheet_skin.dart';

class CustomTheme {
  late Color darkColor;
  late Color middleBgColor;
  late Color bgColor;
  late Color textColor;
  late Color accentColor;
  late Color lightGreen;
  late Color lightYellow;
  late Color lightRed;
  late Color darkGreen;
  late Color darkRed;
  late Color darkTextColor;
  late Color secondaryNavbarColor;
  late Color whiteBgTint;

  late LinearGradient borderGradient;
  late LinearGradient navbarBackground;

  // Get the appropriate SystemUiOverlayStyle for status bar
  SystemUiOverlayStyle get statusBarStyle {
    // Since the app has dark headers/navbar, we need light status bar content
    return SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness:
          Brightness.light, // Light icons for dark background
      statusBarBrightness: Brightness.dark, // For iOS - dark background
    );
  }

  static CustomTheme lightTheme = CustomTheme()
    ..darkColor = Color(0xff312D28)
    ..middleBgColor = Color(0xffE4D5C5)
    ..bgColor = Color(0xfffdf0e3)
    ..textColor = Color(0xffffffff)
    ..accentColor = Color(0xffF96F3D)
    ..lightGreen = Color(0xff3ED22B)
    ..lightYellow = Color.fromARGB(255, 244, 194, 12)
    ..lightRed = Color(0xffD22B2E)
    ..darkGreen = Color.fromARGB(255, 34, 157, 59)
    ..darkRed = Color.fromARGB(255, 209, 26, 26)
    ..darkTextColor = Color(0xff312D28)
    ..secondaryNavbarColor = Color(0xff3E4148)
    ..whiteBgTint = Color.fromARGB(33, 210, 191, 221)
    ..borderGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff9FA3A4),
          Color(0xff2F333E),
          Color.fromARGB(255, 89, 115, 144),
        ])
    ..navbarBackground = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff2A2E37),
          Color(0xff272B36),
          Color(0xff2A374A),
        ]);

  static CustomTheme darkTheme = CustomTheme()
    ..bgColor = Color.fromARGB(255, 48, 46, 43)
    ..darkTextColor = Color.fromARGB(255, 255, 255, 255)
    ..textColor = Color.fromARGB(255, 0, 0, 0)
    ..darkColor = Color.fromARGB(255, 222, 207, 188)
    ..middleBgColor = Color.fromARGB(255, 194, 183, 166)
    ..accentColor = Color(0xffF96F3D)
    ..lightGreen = Color.fromARGB(255, 44, 169, 28)
    ..lightYellow = Color.fromARGB(255, 244, 182, 12)
    ..lightRed = Color(0xffD22B2E)
    ..darkGreen = Color.fromARGB(255, 34, 157, 59)
    ..darkRed = Color.fromARGB(255, 209, 26, 26)
    ..secondaryNavbarColor = Color(0xff3E4148) // TODO update me
    ..whiteBgTint = Color.fromARGB(33, 210, 191, 221) // TODO update me
    ..borderGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff9FA3A4), // TODO update me
          Color(0xff2F333E), // TODO update me
          Color.fromARGB(255, 89, 115, 144), // TODO update me
        ])
    ..navbarBackground = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xff2A2E37), // TODO update me
          Color(0xff272B36), // TODO update me
          Color(0xff2A374A), // TODO update me
        ]);

  /// Arcane Ledger — warmer manuscript parchment + bronze accent (skin-07).
  static CustomTheme arcaneLedgerTheme = CustomTheme()
    ..darkColor = const Color(0xff3A2E24)
    ..middleBgColor = const Color(0xffE8D7C0)
    ..bgColor = const Color(0xffF4E6D2)
    ..textColor = const Color(0xffF8F0E4)
    ..accentColor = const Color(0xffC46A3A)
    ..lightGreen = const Color(0xff3A9E4A)
    ..lightYellow = const Color(0xffD4A017)
    ..lightRed = const Color(0xffA8322D)
    ..darkGreen = const Color(0xff2E7A3A)
    ..darkRed = const Color(0xff8B1E1E)
    ..darkTextColor = const Color(0xff3A2E24)
    ..secondaryNavbarColor = const Color(0xff2C2521)
    ..whiteBgTint = const Color(0x22C4A882)
    ..borderGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xff8B7355),
        Color(0xff3A2E24),
        Color(0xff6B5344),
      ],
    )
    ..navbarBackground = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xff2C2521),
        Color(0xff312A24),
        Color(0xff3A322C),
      ],
    );
}

class CustomThemeProvider extends InheritedWidget {
  /// Active sheet skin id (may be unknown/stored); [theme] uses render fallback.
  final ValueNotifier<String> skinIdNotifier;

  /// Derived from the active skin's brightness category for legacy UI checks.
  final ValueNotifier<Brightness> brightnessNotifier;

  static CustomThemeProvider of(BuildContext context) {
    final dependOnInheritedWidgetOfExactType =
        context.dependOnInheritedWidgetOfExactType<CustomThemeProvider>();

    if (dependOnInheritedWidgetOfExactType == null) {
      throw MissingPluginException(
          'Custom error: Could not find CustomThemeProvider in dependOnInheritedWidgetOfExactType');
    }

    return dependOnInheritedWidgetOfExactType;
  }

  CustomTheme get theme {
    final resolved = resolveCharacterSheetSkin(
      characterSkinId: skinIdNotifier.value,
      campaignDefaultSkinId: null,
    );
    return CharacterSheetSkin.forRenderId(resolved.renderSkinId).theme;
  }

  /// Apply a resolved/stored skin id and sync [brightnessNotifier] for callers
  /// that still branch on light/dark.
  void setActiveSkinId(String skinId) {
    skinIdNotifier.value = skinId;
    final renderId = resolveCharacterSheetSkin(
      characterSkinId: skinId,
      campaignDefaultSkinId: null,
    ).renderSkinId;
    brightnessNotifier.value =
        CharacterSheetSkin.forRenderId(renderId).brightness;
  }

  CustomThemeProvider({
    super.key,
    required super.child,
    Brightness? overrideBrightness,
    String? overrideSkinId,
  })  : skinIdNotifier = ValueNotifier(
          overrideSkinId ??
              (overrideBrightness == Brightness.light
                  ? CharacterSheetSkinIds.classicLight
                  : CharacterSheetSkinIds.classicDark),
        ),
        brightnessNotifier = ValueNotifier(
          overrideBrightness ??
              (overrideSkinId != null
                  ? CharacterSheetSkin.forRenderId(
                      resolveCharacterSheetSkin(
                        characterSkinId: overrideSkinId,
                        campaignDefaultSkinId: null,
                      ).renderSkinId,
                    ).brightness
                  : Brightness.dark),
        ) {
    // Skins own appearance; do not follow platform brightness changes.
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
