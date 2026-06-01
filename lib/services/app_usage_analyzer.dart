import '../models/app_usage_insight.dart';
import '../models/subscription.dart';

class AppUsageAnalyzer {
  static const Map<String, List<String>> _knownPackages = {
    '넷플릭스': ['com.netflix.mediaclient'],
    'netflix': ['com.netflix.mediaclient'],
    '유튜브': ['com.google.android.youtube', 'com.google.android.apps.youtube.music'],
    'youtube': ['com.google.android.youtube', 'com.google.android.apps.youtube.music'],
    '유튜브프리미엄': ['com.google.android.youtube', 'com.google.android.apps.youtube.music'],
    '스포티파이': ['com.spotify.music'],
    'spotify': ['com.spotify.music'],
    '디즈니': ['com.disney.disneyplus'],
    'disney': ['com.disney.disneyplus'],
    '쿠팡': ['com.coupang.mobile', 'com.coupang.mobile.play'],
    '멜론': ['com.iloen.melon'],
    'melon': ['com.iloen.melon'],
    'notion': ['notion.id'],
    '노션': ['notion.id'],
  };

  static List<AppUsageInsight> analyze({
    required List<Subscription> subscriptions,
    required List<dynamic> rawUsageStats,
  }) {
    final usageRows = rawUsageStats
        .whereType<Map>()
        .map((row) => _UsageRow.fromMap(row))
        .where((row) => row.usageMinutes > 0 || row.packageName.isNotEmpty)
        .toList();

    final insights = <AppUsageInsight>[];

    for (final subscription in subscriptions) {
      final matched = _findBestMatch(subscription, usageRows);
      if (matched == null) {
        insights.add(
          AppUsageInsight(
            subscription: subscription,
            appName: subscription.name,
            packageName: '',
            usageMinutes: 0,
            grade: UsageValueGrade.unknown,
            costPerHour: null,
            reason: '이 구독과 연결되는 앱 사용 기록을 찾지 못했어요.',
          ),
        );
        continue;
      }

      final hours = matched.usageMinutes / 60.0;
      final costPerHour = hours <= 0 ? null : subscription.monthlyAmount / hours;
      final grade = _gradeFor(
        usageMinutes: matched.usageMinutes,
        monthlyAmount: subscription.monthlyAmount,
        costPerHour: costPerHour,
      );

      insights.add(
        AppUsageInsight(
          subscription: subscription,
          appName: matched.appName.isEmpty ? subscription.name : matched.appName,
          packageName: matched.packageName,
          usageMinutes: matched.usageMinutes,
          grade: grade,
          costPerHour: costPerHour,
          reason: _reasonFor(grade, matched.usageMinutes, costPerHour),
        ),
      );
    }

    insights.sort((a, b) {
      final gradeOrder = _gradeOrder(a.grade).compareTo(_gradeOrder(b.grade));
      if (gradeOrder != 0) return gradeOrder;
      return b.monthlyAmount.compareTo(a.monthlyAmount);
    });

    return insights;
  }

  static _UsageRow? _findBestMatch(
    Subscription subscription,
    List<_UsageRow> usageRows,
  ) {
    final normalizedName = _normalize(subscription.name);
    final knownPackageIds = _knownPackages.entries
        .where((entry) => normalizedName.contains(_normalize(entry.key)) || _normalize(entry.key).contains(normalizedName))
        .expand((entry) => entry.value)
        .toSet();

    _UsageRow? best;
    int bestScore = -1;

    for (final row in usageRows) {
      var score = 0;
      final normalizedApp = _normalize(row.appName);
      final normalizedPackage = _normalize(row.packageName);

      if (knownPackageIds.contains(row.packageName)) score += 100;
      if (knownPackageIds.any((p) => row.packageName.contains(p))) score += 80;
      if (normalizedApp == normalizedName) score += 70;
      if (normalizedApp.contains(normalizedName) || normalizedName.contains(normalizedApp)) score += 45;
      if (normalizedPackage.contains(normalizedName)) score += 25;

      if (score > bestScore) {
        bestScore = score;
        best = row;
      }
    }

    return bestScore >= 25 ? best : null;
  }

  static UsageValueGrade _gradeFor({
    required int usageMinutes,
    required int monthlyAmount,
    required double? costPerHour,
  }) {
    if (usageMinutes <= 0) return UsageValueGrade.unknown;
    if (usageMinutes < 30) return UsageValueGrade.low;
    if (usageMinutes < 120 && monthlyAmount >= 10000) return UsageValueGrade.low;
    if (costPerHour != null && costPerHour >= 10000) return UsageValueGrade.low;
    if (usageMinutes < 300) return UsageValueGrade.medium;
    if (costPerHour != null && costPerHour >= 5000) return UsageValueGrade.medium;
    return UsageValueGrade.high;
  }

  static String _reasonFor(
    UsageValueGrade grade,
    int usageMinutes,
    double? costPerHour,
  ) {
    final hours = usageMinutes / 60.0;
    final hourText = hours >= 1
        ? '${hours.toStringAsFixed(hours >= 10 ? 0 : 1)}시간'
        : '$usageMinutes분';

    switch (grade) {
      case UsageValueGrade.low:
        return '최근 사용 시간이 $hourText 수준이라 절약 후보로 볼 수 있어요.';
      case UsageValueGrade.medium:
        return '최근 사용 시간이 $hourText라 유지 여부를 한 번 확인해보면 좋아요.';
      case UsageValueGrade.high:
        return '최근 $hourText 사용해서 구독료 대비 활용도가 좋은 편이에요.';
      case UsageValueGrade.unknown:
        return '앱 사용 기록을 찾지 못했어요.';
    }
  }

  static int _gradeOrder(UsageValueGrade grade) {
    switch (grade) {
      case UsageValueGrade.low:
        return 0;
      case UsageValueGrade.medium:
        return 1;
      case UsageValueGrade.unknown:
        return 2;
      case UsageValueGrade.high:
        return 3;
    }
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('프리미엄', '')
      .replaceAll('+', '')
      .replaceAll('premium', '');
}

class _UsageRow {
  final String appName;
  final String packageName;
  final int usageMinutes;

  const _UsageRow({
    required this.appName,
    required this.packageName,
    required this.usageMinutes,
  });

  factory _UsageRow.fromMap(Map<dynamic, dynamic> map) {
    return _UsageRow(
      appName: _readString(map, ['appName', 'label', 'name']),
      packageName: _readString(map, ['packageName', 'package', 'id']),
      usageMinutes: _readMinutes(map),
    );
  }

  static String _readString(Map<dynamic, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  static int _readMinutes(Map<dynamic, dynamic> map) {
    final candidates = [
      map['usageMinutes'],
      map['totalMinutes'],
      map['minutes'],
      map['usageTimeMinutes'],
    ];
    for (final value in candidates) {
      final parsed = _asInt(value);
      if (parsed != null) return parsed;
    }

    final millis = _asInt(map['usageMillis']) ??
        _asInt(map['totalTimeInForeground']) ??
        _asInt(map['usageTimeMillis']);
    if (millis != null) return (millis / 60000).round();

    return 0;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
