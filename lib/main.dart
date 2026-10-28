import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'auth/auth_session.dart';
import 'config/app_settings.dart';
import 'api/consultation_model.dart' show ClientDetail;
import 'navigation/auth_route_guard.dart';
import 'navigation/prototype_routes.dart';
import 'screens/ClientScreen/client_album.dart' show ClientalbumWidget;
import 'screens/ClientScreen/client_home.dart' show ClienthomeWidget;
import 'screens/ClientScreen/client_login.dart' show ClientloginWidget;
import 'screens/ClientScreen/client_settings.dart' show ClientsettingsWidget;
import 'screens/ClientScreen/client_summary_detail.dart'
    show ClientsummarydetailWidget;
import 'screens/CounselorScreen/calendar.dart' show CalendarV3;
import 'screens/CounselorScreen/client_detail.dart' show ClientDetailV3;
import 'screens/CounselorScreen/client_list.dart' show ClientList;
import 'screens/CounselorScreen/client_list_recording.dart'
    show ClientListRecordingV3;
import 'screens/CounselorScreen/counselor_login.dart' show CounselorLoginV3;
import 'screens/CounselorScreen/counselor_signup.dart'
    show CounselorsignupWidget;
import 'screens/CounselorScreen/dashboard.dart' show DashboardWidget;
import 'screens/CounselorScreen/image_generation_loading.dart'
    show ImageGenerationLoading;
import 'screens/CounselorScreen/image_review.dart' show ImageReviewV3;
import 'screens/CounselorScreen/new_client_form.dart' show NewClientForm;
import 'screens/CounselorScreen/recording.dart' show RecordingV3;
import 'screens/CounselorScreen/session_complete.dart' show SessionCompleteV3;
import 'screens/CounselorScreen/session_detail.dart' show SessionDetailV3;
import 'screens/CounselorScreen/session_end_popup.dart' show SessionEndPopupV3;
import 'screens/CounselorScreen/session_info_input.dart'
    show SessionInfoInputV3;
import 'screens/CounselorScreen/session_start_popup.dart'
    show SessionStartPopupV3;
import 'screens/CounselorScreen/summary_generation_loading.dart'
    show SummaryGenerationLoading, SummaryGenerationRequest;
import 'screens/CounselorScreen/summary_review.dart' show SummaryReviewV3;
import 'screens/CounselorScreen/session_flow_payloads.dart'
    show
        ImageGenerationRequest,
        ImageReviewRoutePayload,
        SessionCompleteRoutePayload,
        SessionEndConfirmationRequest,
        SummaryReviewRoutePayload;
import 'screens/CounselorScreen/text_confirm_popup.dart' show TextConfirmPopup;
import 'screens/login_failure.dart' show LoginFailureScreen;
import 'screens/splash_title.dart' show SplashtitleWidget;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.load();
  runApp(SeniorCareApp(settings: settings, authSession: AuthSession()));
}

class SeniorCareApp extends StatefulWidget {
  const SeniorCareApp({
    required this.settings,
    required this.authSession,
    super.key,
  });

  final AppSettings settings;
  final AuthSession authSession;

  @override
  State<SeniorCareApp> createState() => _SeniorCareAppState();
}

class _SeniorCareAppState extends State<SeniorCareApp> {
  final Map<int, Offset> _touchOrigins = {};

  AppSettings get _settings => widget.settings;

  void _handlePointerDown(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.touch) {
      _touchOrigins[event.pointer] = event.position;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    final origin = _touchOrigins.remove(event.pointer);
    if (origin == null ||
        !_settings.isHapticEnabled ||
        (event.position - origin).distance > kTouchSlop) {
      return;
    }
    unawaited(HapticFeedback.selectionClick());
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _touchOrigins.remove(event.pointer);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsProvider(
      notifier: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) {
          final bool isDark = _settings.isDarkMode;
          const Color coral = Color(0xFFFF6B53);
          final Color primaryColor = isDark ? const Color(0xFFFF8E7C) : coral;
          const Color accentColor = coral;
          final Color surfaceColor = isDark
              ? const Color(0xFF121212)
              : Colors.white;

          return Listener(
            onPointerDown: _handlePointerDown,
            onPointerUp: _handlePointerUp,
            onPointerCancel: _handlePointerCancel,
            child: MaterialApp(
              title: 'Senior Care App',
              debugShowCheckedModeBanner: false,
              initialRoute: PrototypeRoutes.entry,
              onGenerateRoute: _generateRoute,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final textScaler = TextScaler.linear(
                  _settings.fontSizeMultiplier,
                );
                final appChild = child ?? const SizedBox.shrink();

                if (!kIsWeb) {
                  return MediaQuery(
                    data: mediaQuery.copyWith(textScaler: textScaler),
                    child: appChild,
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = math.min(
                      constraints.maxWidth,
                      constraints.maxHeight * (402 / 874),
                    );
                    final height = width * (874 / 402);
                    return ColoredBox(
                      color: const Color(0xFF1A2B49),
                      child: Center(
                        child: Container(
                          width: width,
                          height: height,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 32,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 402,
                              height: 874,
                              child: MediaQuery(
                                data: mediaQuery.copyWith(
                                  size: const Size(402, 874),
                                  textScaler: textScaler,
                                ),
                                child: appChild,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              theme: ThemeData(
                useMaterial3: true,
                brightness: isDark ? Brightness.dark : Brightness.light,
                fontFamily: 'GowunBatang',
                colorScheme:
                    ColorScheme.fromSeed(
                      seedColor: accentColor,
                      brightness: isDark ? Brightness.dark : Brightness.light,
                    ).copyWith(
                      primary: primaryColor,
                      onPrimary: isDark
                          ? const Color(0xFF10212E)
                          : Colors.white,
                      secondary: accentColor,
                      surface: surfaceColor,
                      onSurface: isDark
                          ? Colors.white
                          : const Color(0xFF003366),
                    ),
                scaffoldBackgroundColor: surfaceColor,
                appBarTheme: AppBarTheme(
                  backgroundColor: surfaceColor,
                  foregroundColor: isDark ? Colors.white : primaryColor,
                  elevation: 0,
                  centerTitle: true,
                ),
                cardTheme: CardThemeData(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  surfaceTintColor: Colors.transparent,
                ),
                switchTheme: SwitchThemeData(
                  thumbColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? primaryColor
                        : null,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark
                        ? const Color(0xFF10212E)
                        : Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    elevation: 2,
                  ),
                ),
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark
                        ? const Color(0xFF1A2B49)
                        : Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final pages = <String, Widget>{
      PrototypeRoutes.entry: const SplashtitleWidget(),
      PrototypeRoutes.clientLogin: ClientloginWidget(
        authSession: widget.authSession,
      ),
      PrototypeRoutes.loginFailure: const LoginFailureScreen(),
      PrototypeRoutes.clientHome: const ClienthomeWidget(),
      PrototypeRoutes.clientAlbum: const ClientalbumWidget(),
      PrototypeRoutes.clientSummary: const ClientsummarydetailWidget(),
      PrototypeRoutes.clientSettings: ClientsettingsWidget(
        authSession: widget.authSession,
      ),
      PrototypeRoutes.counselorLogin: CounselorLoginV3(
        authSession: widget.authSession,
      ),
      PrototypeRoutes.counselorSignup: const CounselorsignupWidget(),
      PrototypeRoutes.dashboard: DashboardWidget(
        authSession: widget.authSession,
      ),
      PrototypeRoutes.clientList: const ClientList(),
      PrototypeRoutes.clientDetail: const ClientDetailV3(),
      PrototypeRoutes.calendar: const CalendarV3(),
      PrototypeRoutes.newClient: const NewClientForm(),
      PrototypeRoutes.recordingClientList: const ClientListRecordingV3(),
      PrototypeRoutes.sessionInfo: const SessionInfoInputV3(),
      PrototypeRoutes.sessionStart: const SessionStartPopupV3(),
      PrototypeRoutes.recording: const RecordingV3(),
      PrototypeRoutes.summaryGeneration: const SummaryGenerationLoading(),
      PrototypeRoutes.summaryReview: const SummaryReviewV3(),
      PrototypeRoutes.textConfirm: const TextConfirmPopup(),
      PrototypeRoutes.imageLoading: const ImageGenerationLoading(),
      PrototypeRoutes.imageReview: const ImageReviewV3(),
      PrototypeRoutes.sessionComplete: const SessionCompleteV3(),
      PrototypeRoutes.sessionDetail: const SessionDetailV3(),
      PrototypeRoutes.sessionEnd: SessionEndPopupV3(),
    };
    final requestedPage = pages[settings.name];
    if (requestedPage == null) {
      if (settings.name == '/') return null;
      throw FlutterError('Unknown prototype route: ${settings.name}');
    }

    final requestedRoute = settings.name!;
    final routeName = AuthRouteGuard(
      widget.authSession,
    ).resolve(requestedRoute);
    final wasRedirected = routeName != requestedRoute;
    final effectiveSettings = wasRedirected
        ? const RouteSettings(name: PrototypeRoutes.entry)
        : settings;
    final routeArguments =
        !wasRedirected && settings.arguments is PrototypeRouteArguments
        ? settings.arguments! as PrototypeRouteArguments
        : null;
    final configuredPage = wasRedirected
        ? pages[PrototypeRoutes.entry]!
        : requestedPage;

    final payload = routeArguments?.payload;
    final page = routeName == PrototypeRoutes.clientSummary
        ? ClientsummarydetailWidget(sessionId: payload is int ? payload : null)
        : routeName == PrototypeRoutes.clientDetail
        ? ClientDetailV3(clientId: payload is int ? payload : null)
        : routeName == PrototypeRoutes.sessionInfo
        ? SessionInfoInputV3(clientId: payload is int ? payload : null)
        : routeName == PrototypeRoutes.sessionStart
        ? SessionStartPopupV3(clientId: payload is int ? payload : null)
        : routeName == PrototypeRoutes.recording
        ? RecordingV3(clientId: payload is int ? payload : null)
        : routeName == PrototypeRoutes.summaryGeneration
        ? SummaryGenerationLoading(
            request: payload is SummaryGenerationRequest ? payload : null,
          )
        : routeName == PrototypeRoutes.summaryReview
        ? SummaryReviewV3(
            routePayload: payload is SummaryReviewRoutePayload ? payload : null,
          )
        : routeName == PrototypeRoutes.textConfirm
        ? TextConfirmPopup(
            routePayload: payload is SummaryReviewRoutePayload ? payload : null,
          )
        : routeName == PrototypeRoutes.imageLoading
        ? ImageGenerationLoading(
            request: payload is ImageGenerationRequest ? payload : null,
          )
        : routeName == PrototypeRoutes.imageReview
        ? ImageReviewV3(
            routePayload: payload is ImageReviewRoutePayload ? payload : null,
          )
        : routeName == PrototypeRoutes.sessionComplete
        ? SessionCompleteV3(
            routePayload: payload is SessionCompleteRoutePayload
                ? payload
                : null,
          )
        : routeName == PrototypeRoutes.sessionEnd
        ? SessionEndPopupV3(
            request: payload is SessionEndConfirmationRequest ? payload : null,
          )
        : routeName == PrototypeRoutes.sessionDetail
        ? SessionDetailV3(sessionId: payload is int ? payload : null)
        : routeName == PrototypeRoutes.newClient
        ? NewClientForm(initialClient: payload is ClientDetail ? payload : null)
        : configuredPage;
    final transition = wasRedirected
        ? FlowTransition.none
        : routeArguments?.transition ??
              (settings.arguments is FlowTransition
                  ? settings.arguments! as FlowTransition
                  : FlowTransition.slide);
    return PageRouteBuilder<dynamic>(
      settings: effectiveSettings,
      transitionDuration: transition == FlowTransition.none
          ? Duration.zero
          : const Duration(milliseconds: 300),
      reverseTransitionDuration: transition == FlowTransition.none
          ? Duration.zero
          : const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transition) {
          case FlowTransition.none:
            return child;
          case FlowTransition.fade:
            return FadeTransition(opacity: animation, child: child);
          case FlowTransition.slide:
          case FlowTransition.slideBack:
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: transition == FlowTransition.slide
                        ? const Offset(1, 0)
                        : const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    ),
                  ),
              child: child,
            );
        }
      },
    );
  }
}
