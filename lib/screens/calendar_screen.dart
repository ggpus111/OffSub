// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Design Tokens ──────────────────────────────────────────────
const _kPrimary = Color(0xFF3182F6);
const _kBg = Color(0xFFF2F4F6);
const _kSurface = Colors.white;
const _kTextPrimary = Color(0xFF191F28);
const _kTextSecondary = Color(0xFF8B95A1);
const _kRadius = 16.0;
const _kPadH = 24.0;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // 샘플 데이터: {day: [(name, amount, color)]}
  final Map<int, List<_SubEntry>> _events = {
    3: [_SubEntry('Netflix', 17000, const Color(0xFFE50914))],
    8: [_SubEntry('Spotify', 10900, const Color(0xFF1DB954))],
    15: [
      _SubEntry('YouTube', 14900, const Color(0xFFFF0000)),
      _SubEntry('iCloud', 1200, const Color(0xFF555555)),
    ],
    22: [_SubEntry('Notion', 8000, const Color(0xFF000000))],
    28: [_SubEntry('Adobe CC', 26400, const Color(0xFFFF0000))],
  };

  List<_SubEntry> get _selectedEntries =>
      _events[_selectedDay.day] ?? [];

  void _prevMonth() => setState(() {
    _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
  });

  void _nextMonth() => setState(() {
    _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '결제 캘린더',
          style: TextStyle(
            color: _kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _CalendarCard(
            focusedMonth: _focusedMonth,
            selectedDay: _selectedDay,
            events: _events,
            onPrev: _prevMonth,
            onNext: _nextMonth,
            onDayTap: (d) => setState(() => _selectedDay = d),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _DayDetail(
              day: _selectedDay,
              entries: _selectedEntries,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Calendar Card ───────────────────────────────────────────────
class _CalendarCard extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Map<int, List<_SubEntry>> events;
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
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sun=0

    final fmt = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.fromLTRB(_kPadH, 0, _kPadH, 0),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(_kRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: _kTextSecondary),
                  onPressed: onPrev,
                  visualDensity: VisualDensity.compact,
                ),
                Text(
                  DateFormat('yyyy년 M월').format(focusedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: _kTextSecondary),
                  onPressed: onNext,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Weekday headers
            Row(
              children: ['일', '월', '화', '수', '목', '금', '토']
                  .asMap()
                  .entries
                  .map((e) => Expanded(
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: e.key == 0
                          ? const Color(0xFFFF4D4D)
                          : e.key == 6
                          ? _kPrimary
                          : _kTextSecondary,
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Day grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.72,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (_, i) {
                if (i < startWeekday) return const SizedBox.shrink();
                final day = i - startWeekday + 1;
                final date =
                DateTime(focusedMonth.year, focusedMonth.month, day);
                final isSelected = selectedDay.year == date.year &&
                    selectedDay.month == date.month &&
                    selectedDay.day == date.day;
                final isToday = DateTime.now().year == date.year &&
                    DateTime.now().month == date.month &&
                    DateTime.now().day == date.day;
                final entries = events[day];
                final totalAmt =
                    entries?.fold(0, (s, e) => s + e.amount) ?? 0;
                final isWeekend = date.weekday == 7 || date.weekday == 6;

                return GestureDetector(
                  onTap: () => onDayTap(date),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected ? _kPrimary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday && !isSelected
                              ? Border.all(color: _kPrimary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : isWeekend
                                  ? (date.weekday == 7
                                  ? const Color(0xFFFF4D4D)
                                  : _kPrimary)
                                  : _kTextPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (totalAmt > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${fmt.format(totalAmt ~/ 1000)}K',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? _kPrimary : _kTextSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Day Detail ──────────────────────────────────────────────────
class _DayDetail extends StatelessWidget {
  final DateTime day;
  final List<_SubEntry> entries;

  const _DayDetail({required this.day, required this.entries});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kPadH, 8, _kPadH, 0),
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
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (entries.isNotEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '총 ${fmt.format(entries.fold(0, (s, e) => s + e.amount))}원',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 40, color: _kTextSecondary.withOpacity(0.4)),
                    const SizedBox(height: 8),
                    const Text(
                      '결제 예정 없음',
                      style: TextStyle(
                          fontSize: 14,
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            ...entries.map((e) => _EntryTile(entry: e, fmt: fmt)),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final _SubEntry entry;
  final NumberFormat fmt;

  const _EntryTile({required this.entry, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(_kRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
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
                entry.name[0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: entry.color,
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
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
            ),
          ),
          Text(
            '${fmt.format(entry.amount)}원',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubEntry {
  final String name;
  final int amount;
  final Color color;
  const _SubEntry(this.name, this.amount, this.color);
}
