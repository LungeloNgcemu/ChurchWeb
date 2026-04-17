import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:master/theme/app_colors.dart';
import 'connect_icon.dart';

/// Connect App logo — ring mark + "Connect." wordmark side by side.
///
/// [size]     — height of the icon; wordmark scales to match (default 32)
/// [darkMode] — true = white wordmark + orange dot (for dark surfaces)
///              false = charcoal wordmark + orange dot (for light surfaces)
///
/// Usage:
///   ConnectLogo()                           // light bg, default size
///   ConnectLogo(size: 40, darkMode: true)   // dark bg
class ConnectLogo extends StatelessWidget {
  final double size;
  final bool darkMode;

  const ConnectLogo({super.key, this.size = 32, this.darkMode = false});

  @override
  Widget build(BuildContext context) {
    final wordColor =
        darkMode ? Colors.white : AppColors.textPrimary;
    final fontSize = size * 0.72;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConnectIcon(size: size, darkMode: darkMode),
        SizedBox(width: size * 0.28),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Connect',
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: wordColor,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              TextSpan(
                text: '.',
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
