import 'package:flutter/material.dart';
import 'package:master/theme/app_colors.dart';
import 'connect_icon.dart';

/// Connect App icon tile — purple gradient rounded square with ring-mark icon.
/// Used on CrossRoad, RegisterMember, and anywhere the tile form is needed.
///
/// Usage:
///   ConnectAppIcon(size: 68)
class ConnectAppIcon extends StatelessWidget {
  final double size;

  const ConnectAppIcon({super.key, this.size = 68});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.purpleCardGradient,
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.42),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ConnectIcon(size: size * 0.52, darkMode: true),
    );
  }
}
