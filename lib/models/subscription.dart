// lib/models/subscription.dart
import 'package:flutter/material.dart';

class Subscription {
  final String id;
  final String name;
  final int amount;
  final String category;
  final int colorValue;
  final String icon;
  final int billingDay;
  final String billingCycle; // 'monthly' | 'yearly'

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.colorValue,
    required this.icon,
    required this.billingDay,
    required this.billingCycle,
  });

  Color get color => Color(colorValue);

  int get monthlyAmount =>
      billingCycle == 'yearly' ? (amount / 12).round() : amount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category,
    'colorValue': colorValue,
    'icon': icon,
    'billingDay': billingDay,
    'billingCycle': billingCycle,
  };

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'] as String,
    name: json['name'] as String,
    amount: json['amount'] as int,
    category: json['category'] as String,
    colorValue: json['colorValue'] as int,
    icon: json['icon'] as String,
    billingDay: json['billingDay'] as int,
    billingCycle: json['billingCycle'] as String,
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
      );
}
