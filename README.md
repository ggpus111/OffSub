# 📱 OffSub (오프서브)
> **Privacy-Preserving On-Device AI Subscription Manager** > 사용자의 프라이버시를 최우선으로 생각하는 온디바이스 AI 기반 구독 관리 플랫폼

<p align="left">
  <img src="assets/images/logo_color.png" width="180" alt="OffSub Logo">
</p>

OffSub은 Android 16의 **Gemini Nano**를 활용하여 결제 내역과 앱 사용 시간을 로컬에서 분석하고, 서버 전송 없이 안전하고 스마트한 구독 해지 가이드를 제공합니다.

---

## 📸 Screen Shots

| 홈 화면 | 지출 통계 화면 |
| :---: | :---: |
| <img src="assets/images/홈화면.png" width="260" alt="홈 화면"> | <img src="assets/images/지출 통계 화면.png" width="260" alt="지출 통계 화면"> |
| **구독 현황 및 소비 요약** | **구독 지출 통계 및 분석** |
| **서비스 관리 화면** | **설정 화면** |
| <img src="assets/images/서비스관리 화면.png" width="260" alt="서비스 관리 화면"> | <img src="assets/images/설정 화면.png" width="260" alt="설정 화면"> |
| **구독 서비스 추가 및 해지 관리** | **온디바이스 AI 및 보안 설정** |

---

## ✨ 핵심 기능 (Core Features)

* **🔒 Privacy First (Zero-Server)**
  * 모든 데이터 처리는 외부 서버 전송 없이 **100% 기기 내부**에서만 안전하게 수행됩니다.
* **🤖 On-Device AI Chat**
  * 내장된 `Gemini Nano` 인프라를 통해 데이터 유출 걱정 없는 개인 맞춤형 구독 해지 및 소비 상담을 제공합니다.
* **🔔 Smart Subscription Tracker**
  * Android의 `NotificationListenerService`를 기반으로 결제 알림을 실시간 감지하여 구독 정보를 자동 등록합니다.
* **📊 App Usage Analysis**
  * `UsageStatsManager`로 실제 앱 사용 시간을 정밀 분석하여, 비용만 지불되고 있는 미사용 구독(좀비 구독)을 탐지합니다.

---

## 🛠 기술 스택 (Tech Stack)

### Frontend & Architecture
- **Framework:** Flutter (`Dart`)
- **State Management:** Provider
- **Design System:** Material 3, Pretendard Font

### Native & AI (Android 16+)
- **Local AI:** Google Gemini Nano (`AICore`)
- **Native Bridge:** `MethodChannel` 
  - Android `UsageStatsManager` (앱 사용량 데이터 추출)
  - Android `NotificationListenerService` (결제 알림 텍스트 파싱)

---

## 📂 프로젝트 구조 (Project Structure)

```text
lib/
├── models/          # 데이터 모델 정의 (Subscription, Usage 등)
├── services/        # 네이티브 시스템 연동 로직 (MethodChannel, AI Bridge)
└── screens/         # UI 화면 구성
    ├── auth/        # 사용자 인증 및 로그인
    ├── onboarding/  # 서비스 최초 진입 온보딩 가이드
    ├── dashboard/   # 메인 대시보드 (홈 / 지출 통계 / 서비스 관리)
    └── chat/        # Gemini Nano 기반 AI 챗봇 화면
