import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const MaterialColor customBlue = MaterialColor(
  0xFF02005D,
  <int, Color>{
    50: Color(0xFFE0E0EC),
    100: Color(0xFFB3B3CC),
    200: Color(0xFF8080AD),
    300: Color(0xFF4D4D8E),
    400: Color(0xFF262673),
    500: Color(0xFF02005D), // Base
    600: Color(0xFF010048),
    700: Color(0xFF01003A),
    800: Color(0xFF00002E),
    900: Color(0xFF000021),
  },
);

BoxDecoration roundedContainer({double radius = 15}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

/// The [AppTheme] defines light and dark themes for the app.
abstract final class AppTheme {
  // Define constant color schemes
  static const _lightColors = FlexSchemeColor(
    // Custom colors
    primary: Color(0xFFFF8D41),
    primaryContainer: Color(0xFFFFFEFE),
    primaryLightRef: Color(0xFFFF8D41),
    secondary: customBlue,
    secondaryContainer: Color(0xFFFFDBCF),
    secondaryLightRef: Color(0xFF02005D),
    tertiary: Color(0xFF006875),
    tertiaryContainer: Color(0xFF95F0FF),
    tertiaryLightRef: Color(0xFF006875),
    appBarColor: Color(0xFFFFDBCF),
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
  );

  static const _darkColors = FlexSchemeColor(
    // Custom colors
    primary: Color(0xFFFF8D41),
    primaryContainer: Color(0xFFFFF8F3),
    primaryLightRef: Color(0xFFFF8D41),
    secondary: Color(0xFF02005D),
    secondaryContainer: Color(0xFFD4D3F6),
    secondaryLightRef: Color(0xFF02005D),
    tertiary: Color(0xFFFF8D41),
    tertiaryContainer: Color(0xFF757575),
    tertiaryLightRef: Color(0xFF006875),
    appBarColor: Color(0xFFFFDBCF),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
  );

  // Define constant shared theme settings
  static const _subThemes = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnLevel: 6,
    useMaterial3Typography: true,
    useM2StyleDividerInM3: true,
    adaptiveElevationShadowsBack: FlexAdaptive.excludeWebAndroidFuchsia(),
    adaptiveAppBarScrollUnderOff: FlexAdaptive.excludeWebAndroidFuchsia(),
    adaptiveRadius: FlexAdaptive.excludeWebAndroidFuchsia(),
    adaptiveDialogRadius: FlexAdaptive.all(),
    defaultRadiusAdaptive: 8.0,
    textButtonRadius: 100,
    filledButtonRadius: 100.0,
    elevatedButtonRadius: 100.0,
    textButtonSchemeColor: SchemeColor.primary,
    elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
    elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
    outlinedButtonRadius: 100.0,
    outlinedButtonOutlineSchemeColor: SchemeColor.primary,
    toggleButtonsRadius: 15.0,
    toggleButtonsSchemeColor: SchemeColor.primaryFixedDim,
    toggleButtonsSelectedForegroundSchemeColor: SchemeColor.primary,
    toggleButtonsBorderSchemeColor: SchemeColor.primary,
    segmentedButtonRadius: 15.0,
    segmentedButtonSchemeColor: SchemeColor.primaryContainer,
    segmentedButtonSelectedForegroundSchemeColor: SchemeColor.primary,
    segmentedButtonBorderSchemeColor: SchemeColor.primary,
    switchThumbFixedSize: true,
    switchAdaptiveCupertinoLike: FlexAdaptive.all(),
    unselectedToggleIsColored: true,
    sliderValueTinted: true,
    sliderValueIndicatorType: FlexSliderIndicatorType.rectangular,
    sliderTrackHeight: 6,
    inputDecoratorSchemeColor: SchemeColor.primaryFixed,
    inputDecoratorIsFilled: true,
    inputDecoratorBackgroundAlpha: 56,
    inputDecoratorBorderSchemeColor: SchemeColor.primary,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: 15.0,
    inputCursorSchemeColor: SchemeColor.primary,
    fabUseShape: true,
    fabAlwaysCircular: true,
    fabSchemeColor: SchemeColor.primary,
    fabForegroundSchemeColor: SchemeColor.primaryFixed,
    chipBlendColors: false,
    chipRadius: 15.0,
    cardRadius: 15.0,
    popupMenuRadius: 6.0,
    popupMenuElevation: 3.0,
    alignedDropdown: true,
    tooltipRadius: 15,
    tooltipSchemeColor: SchemeColor.primaryFixed,
    tooltipOpacity: null,
    dialogRadius: 15.0,
    dialogRadiusAdaptive: 15.0,
    timePickerElementRadius: 15.0,
    datePickerDialogRadius: 15.0,
    snackBarRadius: 15,
    snackBarBackgroundSchemeColor: SchemeColor.secondary,
    appBarBackgroundSchemeColor: SchemeColor.surface,
    appBarScrolledUnderElevation: 0.0,
    appBarCenterTitle: false,
    tabBarItemSchemeColor: SchemeColor.primary,
    tabBarUnselectedItemSchemeColor: SchemeColor.onSurface,
    tabBarIndicatorSchemeColor: SchemeColor.primary,
    tabBarIndicatorSize: TabBarIndicatorSize.label,
    tabBarDividerColor: Color(0x00000000),
    drawerRadius: 16.0,
    drawerElevation: 1.0,
    drawerIndicatorRadius: 15.0,
    drawerIndicatorSchemeColor: SchemeColor.primary,
    drawerSelectedItemSchemeColor: SchemeColor.primaryFixed,
    bottomSheetRadius: 15.0,
    bottomSheetElevation: 2.0,
    bottomSheetModalElevation: 4.0,
    bottomNavigationBarMutedUnselectedLabel: false,
    bottomNavigationBarMutedUnselectedIcon: false,
    menuRadius: 6.0,
    menuElevation: 3.0,
    menuBarRadius: 0.0,
    menuBarElevation: 1.0,
    menuBarShadowColor: Color(0x00000000),
    menuIndicatorRadius: 15.0,
    searchBarElevation: 0.0,
    searchViewElevation: 0.0,
    searchBarRadius: 15.0,
    searchViewRadius: 15.0,
    searchUseGlobalShape: true,
    navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
    navigationBarSelectedIconSchemeColor: SchemeColor.primaryFixedDim,
    navigationBarIndicatorSchemeColor: SchemeColor.primary,
    navigationBarIndicatorRadius: 15.0,
    navigationBarElevation: 1.0,
    adaptiveRemoveNavigationBarTint: FlexAdaptive.all(),
    navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
    navigationRailSelectedIconSchemeColor: SchemeColor.primaryFixedDim,
    navigationRailUseIndicator: true,
    navigationRailIndicatorSchemeColor: SchemeColor.primary,
    navigationRailIndicatorOpacity: 1.00,
    navigationRailBackgroundSchemeColor: SchemeColor.surface,
    navigationRailLabelType: NavigationRailLabelType.all,
  );

  // Define constant key colors
  static const _lightKeyColors = FlexKeyColors(
    keepPrimary: true,
    keepSecondary: true,
    useExpressiveOnContainerColors: true,
  );

  static const _darkKeyColors = FlexKeyColors(
    keepPrimary: true,
    keepSecondary: true,
    keepPrimaryContainer: true,
    keepSecondaryContainer: true,
  );

  // The font family
  static const String _fontFamily = "Montserrat";

  // The defined light theme.
  static final ThemeData light = FlexThemeData.light(
    colors: _lightColors,
    usedColors: 2,
    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
    blendLevel: 1,
    transparentStatusBar: true,
    appBarElevation: 0.0,
    bottomAppBarElevation: 2.0,
    tabBarStyle: FlexTabBarStyle.forBackground,
    subThemesData: _subThemes,
    keyColors: _lightKeyColors,
    tones: FlexSchemeVariant.candyPop
        .tones(Brightness.light)
        .higherContrastFixed(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    // fontFamily: GoogleFonts.questrial().fontFamily,
    // textTheme: GoogleFonts.questrialTextTheme(),
  );

  // The defined dark theme.
  static final ThemeData dark = FlexThemeData.dark(
    colors: _darkColors,
    usedColors: 2,
    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
    blendLevel: 1,
    transparentStatusBar: true,
    bottomAppBarElevation: 2.0,
    tabBarStyle: FlexTabBarStyle.forAppBar,
    subThemesData: _subThemes,
    keyColors: _darkKeyColors,
    tones:
        FlexSchemeVariant.candyPop.tones(Brightness.dark).higherContrastFixed(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    // fontFamily: GoogleFonts.questrial().fontFamily,
    // textTheme: GoogleFonts.questrialTextTheme(),
  );

  static ThemeData get currentTheme {
    return Get.theme.brightness == Brightness.light ? light : dark;
  }
}
