// lib/models/subscription.dart
import 'package:flutter/material.dart';

enum SubscriptionSource {
  manual,
  sms,
  appUsage,
}

extension SubscriptionSourceX on SubscriptionSource {
  String get value {
    switch (this) {
      case SubscriptionSource.manual:
        return 'manual';
      case SubscriptionSource.sms:
        return 'sms';
      case SubscriptionSource.appUsage:
        return 'app_usage';
    }
  }

  String get label {
    switch (this) {
      case SubscriptionSource.manual:
        return '수동 등록';
      case SubscriptionSource.sms:
        return '문자 감지';
      case SubscriptionSource.appUsage:
        return '사용량 분석';
    }
  }

  static SubscriptionSource fromValue(String? value) {
    switch (value) {
      case 'sms':
        return SubscriptionSource.sms;
      case 'app_usage':
        return SubscriptionSource.appUsage;
      case 'manual':
      default:
        return SubscriptionSource.manual;
    }
  }
}

class Subscription {
  final String id;
  final String name;
  final int amount;
  final String category;
  final int colorValue;
  final String icon;
  final int billingDay;
  final String billingCycle; // 'monthly' | 'yearly'

  // 자동 감지/분석용 메타데이터
  final SubscriptionSource source;
  final String? rawMessage;
  final String? sender;
  final String? cardName;
  final DateTime? detectedAt;
  final double confidence;
  final bool confirmed;

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.colorValue,
    required this.icon,
    required this.billingDay,
    required this.billingCycle,
    this.source = SubscriptionSource.manual,
    this.rawMessage,
    this.sender,
    this.cardName,
    this.detectedAt,
    this.confidence = 1.0,
    this.confirmed = true,
  });

  Color get color => Color(colorValue);

  int get monthlyAmount =>
      billingCycle == 'yearly' ? (amount / 12).round() : amount;

  bool get isAutoDetected => source != SubscriptionSource.manual;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'category': category,
        'colorValue': colorValue,
        'icon': icon,
        'billingDay': billingDay,
        'billingCycle': billingCycle,
        'source': source.value,
        'rawMessage': rawMessage,
        'sender': sender,
        'cardName': cardName,
        'detectedAt': detectedAt?.toIso8601String(),
        'confidence': confidence,
        'confirmed': confirmed,
      };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: _asInt(json['amount']),
        category: json['category'] as String,
        colorValue: _asInt(json['colorValue']),
        icon: json['icon'] as String,
        billingDay: _asInt(json['billingDay']),
        billingCycle: (json['billingCycle'] as String?) ?? 'monthly',
        source: SubscriptionSourceX.fromValue(json['source'] as String?),
        rawMessage: json['rawMessage'] as String?,
        sender: json['sender'] as String?,
        cardName: json['cardName'] as String?,
        detectedAt: _parseDate(json['detectedAt']),
        confidence: _asDouble(json['confidence'], fallback: 1.0),
        confirmed: json['confirmed'] as bool? ?? true,
      );

  Subscription copyWith({
    String? id,
    String? name,
    int? amount,
    String? category,
    int? colorValue,
    String? icon,
    int? billingDay,
    String? billingCycle,
    SubscriptionSource? source,
    String? rawMessage,
    String? sender,
    String? cardName,
    DateTime? detectedAt,
    double? confidence,
    bool? confirmed,
    bool clearRawMessage = false,
    bool clearSender = false,
    bool clearCardName = false,
    bool clearDetectedAt = false,
  }) =>
      Subscription(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        colorValue: colorValue ?? this.colorValue,
        icon: icon ?? this.icon,
        billingDay: billingDay ?? this.billingDay,
        billingCycle: billingCycle ?? this.billingCycle,
        source: source ?? this.source,
        rawMessage: clearRawMessage ? null : rawMessage ?? this.rawMessage,
        sender: clearSender ? null : sender ?? this.sender,
        cardName: clearCardName ? null : cardName ?? this.cardName,
        detectedAt: clearDetectedAt ? null : detectedAt ?? this.detectedAt,
        confidence: confidence ?? this.confidence,
        confirmed: confirmed ?? this.confirmed,
      );

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
