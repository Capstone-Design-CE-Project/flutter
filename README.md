# 기억의 조각 (Flutter)

내담자와 상담사가 상담 일정, 요약, 회상 이미지, 상담 기록을 확인하고 관리하는 Flutter 앱입니다.

이 안내는 **백엔드 서버와 필요한 API가 이미 실행 중이고 접속 가능한 상태**라고 가정합니다. 백엔드 서버를 실행하거나 배포하는 방법은 여기서 다루지 않습니다.

## 준비물

- Flutter SDK
- Dart SDK 3.10.4 이상 (`pubspec.yaml` 기준)
- 웹 실행: Chrome
- Android 실행: Android Studio와 Android Emulator 권장

Flutter 설치와 기기 인식 상태는 프로젝트 폴더에서 확인할 수 있습니다.

```powershell
flutter --version
flutter doctor
flutter devices
```

## 백엔드 주소 설정

앱의 API 기본 주소는 [lib/api/api_service.dart](lib/api/api_service.dart)의 `ApiService` 생성자에 있습니다.

```dart
ApiService({String baseUrl = 'http://3.36.70.79:8000', Dio? dio})
```

사용할 백엔드 서버 주소가 다르면 `baseUrl`을 서버의 접속 가능한 기본 주소로 바꿉니다. 예를 들어 개발용 서버가 `192.168.0.20`의 8000 포트에서 실행 중이면 다음처럼 설정합니다.

```dart
ApiService({String baseUrl = 'http://192.168.0.20:8000', Dio? dio})
```

- `http://` 또는 `https://`, 호스트, 필요하면 포트까지 입력합니다.
- `/auth/client/login` 같은 API 경로는 기본 주소에 붙이지 않습니다. 각 API 경로는 앱 코드에서 따로 지정합니다.
- 웹에서 실행하려면 브라우저가 해당 서버 주소에 접속할 수 있어야 합니다. 브라우저의 CORS 오류가 나면 백엔드에서 Flutter 웹 개발 주소를 허용해야 합니다.
- Android Emulator에서 개발 PC의 백엔드에 접속할 때는 `localhost`가 Emulator 자신을 가리킵니다. 개발 PC에서 서버를 실행 중이라면 `10.0.2.2:<포트>`를 사용하거나, PC의 네트워크 주소를 사용하세요.
- 실제 Android 기기에서는 PC와 기기가 같은 네트워크에 있어야 하며, `localhost` 대신 PC의 LAN 주소나 배포 서버 주소를 사용합니다.
- 로그인, 상담 기록, 일정, 이미지 생성 등은 백엔드 API 응답을 사용합니다. 테스트 계정과 데이터는 백엔드 운영 담당자에게 확인하세요.

## 의존성 설치

프로젝트 루트에서 실행합니다.

```powershell
flutter pub get
```

## 웹에서 실행

Chrome이 설치되어 있고 백엔드 주소가 설정되어 있는지 확인한 다음 실행합니다.

```powershell
flutter run -d chrome
```

실행 가능한 기기를 확인하려면 `flutter devices`를 사용합니다. 다른 웹 기기나 디바이스 ID를 선택하려면 다음처럼 실행할 수 있습니다.

```powershell
flutter run -d <device-id>
```

웹에서는 브라우저가 마이크 사용 권한을 요청할 수 있습니다. 녹음 기능을 테스트할 때 권한을 허용하세요.

## Android Emulator에서 실행 (권장)

Android Studio가 설치되어 있다면 Android Studio의 **Device Manager**에서 가상 기기를 만들고 시작한 뒤, Flutter 앱을 그 기기에서 실행하는 방법을 권장합니다.

1. Android Studio를 설치하고 시작합니다. 프로젝트를 열지 않아도 시작 화면의 **Device Manager** 또는 **Tools > Device Manager**에서 가상 기기를 만들 수 있습니다.
2. 가상 기기를 생성한 뒤 **Start**를 눌러 부팅합니다.
3. Flutter 프로젝트 루트에서 `flutter devices`를 실행해 가상 기기가 표시되는지 확인합니다.
4. VS Code를 사용한다면 상태 표시줄의 기기 선택 메뉴에서 실행 중인 Emulator를 선택합니다. 터미널에서는 다음처럼 실행합니다.

```powershell
flutter run -d <emulator-device-id>
```

Android Studio에서 직접 Flutter 앱을 실행하려면 Flutter 플러그인을 설치하고 Flutter 프로젝트 루트를 연 다음, 상단 기기 메뉴에서 Emulator를 선택하고 **Run**을 누릅니다. 녹음 기능을 테스트할 때는 Emulator 또는 기기의 마이크 권한을 허용해야 합니다.

## 주요 실행 명령

```powershell
# 코드 분석
flutter analyze

# 웹 빌드
flutter build web

# Android 디버그 APK 빌드
flutter build apk --debug
```
# 웹 미리보기 
flutter run -d web-server --web-port 5400
## 참고

- Android 전화번호 선택 기능은 Android에서 제공되는 번호 선택 UI를 사용합니다. 번호를 가져오지 못하거나 지원되지 않는 플랫폼에서는 전화번호를 직접 입력합니다.
- 접근성 설정(글자 크기, 다크 모드, 터치 진동)은 앱 설정으로 저장됩니다.
- `backend/`의 코드와 서버 설정은 이 README의 Flutter 실행 절차에 포함되지 않습니다.
