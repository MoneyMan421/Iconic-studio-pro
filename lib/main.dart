import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'auth_screen.dart';
import 'studio_page.dart';

export 'editor_state.dart';
export 'studio_page.dart';

void main() => runApp(const IconStudioPro());

class IconStudioPro extends StatelessWidget {
  const IconStudioPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.gold,
          inactiveTrackColor: AppColors.panelBorder,
          thumbColor: AppColors.gold,
          overlayColor: AppColors.gold.withValues(alpha: 0.2),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
      ),
      home: const AuthGate(child: StudioPage()),
    );
  }
}
