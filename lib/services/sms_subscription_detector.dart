import 'package:uuid/uuid.dart';

import 'sms_subscription_candidate.dart';

class SmsSubscriptionDetector {
  static final _amountRegex = RegExp(r'([0-9]{1,3}(?:,[0-9]{3})+|[0-9]{4,})\s*원');
  static final _paymentKeywords = ['승인', '결제', '이용', '출금', '자동결제', '정기결제', '구독'];
  static final _excludeKeywords = ['취소', '환불', '거절', '실패', '한도', '입금'];

  static const _serviceMap = <String, _ServiceRule>{
    '넷플릭스': _ServiceRule('넷플릭스', 'OTT', 'N', 0xFFE50914),
    'NETFLIX': _ServiceRule('넷플릭스', 'OTT', 'N', 0xFFE50914),
    '유튜브': _ServiceRule('유튜브 프리미엄', 'OTT', 'Y', 0xFFFF0000),
    'YOUTUBE': _ServiceRule('유튜브 프리미엄', 'OTT', 'Y', 0xFFFF0000),
    'GOOGLE': _ServiceRule('구글 결제', '생산성', 'G', 0xFF4285F4),
    '스포티파이': _ServiceRule('스포티파이', '음악', 'S', 0xFF1DB954),
    'SPOTIFY': _ServiceRule('스포티파이', '음악', 'S', 0xFF1DB954),
    '디즈니': _ServiceRule('디즈니+', 'OTT', 'D', 0xFF113CCF),
    'DISNEY': _ServiceRule('디즈니+', 'OTT', 'D', 0xFF113CCF),
    '쿠팡': _ServiceRule('쿠팡 와우', '쇼핑', 'C', 0xFFEE2C2C),
    'COUPANG': _ServiceRule('쿠팡 와우', '쇼핑', 'C', 0xFFEE2C2C),
    '멜론': _ServiceRule('멜론', '음악', 'M', 0xFF00CD3C),
    'MELON': _ServiceRule('멜론', '음악', 'M', 0xFF00CD3C),
    'NOTION': _ServiceRule('Notion', '생산성', 'N', 0xFF111111),
  };

  static List<SmsSubscriptionCandidate> detect(List<Map<String, dynamic>> messages) {
    final candidates = <SmsSubscriptionCandidate>[];
    final seen = <String>{};

    for (final message in messages) {
      final body = (message['body'] ?? '').toString();
      if (body.trim().isEmpty) continue;

      final upper = body.toUpperCase();
      if (!_paymentKeywords.any(body.contains)) continue;
      if (_excludeKeywords.any(body.contains)) continue;

      final amountMatch = _amountRegex.firstMatch(body);
      if (amountMatch == null) continue;

      final amount = int.tryParse(amountMatch.group(1)!.replaceAll(',', ''));
      if (amount == null || amount <= 0) continue;

      final rule = _findServiceRule(body, upper);
      if (rule == null) continue;

      final timestamp = int.tryParse('${message['date']}') ?? DateTime.now().millisecondsSinceEpoch;
      final detectedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final key = '${rule.name}-$amount-${detectedAt.year}-${detectedAt.month}-${detectedAt.day}';
      if (seen.contains(key)) continue;
      seen.add(key);

      candidates.add(
        SmsSubscriptionCandidate(
          id: const Uuid().v4(),
          serviceName: rule.name,
          amount: amount,
          billingDay: detectedAt.day,
          detectedAt: detectedAt,
          sender: (message['address'] ?? '').toString(),
          rawMessage: body,
          confidence: _calculateConfidence(body, rule),
          category: rule.category,
          icon: rule.icon,
          colorValue: rule.colorValue,
        ),
      );
    }

    candidates.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return candidates;
  }

  static _ServiceRule? _findServiceRule(String body, String upper) {
    for (final entry in _serviceMap.entries) {
      if (body.contains(entry.key) || upper.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  static double _calculateConfidence(String body, _ServiceRule rule) {
    var score = 0.65;
    if (body.contains('정기결제') || body.contains('자동결제') || body.contains('구독')) {
      score += 0.2;
    }
    if (body.contains(rule.name)) score += 0.1;
    if (body.contains('승인') || body.contains('결제')) score += 0.05;
    return score.clamp(0.0, 0.98);
  }
}

class _ServiceRule {
  final String name;
  final String category;
  final String icon;
  final int colorValue;

  const _ServiceRule(this.name, this.category, this.icon, this.colorValue);
}
