import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../api/client_session.dart';
import '../auth/auth_session.dart';
import '../widgets/device_clock.dart';
import 'prototype_routes.dart';

class AppNavigationScope extends InheritedNotifier<AuthSession> {
  const AppNavigationScope({
    required AuthSession session,
    required super.child,
    super.key,
  }) : super(notifier: session);

  static AuthSession? sessionOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppNavigationScope>()
      ?.notifier;
}

abstract final class AppNavigation {
  static const _unfinishedRoutes = {
    PrototypeRoutes.newClient,
    PrototypeRoutes.counselorSignup,
    PrototypeRoutes.recording,
    PrototypeRoutes.summaryGeneration,
    PrototypeRoutes.summaryReview,
    PrototypeRoutes.textConfirm,
    PrototypeRoutes.imageLoading,
    PrototypeRoutes.imageReview,
    PrototypeRoutes.sessionComplete,
    PrototypeRoutes.sessionEnd,
  };

  static String? _exitWarning(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    if (route == PrototypeRoutes.recording ||
        route == PrototypeRoutes.sessionEnd) {
      return '화면을 나가면 진행 중인 녹음이 종료되며 저장되지 않을 수 있습니다.';
    }
    if (_unfinishedRoutes.contains(route)) {
      return '저장하지 않은 내용은 사라질 수 있습니다. 이미 요청한 처리는 서버에서 완료될 수 있습니다.';
    }
    return null;
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  static Future<void> back(
    BuildContext context, {
    String? fallbackRoute,
  }) async {
    final warning = _exitWarning(context);
    if (warning != null &&
        !await _confirm(
          context,
          title: '이전 화면으로 이동',
          message: warning,
          action: '이동하기',
        )) {
      return;
    }
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      await navigator.maybePop();
      return;
    }

    final session = AppNavigationScope.sessionOf(context);
    final home = session?.isAuthenticated == true
        ? ClientSession.clientId != null
              ? PrototypeRoutes.clientHome
              : PrototypeRoutes.dashboard
        : PrototypeRoutes.entry;
    final current = ModalRoute.of(context)?.settings.name;
    final destination =
        fallbackRoute ?? (current == home ? PrototypeRoutes.entry : home);
    if (current != destination) navigator.pushReplacementNamed(destination);
  }

  static Future<void> logout(
    BuildContext context, {
    AuthSession? authSession,
  }) async {
    final session = authSession ?? AppNavigationScope.sessionOf(context);
    if (session?.isAuthenticated != true) return;
    final warning = _exitWarning(context);
    final confirmed = await _confirm(
      context,
      title: '로그아웃',
      message: warning == null ? '로그아웃하시겠습니까?' : '로그아웃하시겠습니까?\n\n$warning',
      action: '로그아웃',
    );
    if (!confirmed || !context.mounted) return;
    ApiService().clearAuthToken();
    ClientSession.clear();
    session!.signOut();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(PrototypeRoutes.entry, (route) => false);
  }
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({this.color, this.fallbackRoute, super.key});

  final Color? color;
  final String? fallbackRoute;

  @override
  Widget build(BuildContext context) {
    final atEntry =
        ModalRoute.of(context)?.settings.name == PrototypeRoutes.entry;
    return IconButton(
      tooltip: '뒤로가기',
      color: color,
      onPressed: atEntry && !Navigator.of(context).canPop()
          ? null
          : () => AppNavigation.back(context, fallbackRoute: fallbackRoute),
      icon: const Icon(Icons.arrow_back),
    );
  }
}

class AppLogoutButton extends StatelessWidget {
  const AppLogoutButton({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final signedIn =
        AppNavigationScope.sessionOf(context)?.isAuthenticated == true;
    return TextButton.icon(
      onPressed: signedIn ? () => AppNavigation.logout(context) : null,
      style: TextButton.styleFrom(
        foregroundColor: color ?? const Color(0xFFFF6B53),
        disabledForegroundColor: (color ?? const Color(0xFF7D879C)).withValues(
          alpha: 0.5,
        ),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: const TextStyle(fontFamily: 'GowunBatang', fontSize: 13),
      ),
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('로그아웃'),
    );
  }
}

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    this.foregroundColor = const Color(0xFF1A2B49),
    this.showBack = true,
    this.showLogout = true,
    this.title,
    this.titleStyle,
    super.key,
  });

  final Color foregroundColor;
  final bool showBack;
  final bool showLogout;
  final String? title;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Row(
        children: [
          if (showBack) AppBackButton(color: foregroundColor),
          if (title == null)
            Expanded(child: DeviceClock(color: foregroundColor, fontSize: 15))
          else
            Expanded(
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style:
                    titleStyle ??
                    TextStyle(
                      color: foregroundColor,
                      fontFamily: 'GowunBatang',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          if (showLogout) AppLogoutButton(color: foregroundColor),
        ],
      ),
    );
  }
}
