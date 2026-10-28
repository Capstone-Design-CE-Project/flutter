import 'package:flutter/widgets.dart';

enum FlowTransition { slide, slideBack, fade, none }

class PrototypeRouteArguments {
  const PrototypeRouteArguments({required this.transition, this.payload});

  final FlowTransition transition;
  final Object? payload;
}

abstract final class PrototypeRoutes {
  static const entry = '/entry';
  static const clientLogin = '/client-login';
  static const loginFailure = '/login-failure';
  static const clientHome = '/client-home';
  static const clientAlbum = '/client-album';
  static const clientSummary = '/client-summary';
  static const clientSettings = '/client-settings';
  static const counselorLogin = '/counselor-login';
  static const dashboard = '/dashboard';
  static const clientList = '/client-list';
  static const clientDetail = '/client-detail';
  static const calendar = '/calendar';
  static const newClient = '/new-client';
  static const recordingClientList = '/recording-client-list';
  static const sessionInfo = '/session-info';
  static const sessionStart = '/session-start';
  static const recording = '/recording';
  static const summaryGeneration = '/summary-generation';
  static const summaryReview = '/summary-review';
  static const textConfirm = '/text-confirm';
  static const imageLoading = '/image-loading';
  static const imageReview = '/image-review';
  static const sessionComplete = '/session-complete';
  static const sessionDetail = '/session-detail';
  static const sessionEnd = '/session-end';

  static const Set<String> publicRoutes = {
    entry,
    clientLogin,
    loginFailure,
    counselorLogin,
  };

  static bool isPublic(String route) => publicRoutes.contains(route);
}

void openPrototypeRoute(
  BuildContext context,
  String route, {
  FlowTransition transition = FlowTransition.slide,
  Object? payload,
}) {
  Navigator.of(context).pushNamed(
    route,
    arguments: PrototypeRouteArguments(
      transition: transition,
      payload: payload,
    ),
  );
}

class FlowAction extends StatelessWidget {
  const FlowAction({
    required this.route,
    required this.child,
    this.transition = FlowTransition.slide,
    this.payload,
    super.key,
  });

  final String route;
  final Widget child;
  final FlowTransition transition;
  final Object? payload;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openPrototypeRoute(
        context,
        route,
        transition: transition,
        payload: payload,
      ),
      child: child,
    );
  }
}
