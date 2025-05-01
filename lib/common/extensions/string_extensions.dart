import 'dart:ui';

import 'package:picapool/common/functions/color_function.dart';

extension ColorFromString on String {
  Color get toColor => getColorFromString(this);
}
