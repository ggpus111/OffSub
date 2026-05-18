import 'package:flutter/material.dart';

enum ValueGrade {
  high('높음', Color(0xFF34C759)),
  medium('보통', Color(0xFFFF9500)),
  low('낮음', Color(0xFFFF4D4D));

  final String label;
  final Color color;

  const ValueGrade(this.label, this.color);
}

class SubscriptionService {
  final String id;
  final String name;
  final String category;
  final int monthlyCost;
  final int monthlyUsageMinutes;
  final ValueGrade grade;
  final Color brandColor;
  final String? cancelUrl;

  const SubscriptionService({
    required this.id,
    required this.name,
    required this.category,
    required this.monthlyCost,
    required this.monthlyUsageMinutes,
    required this.grade,
    required this.brandColor,
    this.cancelUrl,
  });

  Color get brandColorLight => brandColor.withOpacity(0.12);
}

const mockSubscriptions = <SubscriptionService>[
  SubscriptionService(
    id: 'netflix',
    name: 'Netflix',
    category: 'OTT',
    monthlyCost: 17000,
    monthlyUsageMinutes: 1260,
    grade: ValueGrade.high,
    brandColor: Color(0xFFE50914),
    cancelUrl: 'https://www.netflix.com/cancelplan',
  ),
  SubscriptionService(
    id: 'spotify',
    name: 'Spotify',
    category: '음악',
    monthlyCost: 10900,
    monthlyUsageMinutes: 480,
    grade: ValueGrade.medium,
    brandColor: Color(0xFF1DB954),
    cancelUrl: 'https://www.spotify.com/account/subscription/',
  ),
  SubscriptionService(
    id: 'youtube',
    name: 'YouTube Premium',
    category: 'OTT',
    monthlyCost: 14900,
    monthlyUsageMinutes: 1800,
    grade: ValueGrade.high,
    brandColor: Color(0xFFFF0000),
    cancelUrl: 'https://www.youtube.com/paid_memberships',
  ),
];
