import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import '../widgets/empty_state_widget.dart';

const _categoryColors = <String, Color>{
  'OTT': Color(0xFFE50914),
  '음악': Color(0xFF1DB954),
  '게임': Color(0xFF6441A4),
  '쇼핑': Color(0xFFFF6B35),
  '생산성': Color(0xFF3182F6),
  '교육': Color(0xFFF59E0B),
  '기타': Color(0xFF8B95A1),
};

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(title: const Text('지출 통계')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final categoryMap = provider.amountByCategory;
          final total = provider.totalMonthlyAmount;

          if (provider.subscriptions.isEmpty) {
            return const EmptyStateWidget(
              emoji: '％',
              title: '분석할 데이터가 없어요',
              description: '서비스를 추가하면 카테고리별 지출과 월간 구독료를 분석할 수 있어요.',
            );
          }

          final sections = categoryMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _TotalCard(total: total, count: provider.subscriptions.length),
              const SizedBox(height: 16),
              _ChartCard(
                total: total,
                sections: sections,
                touchedIndex: _touchedIndex,
                onTouched: (index) => setState(() => _touchedIndex = index),
              ),
              const SizedBox(height: 16),
              _CategoryList(total: total, sections: sections),
            ],
          );
        },
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int total;
  final int count;

  const _TotalCard({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '월 구독 총액',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8B95A1),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${NumberFormat('#,###').format(total)}원',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191F28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count개 서비스 기준',
            style: const TextStyle(fontSize: 13, color: Color(0xFF8B95A1)),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final int total;
  final List<MapEntry<String, int>> sections;
  final int touchedIndex;
  final ValueChanged<int> onTouched;

  const _ChartCard({
    required this.total,
    required this.sections,
    required this.touchedIndex,
    required this.onTouched,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '카테고리별 비중',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191F28),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response?.touchedSection == null) {
                      onTouched(-1);
                      return;
                    }
                    onTouched(response!.touchedSection!.touchedSectionIndex);
                  },
                ),
                centerSpaceRadius: 58,
                sectionsSpace: 3,
                sections: sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isTouched = index == touchedIndex;
                  final percent = total > 0
                      ? (item.value / total * 100).toStringAsFixed(1)
                      : '0';
                  final color =
                      _categoryColors[item.key] ?? const Color(0xFF8B95A1);
                  return PieChartSectionData(
                    value: item.value.toDouble(),
                    color: color,
                    radius: isTouched ? 64 : 54,
                    title: isTouched ? '$percent%' : '',
                    titleStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final int total;
  final List<MapEntry<String, int>> sections;

  const _CategoryList({required this.total, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카테고리 상세',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF191F28),
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map((entry) {
            final percent = total > 0 ? entry.value / total : 0.0;
            final color = _categoryColors[entry.key] ?? const Color(0xFF8B95A1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E5968),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${NumberFormat('#,###').format(entry.value)}원',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191F28),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${(percent * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B95A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: const Color(0xFFF2F4F6),
                      color: color,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
