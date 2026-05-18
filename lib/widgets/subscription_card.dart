import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysUntil(subscription.billingDay);
    final isToday = daysLeft == 0;
    final isSoon = daysLeft <= 3;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: subscription.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    subscription.icon.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: subscription.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF191F28),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MetaChip(label: subscription.category),
                        _MetaChip(
                          label: isToday
                              ? '오늘 결제'
                              : isSoon
                                  ? 'D-$daysLeft'
                                  : '매월 ${subscription.billingDay}일',
                          color: isToday
                              ? const Color(0xFFE53935)
                              : isSoon
                                  ? const Color(0xFFF57C00)
                                  : const Color(0xFF8B95A1),
                          background: isToday
                              ? const Color(0xFFFFEEEE)
                              : isSoon
                                  ? const Color(0xFFFFF3E0)
                                  : const Color(0xFFF2F4F6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(subscription.monthlyAmount)}원',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191F28),
                    ),
                  ),
                  if (subscription.billingCycle == 'yearly')
                    const Text(
                      '월 환산',
                      style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1)),
                    ),
                ],
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '삭제',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Color(0xFFD1D6DB),
                    size: 21,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _daysUntil(int billingDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonthLastDay = DateTime(now.year, now.month + 1, 0).day;
    var next = DateTime(
      now.year,
      now.month,
      billingDay.clamp(1, thisMonthLastDay).toInt(),
    );
    if (next.isBefore(today)) {
      final nextMonthLastDay = DateTime(now.year, now.month + 2, 0).day;
      next = DateTime(
        now.year,
        now.month + 1,
        billingDay.clamp(1, nextMonthLastDay).toInt(),
      );
    }
    return next.difference(today).inDays;
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _MetaChip({
    required this.label,
    this.color = const Color(0xFF8B95A1),
    this.background = const Color(0xFFF2F4F6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
