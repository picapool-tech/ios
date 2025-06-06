import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picapool/common/values/values.dart';

class PicaAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final bool excludeHeaderSemantics;
  final Color? foregroundColor;
  final double? toolbarHeight;
  final double? leadingWidth;
  final ShapeBorder? shape;
  final bool primary;
  final SystemUiOverlayStyle? systemOverlayStyle;
  const PicaAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.leading,
    this.flexibleSpace,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.excludeHeaderSemantics = false,
    this.foregroundColor,
    this.toolbarHeight,
    this.leadingWidth,
    this.shape,
    this.primary = true,
    this.systemOverlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      leading: leading,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      excludeHeaderSemantics: excludeHeaderSemantics,
      foregroundColor:
          foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
      leadingWidth: leadingWidth ?? kToolbarHeight,
      shape: shape ?? Theme.of(context).appBarTheme.shape,
      primary: primary,
      systemOverlayStyle: systemOverlayStyle ??
          uiOverlayStyle(
            context,
            brightness: Brightness.dark,
          ),
    );
  }
}
