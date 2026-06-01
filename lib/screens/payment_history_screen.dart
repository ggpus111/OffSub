// lib/screens/payment_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/payment_record.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void _prevMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(title: const Text('결제 이력')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final records = provider.recordsForMonth(_focusedMonth.year, _focusedMonth.month);
          final total = records.fold<int>(0, (sum, record) => sum + record.amount);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: _SummaryCard(
                  focusedMonth: _focusedMonth,
                  total: total,
                  count: records.length,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? const _EmptyHistory()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                        itemCount: records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _PaymentRecordCard(record: records[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DateTime focusedMonth;
  final int total;
  final int count;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _SummaryCard({
    required this.focusedMonth,
    required this.total,
    required this.count,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left_rounded)),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('yyyy년 M월').format(focusedMonth),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191F28),
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '실제 감지된 결제 금액',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${formatter.format(total)}원',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF191F28),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count건의 결제 이력',
            style: const TextStyle(fontSize: 13, color: Color(0xFF8B95A1)),
          ),
        ],
      ),
    );
  }
}

class _PaymentRecordCard extends StatelessWidget {
  final PaymentRecord record;

  const _PaymentRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF3182F6)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.subscriptionName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191F28),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('M월 d일').format(record.paidAt)} · ${record.source.label}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B95A1),
                  ),
                ),
                if (record.rawMessage != null && record.rawMessage!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    record.rawMessage!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1), height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${formatter.format(record.amount)}원',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF191F28),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Color(0xFF8B95A1)),
            SizedBox(height: 16),
            Text(
              '이 달에는 저장된 결제 이력이 없어요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '자동 감지 화면에서 문자 결제 후보를 추가하면 여기에 실제 결제 기록이 쌓여요.',
              style: TextStyle(fontSize: 14, color: Color(0xFF8B95A1), height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
