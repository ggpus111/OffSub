import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription.dart';

class SubscriptionProvider extends ChangeNotifier {
  static const _storageKey = 'subscriptions_v1';

  List<Subscription> _subscriptions = [];

  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  int get totalMonthlyAmount =>
      _subscriptions.fold(0, (sum, s) => sum + s.monthlyAmount);

  Map<String, int> get amountByCategory {
    final map = <String, int>{};
    for (final s in _subscriptions) {
      map[s.category] = (map[s.category] ?? 0) + s.monthlyAmount;
    }
    return map;
  }

  List<Subscription> get upcomingBills {
    final now = DateTime.now();
    final sorted = [..._subscriptions];
    sorted.sort((a, b) =>
        _daysUntil(a.billingDay, now).compareTo(_daysUntil(b.billingDay, now)));
    return sorted;
  }

  Map<int, List<Subscription>> get subscriptionsByBillingDay {
    final map = <int, List<Subscription>>{};
    for (final subscription in _subscriptions) {
      map.putIfAbsent(subscription.billingDay, () => []).add(subscription);
    }
    return map;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    _subscriptions = decoded
        .whereType<Map<String, dynamic>>()
        .map(Subscription.fromJson)
        .toList();
    notifyListeners();
  }

  Future<void> add(Subscription subscription) async {
    _subscriptions.add(subscription);
    await _persistAndNotify();
  }

  Future<void> update(Subscription subscription) async {
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index == -1) return;
    _subscriptions[index] = subscription;
    await _persistAndNotify();
  }

  Future<void> remove(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    await _persistAndNotify();
  }

  Future<void> clearAll() async {
    _subscriptions.clear();
    await _persistAndNotify();
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert(
        _subscriptions.map((s) => s.toJson()).toList(),
      );

  Future<void> _persistAndNotify() async {
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_subscriptions.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  int _daysUntil(int billingDay, DateTime from) {
    final currentMonthLastDay = DateTime(from.year, from.month + 1, 0).day;
    final normalizedDay = billingDay.clamp(1, currentMonthLastDay).toInt();
    var next = DateTime(from.year, from.month, normalizedDay);
    if (next.isBefore(DateTime(from.year, from.month, from.day))) {
      final nextMonthLastDay = DateTime(from.year, from.month + 2, 0).day;
      next = DateTime(
        from.year,
        from.month + 1,
        billingDay.clamp(1, nextMonthLastDay).toInt(),
      );
    }
    return next.difference(DateTime(from.year, from.month, from.day)).inDays;
  }
}
