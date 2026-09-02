import 'package:flutter/material.dart';
import 'package:erp_software/frontend/widgets/common/mobile_nav_shell.dart';

/// Hamburger menu button that opens the MobileNavShell drawer.
/// Uses the GlobalKey to open the outer shell's drawer even from nested Scaffolds.
class HamburgerButton extends StatelessWidget {
  final Color? color;
  const HamburgerButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (canPop) {
      return IconButton(
        icon: Icon(Icons.arrow_back, size: 24, color: color ?? const Color(0xFF0F172A)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
    return IconButton(
      icon: Icon(Icons.menu_rounded, size: 24, color: color ?? const Color(0xFF0F172A)),
      onPressed: () {
        appScaffoldKey.currentState?.openDrawer();
      },
    );
  }
}
