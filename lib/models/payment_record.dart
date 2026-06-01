// lib/models/payment_record.dart
import 'subscription.dart';

class PaymentRecord {
  final String id;
  final String subscriptionId;
  final String subscriptionName;
  final int amount;
  final DateTime paidAt;
  final SubscriptionSource source;
  final String? rawMessage;
  final String? sender;
  final String? cardName;
  final DateTime createdAt;

  const PaymentRecord({
    required this.id,
    required this.subscriptionId,
    required this.subscriptionName,
    required this.amount,
    required this.paidAt,
    required this.source,
    this.rawMessage,
    this.sender,
    this.cardName,
    required this.createdAt,
  });

  String get monthKey => '${paidAt.year}-${paidAt.month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'subscriptionId': subscriptionId,
        'subscriptionName': subscriptionName,
        'amount': amount,
        'paidAt': paidAt.toIso8601String(),
        'source': source.value,
        'rawMessage': rawMessage,
        'sender': sender,
        'cardName': cardName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: (json['id'] as String?) ?? '',
        subscriptionId: (json['subscriptionId'] as String?) ?? '',
        subscriptionName: (json['subscriptionName'] as String?) ?? '알 수 없는 서비스',
        amount: _asInt(json['amount']),
        paidAt: _parseDate(json['paidAt']) ?? DateTime.now(),
        source: SubscriptionSourceX.fromValue(json['source'] as String?),
        rawMessage: json['rawMessage'] as String?,
        sender: json['sender'] as String?,
        cardName: json['cardName'] as String?,
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      );

  PaymentRecord copyWith({
    String? id,
    String? subscriptionId,
    String? subscriptionName,
    int? amount,
    DateTime? paidAt,
    SubscriptionSource? source,
    String? rawMessage,
    String? sender,
    String? cardName,
    DateTime? createdAt,
  }) =>
      PaymentRecord(
        id: id ?? this.id,
        subscriptionId: subscriptionId ?? this.subscriptionId,
        subscriptionName: subscriptionName ?? this.subscriptionName,
        amount: amount ?? this.amount,
        paidAt: paidAt ?? this.paidAt,
        source: source ?? this.source,
        rawMessage: rawMessage ?? this.rawMessage,
        sender: sender ?? this.sender,
        cardName: cardName ?? this.cardName,
        createdAt: createdAt ?? this.createdAt,
      );

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
