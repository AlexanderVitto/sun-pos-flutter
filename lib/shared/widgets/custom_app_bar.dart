import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 0,
      actions: actions,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
