// lib/widgets/subscription_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onDelete;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int daysLeft = subscription.billingDay - now.day;
    if (daysLeft < 0) daysLeft += 31;
    final isToday = daysLeft == 0;
    final isSoon = daysLeft <= 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: subscription.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              subscription.icon,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Text(
          subscription.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF191F28),
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              subscription.category,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8B95A1),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFFFFEEEE)
                    : isSoon
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isToday
                    ? '오늘 결제'
                    : isSoon
                    ? 'D-$daysLeft'
                    : '매월 ${subscription.billingDay}일',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? const Color(0xFFE53935)
                      : isSoon
                      ? const Color(0xFFF57C00)
                      : const Color(0xFF8B95A1),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${NumberFormat('#,###').format(subscription.monthlyAmount)}원',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191F28),
                  ),
                ),
                if (subscription.billingCycle == 'yearly')
                  Text(
                    '연간',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8B95A1),
                    ),
                  ),
              ],
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Color(0xFFD1D6DB),
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
