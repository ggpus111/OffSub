# 📱 OffSub (오프서브)

> **Privacy-First Subscription & Payment Tracker**
> 구독 서비스, 결제 문자, 결제 이력, 가격 변동을 기기 안에서 관리하는 로컬 기반 구독 관리 앱

<p align="left">
  <img src="assets/images/logo_color.png" width="180" alt="OffSub Logo">
</p>

---

## 🧾 프로젝트 소개

**OffSub**는 사용자가 이용 중인 구독 서비스를 한곳에서 관리할 수 있도록 만든 Flutter 기반 구독 관리 앱입니다.

사용자는 구독 서비스의 이름, 결제 금액, 결제일, 카테고리를 직접 등록할 수 있고, 앱은 이를 바탕으로 월 구독 총액, 다가오는 결제, 카테고리별 지출 통계, 결제 캘린더를 제공합니다.

또한 Android 기기 내 SMS 결제 문자를 분석하여 구독 후보와 실제 결제 이력을 자동으로 정리할 수 있습니다.
모든 데이터는 서버가 아닌 기기 내부 저장소에 보관되며, 사용자는 언제든지 데이터를 내보내거나 삭제할 수 있습니다.

---

## 📸 Screen Shots

|                           홈 화면                           |                              지출 통계 화면                             |
| :------------------------------------------------------: | :---------------------------------------------------------------: |
| <img src="assets/images/홈화면.png" width="260" alt="홈 화면"> | <img src="assets/images/지출 통계 화면.png" width="260" alt="지출 통계 화면"> |
|                   **월 구독료와 다가오는 결제 확인**                  |                         **카테고리별 구독 지출 분석**                        |

|                              서비스 관리 화면                             |                            설정 화면                            |
| :----------------------------------------------------------------: | :---------------------------------------------------------: |
| <img src="assets/images/서비스관리 화면.png" width="260" alt="서비스 관리 화면"> | <img src="assets/images/설정 화면.png" width="260" alt="설정 화면"> |
|                         **구독 서비스 추가·수정·삭제**                        |                    **알림, 데이터, 로컬 사용자 설정**                   |

---

## ✨ 주요 기능

### 1. 구독 서비스 관리

* 구독 서비스 직접 추가
* 서비스명, 결제 금액, 결제일, 카테고리 설정
* 월간 결제 / 연간 결제 구분
* 등록된 구독 서비스 수정 및 삭제
* 서비스별 브랜드 색상과 아이콘 표시

---

### 2. 홈 대시보드

* 이번 달 예상 구독료 표시
* 실제 감지된 결제 금액 표시
* 구독 중인 서비스 개수 표시
* 다가오는 결제 목록 정렬
* 가격 변동 후보가 있을 경우 홈 화면에서 알림 배너 표시

---

### 3. SMS 결제 문자 기반 자동 감지

* Android SMS 접근 권한을 허용하면 최근 결제 문자를 분석
* 결제 문자에서 서비스명, 결제 금액, 결제일 추출
* 넷플릭스, 유튜브 프리미엄, 스포티파이, 디즈니+, 쿠팡 와우, 멜론, Notion 등 주요 서비스 감지
* 감지된 후보를 사용자가 선택하여 구독 목록에 추가
* 중복 구독 및 중복 결제 이력 저장 방지

---

### 4. 결제 이력 관리

* SMS에서 감지된 실제 결제 기록을 저장
* 월별 실제 결제 금액 확인
* 결제일, 결제 금액, 감지 출처 확인
* 원본 문자 일부를 함께 저장하여 감지 근거 확인 가능

---

### 5. 구독료 가격 변동 감지

* 기존 등록 금액과 최근 결제 금액 비교
* 이전 결제 이력과 최신 결제 이력 비교
* 가격이 오른 경우와 내려간 경우를 구분하여 표시
* 사용자가 확인 후 최신 금액으로 구독 정보를 반영 가능

---

### 6. 지출 통계

* 전체 월 구독료 계산
* 카테고리별 지출 금액 분석
* 원형 차트를 활용한 구독 지출 비중 시각화
* 카테고리별 금액과 비율 확인

---

### 7. 결제 캘린더

* 매월 결제 예정일을 캘린더 형태로 확인
* 날짜별 결제 예정 구독 서비스 표시
* 날짜별 결제 예정 총액 확인

---

### 8. 결제일 알림

* 등록된 구독 서비스의 결제일 기준 알림 예약
* 결제 하루 전 알림
* 결제 당일 알림
* 알림 시간은 오전 9시 기준
* 설정 화면에서 결제 알림 ON/OFF 가능

---

### 9. 로컬 데이터 기반 AI 상담

현재 AI 상담 화면은 등록된 구독 데이터를 기준으로 간단한 질문에 응답합니다.

예시 질문:

* “이번 달 구독료 얼마야?”
* “해지하면 좋을 서비스 추천해줘”
* “다음 결제 언제야?”
* “지출 줄이고 싶어”

현재 버전은 앱 내부 데이터 기반의 로컬 상담 MVP이며, 향후 Gemini Nano / AICore 기반 온디바이스 AI 상담 기능으로 확장할 수 있도록 Native Bridge 구조를 준비했습니다.

---

### 10. 앱 사용량 분석

* 등록된 구독 서비스와 실제 앱 사용 시간을 비교하는 분석 화면 제공
* 앱 사용 시간 대비 구독료를 기준으로 가성비 등급 계산
* 사용량이 낮은 구독을 절약 후보로 분류
* Android 사용 정보 접근 권한 설정 화면으로 이동 가능

> 이 기능은 Android 네이티브 사용량 데이터 연동을 전제로 한 확장 기능입니다.

---

### 11. 로컬 사용자 및 데이터 관리

* 회원가입 없이 사용자 이름만 로컬에 저장
* 사용자 이름 변경 가능
* 구독 목록과 결제 이력을 JSON 형식으로 내보내기
* 모든 구독 서비스와 결제 이력 삭제 가능
* 앱 데이터는 기기 내부 저장소에 보관

---

## 🔒 Privacy First

OffSub는 서버 계정 기반 서비스가 아니라, **로컬 중심의 구독 관리 앱**을 목표로 합니다.

* 회원가입 없이 사용 가능
* 사용자 이름만 기기 내부에 저장
* 구독 데이터는 로컬 저장소에 저장
* SMS 분석은 사용자가 권한을 허용한 경우에만 수행
* 결제 문자 분석 결과는 기기 내부에서 구독 후보와 결제 이력으로 정리
* 사용자는 언제든지 데이터를 내보내거나 삭제 가능

---

## 🛠 기술 스택

### Frontend

* **Framework:** Flutter
* **Language:** Dart
* **State Management:** Provider
* **Design System:** Material 3
* **Chart:** fl_chart
* **Local Storage:** SharedPreferences
* **Notification:** flutter_local_notifications
* **Timezone:** timezone
* **Utility:** intl, uuid

### Native Android

* **Language:** Kotlin
* **Bridge:** Flutter MethodChannel
* **SMS Access:** Android READ_SMS Permission
* **Settings Intent:** Usage Access Settings 이동
* **Local Notification Permission:** Android POST_NOTIFICATIONS

---

## 📂 프로젝트 구조

```text
lib/
├── main.dart
│
├── models/
│   ├── subscription.dart
│   ├── payment_record.dart
│   ├── price_change_alert.dart
│   └── app_usage_insight.dart
│
├── providers/
│   └── subscription_provider.dart
│
├── services/
│   ├── native_bridge.dart
│   ├── notification_service.dart
│   ├── sms_subscription_detector.dart
│   ├── sms_subscription_candidate.dart
│   └── app_usage_analyzer.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── services_screen.dart
│   ├── statistics_screen.dart
│   ├── calendar_screen.dart
│   ├── chat_screen.dart
│   ├── settings_screen.dart
│   ├── add_service_screen.dart
│   ├── permission_screen.dart
│   ├── detected_subscriptions_screen.dart
│   ├── payment_history_screen.dart
│   ├── price_change_screen.dart
│   └── app_usage_analysis_screen.dart
│
└── widgets/
    ├── empty_state_widget.dart
    └── subscription_card.dart
```

---

## 🧩 핵심 구현 흐름

### 구독 데이터 저장 흐름

```text
사용자 입력
→ AddServiceScreen
→ Subscription 모델 생성
→ SubscriptionProvider에 추가
→ SharedPreferences에 JSON 저장
→ 홈 / 통계 / 캘린더 / 설정 화면에 반영
```

---

### SMS 자동 감지 흐름

```text
서비스 관리 화면
→ 문자 자동 감지 버튼
→ 권한 안내 화면
→ READ_SMS 권한 요청
→ Android Native에서 SMS Inbox 조회
→ SmsSubscriptionDetector가 결제 문자 분석
→ 감지 후보 표시
→ 사용자가 선택한 항목을 구독 목록과 결제 이력에 저장
```

---

### 결제 이력 및 가격 변동 흐름

```text
SMS 결제 문자 감지
→ PaymentRecord 저장
→ 기존 구독 금액과 최근 결제 금액 비교
→ 금액 차이가 있으면 PriceChangeAlert 생성
→ 가격 변동 화면에서 확인
→ 최신 금액으로 구독 정보 반영
```

---

### 결제 알림 흐름

```text
앱 실행
→ NotificationService 초기화
→ 저장된 구독 목록 로드
→ 결제 하루 전 / 결제 당일 알림 예약
→ 설정 화면에서 알림 ON/OFF 관리
```

---

## 🚀 실행 방법

### 1. 패키지 설치

```bash
flutter pub get
```

### 2. 앱 실행

```bash
flutter run
```

---

## 📱 Android 권한 안내

OffSub의 일부 기능은 Android 권한이 필요합니다.

| 권한                   | 사용 목적       |
| :------------------- | :---------- |
| READ_SMS             | 결제 문자 분석    |
| RECEIVE_SMS          | 문자 관련 확장 기능 |
| POST_NOTIFICATIONS   | 결제일 알림      |
| SCHEDULE_EXACT_ALARM | 예약 알림       |
| PACKAGE_USAGE_STATS  | 앱 사용량 분석    |

SMS 자동 감지 기능은 실제 문자 데이터가 필요하므로, 에뮬레이터보다 실제 Android 기기에서 테스트하는 것을 권장합니다.

---

## 🧪 테스트용 SMS 예시

에뮬레이터에서 SMS 감지 기능을 테스트하려면 ADB를 통해 테스트 문자를 넣을 수 있습니다.

```bash
adb emu sms send 01012345678 "[승인] 유튜브 프리미엄 14,900원 정기결제"
adb emu sms send 01012345678 "[승인] 스포티파이 10,900원 자동결제"
adb emu sms send 01012345678 "[승인] 디즈니+ 9,900원 결제"
adb emu sms send 01012345678 "[승인] 쿠팡 와우 7,890원 정기결제"
```

---

## 👥 팀원 역할

| 역할                  | 담당 내용                                                          |
| :------------------ | :------------------------------------------------------------- |
| Backend / Native 연동 | 데이터 모델 설계, 로컬 저장 구조, SMS 분석 로직, MethodChannel, 결제 이력, 가격 변동 감지 |
| Frontend            | Flutter UI 화면 구성, Material 3 디자인, 홈/통계/캘린더/설정 화면 구현            |

---

## 📌 개발 목적

현대 사용자는 다양한 구독 서비스를 이용하지만, 매달 얼마를 지출하고 있는지 정확히 파악하지 못하는 경우가 많습니다.

OffSub는 이러한 문제를 해결하기 위해 흩어진 구독 정보를 한곳에 모으고, 결제 문자와 사용 데이터를 바탕으로 불필요한 구독을 점검할 수 있도록 돕는 것을 목표로 합니다.

---

## 🔮 향후 개선 계획

* Gemini Nano / AICore 기반 온디바이스 AI 상담 고도화
* 앱 사용량 분석을 위한 Android UsageStatsManager 네이티브 연동 완성
* 더 다양한 구독 서비스 감지 규칙 추가
* 결제 문자 분석 정확도 개선
* 구독 해지 가이드 제공
* 구독별 상세 리포트 화면 추가
* 데이터 백업 / 복원 기능 추가

---

## 📄 License

This project is for educational and portfolio purposes.
