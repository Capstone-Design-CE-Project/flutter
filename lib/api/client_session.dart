class ClientSession {
  ClientSession._();

  static int? clientId;
  static String? loginId;

  static void start({
    required int clientId,
    required String loginId,
  }) {
    ClientSession.clientId = clientId;
    ClientSession.loginId = loginId;
  }

  static void clear() {
    clientId = null;
    loginId = null;
  }
}
