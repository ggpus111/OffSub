import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(title: const Text('결제 캘린더')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final events = provider.subscriptionsByBillingDay;
          final selectedEntries =
              events[_selectedDay.day] ?? const <Subscription>[];

          return Column(
            children: [
              _CalendarCard(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                events: events,
                onPrev: _prevMonth,
                onNext: _nextMonth,
                onDayTap: (date) => setState(() => _selectedDay = date),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _DayDetail(
                  day: _selectedDay,
                  entries: selectedEntries,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Map<int, List<Subscription>> events;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarCard({
    required this.focusedMonth,
    required this.selectedDay,
    required this.events,
    required this.onPrev,
    required this.onNext,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final formatter = NumberFormat('#,###');

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
              Text(
                DateFormat('yyyy년 M월').format(focusedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191F28),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: onNext,
              ),
            ],
          ),
          const SizedBox(height: 8),
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
              childAspectRatio: 0.78,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date = DateTime(focusedMonth.year, focusedMonth.month, day);
              final isSelected = selectedDay.year == date.year &&
                  selectedDay.month == date.month &&
                  selectedDay.day == date.day;
              final entries = events[day] ?? const <Subscription>[];
              final total =
                  entries.fold<int>(0, (sum, item) => sum + item.monthlyAmount);

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onDayTap(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEBF3FE)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF3182F6)
                              : const Color(0xFF4E5968),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (total > 0)
                        Text(
                          '${formatter.format(total ~/ 1000)}K',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3182F6),
                          ),
                        )
                      else
                        const SizedBox(height: 11),
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
}

class _DayDetail extends StatelessWidget {
  final DateTime day;
  final List<Subscription> entries;

  const _DayDetail({required this.day, required this.entries});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final total = entries.fold<int>(0, (sum, item) => sum + item.monthlyAmount);

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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF191F28),
                ),
              ),
              const SizedBox(width: 8),
              if (entries.isNotEmpty)
                Chip(
                  label: Text('총 ${formatter.format(total)}원'),
                  labelStyle: const TextStyle(
                    color: Color(0xFF3182F6),
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: const Color(0xFFEBF3FE),
                  side: BorderSide.none,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  '이 날에는 예정된 결제가 없어요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B95A1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final entry = entries[index];
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
                            color: entry.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              entry.icon.toUpperCase(),
                              style: TextStyle(
                                color: entry.color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            entry.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF191F28),
                            ),
                          ),
                        ),
                        Text(
                          '${formatter.format(entry.monthlyAmount)}원',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF191F28),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
