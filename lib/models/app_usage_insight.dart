import 'subscription.dart';

enum UsageValueGrade {
  high,
  medium,
  low,
  unknown,
}

extension UsageValueGradeX on UsageValueGrade {
  String get label {
    switch (this) {
      case UsageValueGrade.high:
        return '가성비 좋음';
      case UsageValueGrade.medium:
        return '확인 필요';
      case UsageValueGrade.low:
        return '절약 후보';
      case UsageValueGrade.unknown:
        return '사용량 없음';
    }
  }

  String get description {
    switch (this) {
      case UsageValueGrade.high:
        return '결제 금액 대비 사용 시간이 충분해요.';
      case UsageValueGrade.medium:
        return '사용량이 애매해서 유지 여부를 확인해보면 좋아요.';
      case UsageValueGrade.low:
        return '돈은 나가는데 사용 시간이 적어요.';
      case UsageValueGrade.unknown:
        return '연결된 앱 사용 기록을 찾지 못했어요.';
    }
  }
}

class AppUsageInsight {
  final Subscription subscription;
  final String appName;
  final String packageName;
  final int usageMinutes;
  final UsageValueGrade grade;
  final double? costPerHour;
  final String reason;

  const AppUsageInsight({
    required this.subscription,
    required this.appName,
    required this.packageName,
    required this.usageMinutes,
    required this.grade,
    required this.costPerHour,
    required this.reason,
  });

  int get monthlyAmount => subscription.monthlyAmount;
  bool get hasUsage => usageMinutes > 0;
}
