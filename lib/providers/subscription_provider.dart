// lib/providers/subscription_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class SubscriptionProvider extends ChangeNotifier {
  static const _storageKey = 'subscriptions_v1';

  List<Subscription> _subscriptions = [];

  List<Subscription> get subscriptions =>
      List.unmodifiable(_subscriptions);

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
    sorted.sort((a, b) {
      int daysA = a.billingDay - now.day;
      if (daysA < 0) daysA += 31;
      int daysB = b.billingDay - now.day;
      if (daysB < 0) daysB += 31;
      return daysA.compareTo(daysB);
    });
    return sorted;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _subscriptions =
          list.map((e) => Subscription.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> add(Subscription subscription) async {
    _subscriptions.add(subscription);
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_subscriptions.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
