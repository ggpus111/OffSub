// lib/screens/statistics_screen.dart
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
  '유틸': Color(0xFF3182F6),
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
              emoji: '📊',
              title: '아직 분석할 데이터가 없어요',
              description: '서비스를 추가하면\n카테고리별 지출을 분석해드려요.',
            );
          }

          final sections = categoryMap.entries.toList();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 총합 카드
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '월 구독 총액',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B95A1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${NumberFormat('#,###').format(total)}원',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF191F28),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 파이 차트
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                            touchCallback: (event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          centerSpaceRadius: 60,
                          sectionsSpace: 3,
                          sections: sections.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final e = entry.value;
                            final isTouched = idx == _touchedIndex;
                            final pct = total > 0
                                ? (e.value / total * 100).toStringAsFixed(1)
                                : '0';
                            final color = _categoryColors[e.key] ??
                                const Color(0xFF8B95A1);
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              color: color,
                              radius: isTouched ? 60 : 50,
                              title: isTouched ? '$pct%' : '',
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
              ),
              const SizedBox(height: 16),

              // 카테고리 목록
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                    ...sections.map((e) {
                      final pct = total > 0
                          ? e.value / total
                          : 0.0;
                      final color = _categoryColors[e.key] ??
                          const Color(0xFF8B95A1);
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
                                  e.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4E5968),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${NumberFormat('#,###').format(e.value)}원',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF191F28),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 38,
                                  child: Text(
                                    '${(pct * 100).toStringAsFixed(0)}%',
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
                                value: pct.toDouble(),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
