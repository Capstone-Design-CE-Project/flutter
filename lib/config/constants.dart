import 'package:flutter/material.dart';

// 색상 상수
class AppColors {
  static const Color primary = Color(0xFF003366);
  static const Color accent = Color(0xFF0EA5E9);
  static const Color darkAccent = Color(0xFF0284C7);
  static const Color darkestAccent = Color(0xFF075985);
}

// 텍스트 스타일 상수
class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

// API 모의 데이터
class MockData {
  static const String counselorId = "admin";
  static const String counselorPassword = "1234";
  static const String seniorPin = "1234";
}

// 텍스트 상수
class AppTexts {
  // Login
  static const String passwordInput = "비밀번호 입력";
  static const String enterPassword = "본인 확인을 위해\n비밀번호를 입력해주세요.";
  static const String passwordLabel = "비밀번호";
  static const String loginButton = "ID 접속";
  static const String counselorLoginButton = "상담사 로그인";
  static const String wrongPassword = "비밀번호가 틀렸습니다.";
  static const String helpCenter = "고객센터 1588-0000";

  // Senior
  static const String myDiary = "나의 다이어리";
  static const String album = "앨범";
  static const String settings = "설정";
  static const String nextConsultation = "🗓️ 다음 상담 약속";
  static const String fontSizeAdjust = "🔠 글자 크기 조절";
  static const String highContrastMode = "고대비 모드";
  static const String hapticFeedback = "터치 진동";

  // Counselor
  static const String counselorLogin = "상담사 로그인";
  static const String counselorId = "상담사 ID";
  static const String consultationSystem = "상담 관리 시스템";
  static const String clientList = "면담자 리스트";
  static const String calendar = "일정 달력";
  static const String newConsultation = "새 상담 시작";
  static const String wrongIdPassword = "ID 또는 비밀번호가 틀렸습니다.";
}
