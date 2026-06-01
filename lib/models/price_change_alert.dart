// lib/models/price_change_alert.dart
import 'payment_record.dart';
import 'subscription.dart';

enum PriceChangeType {
  changedFromPrevious,
  differentFromRegistered,
}

class PriceChangeAlert {
  final Subscription subscription;
  final PaymentRecord latestRecord;
  final PaymentRecord? previousRecord;
  final int oldAmount;
  final int newAmount;
  final PriceChangeType type;

  const PriceChangeAlert({
    required this.subscription,
    required this.latestRecord,
    required this.previousRecord,
    required this.oldAmount,
    required this.newAmount,
    required this.type,
  });

  int get difference => newAmount - oldAmount;
  bool get increased => difference > 0;
  bool get decreased => difference < 0;

  double get changeRate {
    if (oldAmount == 0) return 0;
    return difference / oldAmount * 100;
  }

  String get title {
    if (type == PriceChangeType.changedFromPrevious) {
      return increased ? '가격이 올랐어요' : '가격이 내려갔어요';
    }
    return '등록 금액과 달라요';
  }
}
