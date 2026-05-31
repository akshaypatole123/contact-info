import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = 'Contacts';

  // Paddings & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // BorderRadius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusCircular = 999.0;

  // Icon Sizes
  static const double iconSizeS = 18.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 350);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // Common Spacers (Vertical)
  static const SizedBox verticalSpaceXS = SizedBox(height: paddingXS);
  static const SizedBox verticalSpaceS = SizedBox(height: paddingS);
  static const SizedBox verticalSpaceM = SizedBox(height: paddingM);
  static const SizedBox verticalSpaceL = SizedBox(height: paddingL);
  static const SizedBox verticalSpaceXL = SizedBox(height: paddingXL);

  // Common Spacers (Horizontal)
  static const SizedBox horizontalSpaceXS = SizedBox(width: paddingXS);
  static const SizedBox horizontalSpaceS = SizedBox(width: paddingS);
  static const SizedBox horizontalSpaceM = SizedBox(width: paddingM);
  static const SizedBox horizontalSpaceL = SizedBox(width: paddingL);
  static const SizedBox horizontalSpaceXL = SizedBox(width: paddingXL);
}
