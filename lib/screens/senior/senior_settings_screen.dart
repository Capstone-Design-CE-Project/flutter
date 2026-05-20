import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_settings.dart';
import '../../config/constants.dart';

class SeniorSettingsScreen extends StatelessWidget {
  const SeniorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    final scale = settings.fontSizeMultiplier;
    final primaryColor = const Color(0xFF001B3B); // Dark blue used in mockup

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "TT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "글자 크기 조절",
                  style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _sizeButton(context, "중간", 1.2, settings, scale, primaryColor),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _sizeButton(context, "크게", 1.5, settings, scale, primaryColor),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _sizeButton(context, "아주 크게", 1.9, settings, scale, primaryColor),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "고대비 모드",
                          style: TextStyle(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "화면을 더 선명하게 봅니다",
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Switch(
                      value: settings.isHighContrast,
                      onChanged: (v) {
                        if (settings.isHapticEnabled) {
                          HapticFeedback.lightImpact();
                        }
                        settings.toggleHighContrast(v);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.grey[400],
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "터치 진동",
                          style: TextStyle(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "누를 때마다 진동이 느껴집니다",
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Switch(
                      value: settings.isHapticEnabled,
                      onChanged: (v) {
                        if (v) HapticFeedback.vibrate();
                        settings.toggleHaptic(v);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.grey[400],
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.help_outline, color: Colors.black87, size: 24 * scale),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Colors.black87,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: Text(
                  "도움말 및 지원",
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _sizeButton(
    BuildContext context,
    String label,
    double buttonScale,
    AppSettings settings,
    double scale,
    Color primaryColor,
  ) {
    bool isSelected = settings.fontSizeMultiplier == buttonScale;
    return ElevatedButton(
      onPressed: () {
        if (settings.isHapticEnabled) HapticFeedback.lightImpact();
        settings.setFontSize(buttonScale);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? primaryColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
