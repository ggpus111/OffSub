import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/payment_record.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();

  void _prevMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
        _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
        _selectedDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(title: const Text('결제 캘린더')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final scheduledEvents = _scheduledByDayForMonth(
            provider.subscriptions,
            _focusedMonth,
          );
          final paidEvents = _paymentRecordsByDay(
            provider.recordsForMonth(_focusedMonth.year, _focusedMonth.month),
          );
          final selectedScheduled =
              scheduledEvents[_selectedDay.day] ?? const <Subscription>[];
          final selectedPaid = paidEvents[_selectedDay.day] ?? const <PaymentRecord>[];

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _CalendarCard(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                scheduledEvents: scheduledEvents,
                paidEvents: paidEvents,
                onPrev: _prevMonth,
                onNext: _nextMonth,
                onDayTap: (date) => setState(() => _selectedDay = date),
              ),
              const SizedBox(height: 10),
              _MonthSummary(
                month: _focusedMonth,
                scheduledTotal: _sumScheduled(scheduledEvents),
                paidTotal: _sumPaid(paidEvents),
              ),
              _DayDetail(
                day: _selectedDay,
                scheduledEntries: selectedScheduled,
                paidEntries: selectedPaid,
              ),
            ],
          );
        },
      ),
    );
  }

  Map<int, List<Subscription>> _scheduledByDayForMonth(
    List<Subscription> subscriptions,
    DateTime month,
  ) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final map = <int, List<Subscription>>{};
    for (final subscription in subscriptions) {
      final day = subscription.billingDay.clamp(1, lastDay).toInt();
      map.putIfAbsent(day, () => []).add(subscription);
    }
    return map;
  }

  Map<int, List<PaymentRecord>> _paymentRecordsByDay(List<PaymentRecord> records) {
    final map = <int, List<PaymentRecord>>{};
    for (final record in records) {
      map.putIfAbsent(record.paidAt.day, () => []).add(record);
    }
    return map;
  }

  int _sumScheduled(Map<int, List<Subscription>> events) {
    var total = 0;
    for (final entries in events.values) {
      for (final item in entries) {
        total += item.monthlyAmount;
      }
    }
    return total;
  }

  int _sumPaid(Map<int, List<PaymentRecord>> events) {
    var total = 0;
    for (final entries in events.values) {
      for (final item in entries) {
        total += item.amount;
      }
    }
    return total;
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Map<int, List<Subscription>> scheduledEvents;
  final Map<int, List<PaymentRecord>> paidEvents;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarCard({
    required this.focusedMonth,
    required this.selectedDay,
    required this.scheduledEvents,
    required this.paidEvents,
    required this.onPrev,
    required this.onNext,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: onPrev,
              ),
              Column(
                children: [
                  Text(
                    DateFormat('yyyy년 M월').format(focusedMonth),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191F28),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '예정 결제와 실제 결제를 함께 확인해요',
                    style: TextStyle(fontSize: 11, color: Color(0xFF8B95A1)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: onNext,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _LegendRow(),
          const SizedBox(height: 12),
          Row(
            children: const ['일', '월', '화', '수', '목', '금', '토']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B95A1),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.62,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date = DateTime(focusedMonth.year, focusedMonth.month, day);
              final isSelected = selectedDay.year == date.year &&
                  selectedDay.month == date.month &&
                  selectedDay.day == date.day;
              final scheduled = scheduledEvents[day] ?? const <Subscription>[];
              final paid = paidEvents[day] ?? const <PaymentRecord>[];
              final scheduledTotal = scheduled.fold<int>(
                0,
                (sum, item) => sum + item.monthlyAmount,
              );
              final paidTotal = paid.fold<int>(0, (sum, item) => sum + item.amount);

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onDayTap(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEBF3FE) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3182F6) : Colors.transparent,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF3182F6)
                              : const Color(0xFF4E5968),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (paidTotal > 0)
                        _TinyAmountPill(
                          label: _compactWon(paidTotal),
                          color: const Color(0xFF00A86B),
                          background: const Color(0xFFE9F8F1),
                        ),
                      if (scheduledTotal > 0) ...[
                        const SizedBox(height: 3),
                        _TinyAmountPill(
                          label: _compactWon(scheduledTotal),
                          color: const Color(0xFF3182F6),
                          background: const Color(0xFFEBF3FE),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _compactWon(int amount) {
    if (amount >= 10000) return '${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}만';
    if (amount >= 1000) return '${amount ~/ 1000}K';
    return '$amount';
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendDot(color: Color(0xFF00A86B), label: '실제 결제'),
        SizedBox(width: 14),
        _LegendDot(color: Color(0xFF3182F6), label: '예정 결제'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7684)),
        ),
      ],
    );
  }
}

class _TinyAmountPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _TinyAmountPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final DateTime month;
  final int scheduledTotal;
  final int paidTotal;

  const _MonthSummary({
    required this.month,
    required this.scheduledTotal,
    required this.paidTotal,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              title: '예정 구독료',
              amount: '${formatter.format(scheduledTotal)}원',
              color: const Color(0xFF3182F6),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFF2F4F6)),
          Expanded(
            child: _SummaryItem(
              title: '실제 결제',
              amount: '${formatter.format(paidTotal)}원',
              color: const Color(0xFF00A86B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8B95A1),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DayDetail extends StatelessWidget {
  final DateTime day;
  final List<Subscription> scheduledEntries;
  final List<PaymentRecord> paidEntries;

  const _DayDetail({
    required this.day,
    required this.scheduledEntries,
    required this.paidEntries,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final scheduledTotal = scheduledEntries.fold<int>(
      0,
      (sum, item) => sum + item.monthlyAmount,
    );
    final paidTotal = paidEntries.fold<int>(0, (sum, item) => sum + item.amount);
    final hasAny = scheduledEntries.isNotEmpty || paidEntries.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat('M월 d일').format(day),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF191F28),
                ),
              ),
              const SizedBox(width: 8),
              if (hasAny)
                Chip(
                  label: Text(
                    '예정 ${formatter.format(scheduledTotal)}원 · 결제 ${formatter.format(paidTotal)}원',
                  ),
                  labelStyle: const TextStyle(
                    color: Color(0xFF3182F6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: const Color(0xFFEBF3FE),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasAny)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                '이 날에는 예정 결제나 실제 결제 이력이 없어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B95A1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else ...[
            if (paidEntries.isNotEmpty) ...[
              const _SectionTitle(
                icon: Icons.check_circle_rounded,
                title: '실제 결제 완료',
                color: Color(0xFF00A86B),
              ),
              const SizedBox(height: 8),
              ...paidEntries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PaidRecordTile(record: entry),
                  )),
              const SizedBox(height: 8),
            ],
            if (scheduledEntries.isNotEmpty) ...[
              const _SectionTitle(
                icon: Icons.schedule_rounded,
                title: '예정 결제',
                color: Color(0xFF3182F6),
              ),
              const SizedBox(height: 8),
              ...scheduledEntries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ScheduledTile(subscription: entry),
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PaidRecordTile extends StatelessWidget {
  final PaymentRecord record;

  const _PaidRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F8F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF00A86B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.subscriptionName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191F28),
                  ),
                ),
                if (record.sender != null && record.sender!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '문자 발신: ${record.sender}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1)),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${formatter.format(record.amount)}원',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191F28),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledTile extends StatelessWidget {
  final Subscription subscription;

  const _ScheduledTile({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: subscription.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                subscription.icon.toUpperCase(),
                style: TextStyle(
                  color: subscription.color,
                  fontWeight: FontWeight.w800,
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
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF191F28),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subscription.billingCycle == 'yearly' ? '연간 결제 월 환산' : '매월 예정 결제',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1)),
                ),
              ],
            ),
          ),
          Text(
            '${formatter.format(subscription.monthlyAmount)}원',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191F28),
            ),
          ),
        ],
      ),
    );
  }
}
