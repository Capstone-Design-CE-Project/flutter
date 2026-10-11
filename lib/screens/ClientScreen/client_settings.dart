import 'package:flutter/material.dart';

import '../../config/app_settings.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class ClientsettingsWidget extends StatelessWidget {
  const ClientsettingsWidget({super.key});

  Future<void> _apply(
    BuildContext context,
    Future<void> Function() change,
  ) async {
    try {
      await change();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('설정을 저장하지 못했습니다: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    const coral = Color(0xFFFF6B53);
    final theme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: coral,
        secondary: coral,
        onPrimary: Colors.white,
        secondaryContainer: const Color(0xFFFFE6E0),
        onSecondaryContainer: const Color(0xFF1A2B49),
      ),
      radioTheme: const RadioThemeData(
        fillColor: WidgetStatePropertyAll(coral),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? coral : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? coral.withValues(alpha: 0.45)
              : null,
        ),
      ),
    );
    final colors = theme.colorScheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Row(
                  children: [
                    DeviceClock(color: colors.onSurface),
                    const Spacer(),
                    Text(
                      '설정',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: coral,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '글자 크기 조절',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '앱 화면의 글자 크기를 선택할 수 있습니다.',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            RadioGroup<double>(
                              groupValue: settings.fontSizeMultiplier,
                              onChanged: (value) {
                                if (value != null) {
                                  _apply(
                                    context,
                                    () => settings.setFontSize(value),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  for (final option in const [
                                    (label: '작게 (기본)', multiplier: 0.9),
                                    (label: '보통', multiplier: 1.0),
                                    (label: '크게', multiplier: 1.2),
                                    (label: '가장 크게', multiplier: 1.4),
                                  ])
                                    RadioListTile<double>(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(option.label),
                                      value: option.multiplier,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: const Text('다크 모드'),
                        subtitle: const Text('어두운 배경과 밝은 글자로 표시합니다.'),
                        value: settings.isDarkMode,
                        onChanged: (value) =>
                            _apply(context, () => settings.setDarkMode(value)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: const Text('터치 진동 피드백'),
                        subtitle: const Text('화면을 가볍게 누를 때 기기가 진동합니다.'),
                        value: settings.isHapticEnabled,
                        onChanged: (value) =>
                            _apply(context, () => settings.toggleHaptic(value)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: const Color.fromRGBO(255, 107, 83, 0.12),
                      child: const ListTile(
                        leading: Icon(Icons.help_outline),
                        title: Text('도움말 및 간편 사용 지원'),
                        subtitle: Text('화면 사용에 도움이 필요하면 상담사에게 문의해 주세요.'),
                      ),
                    ),
                  ],
                ),
              ),
              _BottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavigationItem(
              icon: Icons.home_outlined,
              label: '홈',
              route: PrototypeRoutes.clientHome,
            ),
            _NavigationItem(
              icon: Icons.photo_album_outlined,
              label: '앨범',
              route: PrototypeRoutes.clientAlbum,
            ),
            _NavigationItem(
              icon: Icons.settings_outlined,
              label: '설정',
              selected: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    this.route,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String? route;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: selected ? colors.primary : colors.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: selected ? colors.primary : colors.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (route == null) return child;
    return FlowAction(
      route: route!,
      transition: FlowTransition.fade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }
}
