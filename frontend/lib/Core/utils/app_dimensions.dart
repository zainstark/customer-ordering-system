
import 'package:flutter/material.dart';

class AppDimensions {
  // Prevent instantiation
  AppDimensions._();

  // ==================== Screen Dimensions ====================
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double screenAspectRatio(BuildContext context) => screenWidth(context) / screenHeight(context);

  // ==================== Spacing ====================
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingXxxl = 32.0;
  static const double spacingXxxxl = 40.0;
  static const double spacingXxxxxl = 48.0;


  // ==================== Paddings ====================
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 12.0;
  static const double paddingLg = 16.0;
  static const double paddingXl = 20.0;
  static const double paddingXxl = 24.0;
  static const double paddingXxxl = 32.0;

  // Standard screen padding
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 20.0;
  
  // Card padding
  static const double cardPadding = 16.0;
  static const double cardPaddingSmall = 12.0;

  // ==================== Border Radius ====================
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusXxxl = 32.0;
  static const double radiusMax = 999.0; 
  
  
  // Specific use cases
  static const double radiusButton = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusDialog = 20.0;
  static const double radiusTextField = 8.0;
  static const double radiusChip = 20.0;

  // ==================== Elevation ====================
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 6.0;
  static const double elevationXl = 8.0;
  static const double elevationXxl = 12.0;

  // ==================== Icon Sizes ====================
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double iconXxl = 48.0;
  
  // Specific icon sizes
  static const double iconAppBar = 24.0;
  static const double iconBottomNav = 24.0;
  static const double iconFab = 24.0;

  // ==================== Button Dimensions ====================
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonMinWidth = 120.0;
  static const double buttonMinWidthSmall = 80.0;
  
  // Icon button
  static const double iconButtonSize = 40.0;
  static const double iconButtonSizeSmall = 32.0;

  // ==================== Text Field ====================
  static const double textFieldHeight = 48.0;
  static const double textFieldHeightSmall = 40.0;
  static const double textFieldBorderWidth = 1.5;

  // ==================== App Bar ====================
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;

  // ==================== Bottom Navigation ====================
  static const double bottomNavHeight = 65.0;
  static const double bottomNavIconSize = 24.0;

  // ==================== Card Dimensions ====================
  static const double cardElevation = 2.0;
  static const double cardBorderWidth = 1.0;

  // ==================== Divider ====================
  static const double dividerThickness = 1.0;
  static const double dividerHeight = 20.0;
  static const double dividerIndent = 16.0;

  // ==================== Avatar ====================
  static const double avatarSizeXs = 24.0;
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 40.0;
  static const double avatarSizeLg = 56.0;
  static const double avatarSizeXl = 72.0;
  static const double avatarSizeXxl = 96.0;

  // ==================== List Tile ====================
  static const double listTileMinHeight = 48.0;
  static const double listTileHorizontalPadding = 16.0;

  // ==================== Progress Indicators ====================
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorStrokeWidth = 3.0;

  // ==================== Dialog ====================
  static const double dialogMaxWidth = 400.0;
  static const double dialogPadding = 24.0;
  static const double dialogRadius = 20.0;

  // ==================== Drawer ====================
  static const double drawerWidth = 300.0;
  static const double drawerHeaderHeight = 200.0;

  // ==================== Specific Use Cases ====================
  
  // Splash screen
  static const double splashLogoSize = 120.0;
  static const double splashTextSize = 24.0;
  
  // Onboarding
  static const double onboardingImageHeight = 300.0;
  static const double onboardingDotSize = 10.0;
  static const double onboardingDotActiveSize = 12.0;
  
  // Product card
  static const double productCardHeight = 280.0;
  static const double productCardImageHeight = 160.0;
  
  // Search bar
  static const double searchBarHeight = 48.0;
  
  // Bottom sheet
  static const double bottomSheetMaxHeight = 0.9; // 90% of screen
  static const double bottomSheetHandleHeight = 4.0;
  static const double bottomSheetHandleWidth = 40.0;
}

// -----------------------------------------------------------------------------
// SHAPE — Rounded philosophy (0.5 rem = 8 px baseline)
// -----------------------------------------------------------------------------

abstract class VibrantCravingsRadius {

}

