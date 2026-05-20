import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_settings.dart';
import 'senior_session_screen.dart';
import 'senior_album_screen.dart';

import 'senior_settings_screen.dart';

class SeniorMain extends StatefulWidget {
  const SeniorMain({super.key});

  @override
  State<SeniorMain> createState() => _SeniorMainState();
}

class _SeniorMainState extends State<SeniorMain> {
  int _currentIndex = 0;

  void _jumpToAlbum() {
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    
    String getTitle() {
      switch (_currentIndex) {
        case 0: return "나의 다이어리";
        case 1: return "ALBUM";
        case 2: return "SETTINGS";
        default: return "";
      }
    }

    final List<Widget> screens = [
      SeniorHomeScreen(onImageTap: _jumpToAlbum),
      const SeniorAlbumScreen(),
      const SeniorSettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3B86)), // Dark blue text
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: Color(0xFF1B3B86)),
          onPressed: () {
            if (settings.isHapticEnabled) HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2C)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Colors.grey[400],
          iconSize: 32,
          selectedFontSize: 16 * settings.fontSizeMultiplier,
          unselectedFontSize: 14 * settings.fontSizeMultiplier,
          type: BottomNavigationBarType.fixed,
          onTap: (idx) {
            if (settings.isHapticEnabled) HapticFeedback.lightImpact();
            setState(() => _currentIndex = idx);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: "앨범",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "설정",
            ),
          ],
        ),
      ),
    );
  }
}
