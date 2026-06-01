import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_record.dart';
import '../models/price_change_alert.dart';
import '../models/subscription.dart';
import '../services/notification_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  static const _storageKey = 'subscriptions_v2';
  static const _legacyStorageKey = 'subscriptions_v1';
  static const _paymentRecordsKey = 'payment_records_v1';

  List<Subscription> _subscriptions = [];
  List<PaymentRecord> _paymentRecords = [];

  List<Subscription> get subscriptions => List.unmodifiable(_subscriptions);

  List<PaymentRecord> get paymentRecords {
    final sorted = [..._paymentRecords]
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    return List.unmodifiable(sorted);
  }

  int get totalMonthlyAmount =>
      _subscriptions.fold(0, (sum, s) => sum + s.monthlyAmount);

  int get autoDetectedCount =>
      _subscriptions.where((s) => s.isAutoDetected).length;

  int get unconfirmedCount =>
      _subscriptions.where((s) => !s.confirmed).length;

  int get totalPaidThisMonth {
    final now = DateTime.now();
    return recordsForMonth(now.year, now.month)
        .fold(0, (sum, record) => sum + record.amount);
  }



  List<PriceChangeAlert> get priceChangeAlerts {
    final alerts = <PriceChangeAlert>[];

    for (final subscription in _subscriptions) {
      final records = recordsForSubscription(subscription.id)
        ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
      if (records.isEmpty) continue;

      final latest = records.first;
      PaymentRecord? previousDifferent;
      for (final record in records.skip(1)) {
        if (record.amount != latest.amount) {
          previousDifferent = record;
          break;
        }
      }

      // 이미 구독 금액이 최신 결제 금액과 같다면 사용자가 반영한 상태로 봅니다.
      if (latest.amount == subscription.amount) continue;

      if (previousDifferent != null) {
        alerts.add(
          PriceChangeAlert(
            subscription: subscription,
            latestRecord: latest,
            previousRecord: previousDifferent,
            oldAmount: previousDifferent.amount,
            newAmount: latest.amount,
            type: PriceChangeType.changedFromPrevious,
          ),
        );
        continue;
      }

      alerts.add(
        PriceChangeAlert(
          subscription: subscription,
          latestRecord: latest,
          previousRecord: null,
          oldAmount: subscription.amount,
          newAmount: latest.amount,
          type: PriceChangeType.differentFromRegistered,
        ),
      );
    }

    alerts.sort((a, b) => b.latestRecord.paidAt.compareTo(a.latestRecord.paidAt));
    return List.unmodifiable(alerts);
  }

  int get priceChangeAlertCount => priceChangeAlerts.length;

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

  Map<int, List<PaymentRecord>> get paymentRecordsByDayThisMonth {
    final now = DateTime.now();
    final map = <int, List<PaymentRecord>>{};
    for (final record in recordsForMonth(now.year, now.month)) {
      map.putIfAbsent(record.paidAt.day, () => []).add(record);
    }
    return map;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    await _loadSubscriptions(prefs);
    await _loadPaymentRecords(prefs);
    notifyListeners();
  }

  Future<void> _loadSubscriptions(SharedPreferences prefs) async {
    final raw = prefs.getString(_storageKey) ?? prefs.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      _subscriptions = decoded
          .whereType<Map<String, dynamic>>()
          .map(Subscription.fromJson)
          .toList();

      await _persistSubscriptions(); // v1 데이터를 v2 저장 키로 마이그레이션
    } catch (_) {
      _subscriptions = [];
    }
  }

  Future<void> _loadPaymentRecords(SharedPreferences prefs) async {
    final raw = prefs.getString(_paymentRecordsKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      _paymentRecords = decoded
          .whereType<Map<String, dynamic>>()
          .map(PaymentRecord.fromJson)
          .where((record) => record.id.isNotEmpty)
          .toList();
    } catch (_) {
      _paymentRecords = [];
    }
  }

  Future<void> add(Subscription subscription) async {
    _subscriptions.add(subscription);
    await _persistAndNotify();
  }

  Future<bool> addIfNotExists(Subscription subscription) async {
    if (containsSimilar(subscription)) return false;
    _subscriptions.add(subscription);
    await _persistAndNotify();
    return true;
  }

  bool containsSimilar(Subscription subscription) {
    return findSimilarSubscription(subscription) != null;
  }

  Subscription? findSimilarSubscription(Subscription subscription) {
    for (final s in _subscriptions) {
      final sameName = _normalize(s.name) == _normalize(subscription.name);
      final sameAmount = s.amount == subscription.amount;
      final sameDay = s.billingDay == subscription.billingDay;
      if (sameName && sameAmount && sameDay) return s;
    }
    return null;
  }



  Subscription? findSubscriptionByName(String name) {
    final normalizedName = _normalize(name);
    for (final subscription in _subscriptions) {
      if (_normalize(subscription.name) == normalizedName) return subscription;
    }
    for (final subscription in _subscriptions) {
      final current = _normalize(subscription.name);
      if (current.contains(normalizedName) || normalizedName.contains(current)) {
        return subscription;
      }
    }
    return null;
  }

  Future<void> applyLatestAmount(String subscriptionId, int newAmount) async {
    final index = _subscriptions.indexWhere((s) => s.id == subscriptionId);
    if (index == -1) return;
    _subscriptions[index] = _subscriptions[index].copyWith(
      amount: newAmount,
      confirmed: true,
    );
    await _persistAndNotify();
  }

  Future<void> update(Subscription subscription) async {
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index == -1) return;
    _subscriptions[index] = subscription;
    await _persistAndNotify();
  }

  Future<void> confirm(String id) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _subscriptions[index] = _subscriptions[index].copyWith(confirmed: true);
    await _persistAndNotify();
  }

  Future<void> addPaymentRecord(PaymentRecord record) async {
    _paymentRecords.add(record);
    await _persistAndNotify();
  }

  Future<bool> addPaymentRecordIfNotExists(PaymentRecord record) async {
    if (containsSimilarPaymentRecord(record)) return false;
    _paymentRecords.add(record);
    await _persistAndNotify();
    return true;
  }

  bool containsSimilarPaymentRecord(PaymentRecord record) {
    return _paymentRecords.any(
      (r) =>
          r.subscriptionId == record.subscriptionId &&
          r.amount == record.amount &&
          r.paidAt.year == record.paidAt.year &&
          r.paidAt.month == record.paidAt.month &&
          r.paidAt.day == record.paidAt.day,
    );
  }

  List<PaymentRecord> recordsForSubscription(String subscriptionId) {
    final records = _paymentRecords
        .where((record) => record.subscriptionId == subscriptionId)
        .toList()
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    return records;
  }

  PaymentRecord? latestPaymentForSubscription(String subscriptionId) {
    final records = recordsForSubscription(subscriptionId);
    if (records.isEmpty) return null;
    return records.first;
  }

  bool hasPaymentThisMonth(String subscriptionId) {
    final now = DateTime.now();
    return _paymentRecords.any(
      (record) =>
          record.subscriptionId == subscriptionId &&
          record.paidAt.year == now.year &&
          record.paidAt.month == now.month,
    );
  }

  List<PaymentRecord> recordsForMonth(int year, int month) {
    final records = _paymentRecords
        .where((record) => record.paidAt.year == year && record.paidAt.month == month)
        .toList()
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    return records;
  }

  Future<void> removePaymentRecord(String id) async {
    _paymentRecords.removeWhere((record) => record.id == id);
    await _persistAndNotify();
  }

  Future<void> remove(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    _paymentRecords.removeWhere((record) => record.subscriptionId == id);
    await _persistAndNotify();
  }

  Future<void> clearAll() async {
    _subscriptions.clear();
    _paymentRecords.clear();
    await _persistAndNotify();
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert({
        'subscriptions': _subscriptions.map((s) => s.toJson()).toList(),
        'paymentRecords': _paymentRecords.map((r) => r.toJson()).toList(),
      });

  Future<void> _persistAndNotify() async {
    await _persistSubscriptions();
    await _persistPaymentRecords();
    await NotificationService.rescheduleIfEnabled(_subscriptions);
    notifyListeners();
  }

  Future<void> _persistSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_subscriptions.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> _persistPaymentRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_paymentRecords.map((r) => r.toJson()).toList());
    await prefs.setString(_paymentRecordsKey, raw);
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

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('프리미엄', '')
      .replaceAll('+', '');
}
