import 'package:flutter/material.dart';

class SmsSubscriptionCandidate {
  final String id;
  final String serviceName;
  final int amount;
  final int billingDay;
  final DateTime detectedAt;
  final String sender;
  final String rawMessage;
  final double confidence;
  final String category;
  final String icon;
  final int colorValue;

  const SmsSubscriptionCandidate({
    required this.id,
    required this.serviceName,
    required this.amount,
    required this.billingDay,
    required this.detectedAt,
    required this.sender,
    required this.rawMessage,
    required this.confidence,
    required this.category,
    required this.icon,
    required this.colorValue,
  });

  Color get color => Color(colorValue);
}
