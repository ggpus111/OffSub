import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_usage_insight.dart';
import '../providers/subscription_provider.dart';
import '../services/app_usage_analyzer.dart';
import '../services/native_bridge.dart';

class AppUsageAnalysisScreen extends StatefulWidget {
  const AppUsageAnalysisScreen({super.key});

  @override
  State<AppUsageAnalysisScreen> createState() => _AppUsageAnalysisScreenState();
}

class _AppUsageAnalysisScreenState extends State<AppUsageAnalysisScreen> {
  bool _loading = true;
  String? _error;
  List<AppUsageInsight> _insights = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<SubscriptionProvider>();
    if (provider.subscriptions.isEmpty) {
      setState(() {
        _loading = false;
        _insights = [];
      });
      return;
    }

    final rawStats = await NativeBridge.getUsageStats();
    if (!mounted) return;

    if (rawStats.isEmpty) {
      setState(() {
        _loading = false;
        _error = '앱 사용 기록을 가져오지 못했어요. Android 설정에서 OffSub의 사용 정보 접근 권한을 허용한 뒤 다시 분석해 주세요.';
      });
      return;
    }

    final insights = AppUsageAnalyzer.analyze(
      subscriptions: provider.subscriptions,
      rawUsageStats: rawStats,
    );

    setState(() {
      _insights = insights;
      _loading = false;
    });
  }

  Future<void> _openSettings() async {
    final opened = await NativeBridge.openUsageAccessSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? '사용 정보 접근 권한을 허용한 뒤 다시 분석해 주세요.'
              : '설정 앱에서 사용 정보 접근 권한을 직접 허용해 주세요.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text('앱 사용량 분석'),
        actions: [
          IconButton(
            tooltip: '다시 분석',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _InfoState(
        icon: Icons.query_stats_rounded,
        title: '사용량을 가져올 수 없어요',
        description: _error!,
        primaryLabel: '권한 설정 열기',
        onPrimaryTap: _openSettings,
        secondaryLabel: '다시 분석',
        onSecondaryTap: _load,
      );
    }

    if (_insights.isEmpty) {
      return _InfoState(
        icon: Icons.subscriptions_outlined,
        title: '분석할 구독이 없어요',
        description: '구독 서비스를 먼저 추가하면 앱 사용 시간과 월 구독료를 비교할 수 있어요.',
        primaryLabel: '다시 분석',
        onPrimaryTap: _load,
      );
    }

    final low = _insights.where((item) => item.grade == UsageValueGrade.low).length;
    final totalWasteCandidate = _insights
        .where((item) => item.grade == UsageValueGrade.low)
        .fold<int>(0, (sum, item) => sum + item.monthlyAmount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        _SummaryCard(
          lowCount: low,
          totalWasteCandidate: totalWasteCandidate,
          totalCount: _insights.length,
        ),
        const SizedBox(height: 16),
        const Text(
          '구독별 가성비',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF191F28),
          ),
        ),
        const SizedBox(height: 12),
        ..._insights.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _InsightCard(item: item),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int lowCount;
  final int totalWasteCandidate;
  final int totalCount;

  const _SummaryCard({
    required this.lowCount,
    required this.totalWasteCandidate,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '사용량 기반 절약 후보',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8B95A1),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$lowCount개',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Color(0xFF191F28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lowCount == 0
                ? '분석한 $totalCount개 구독 중 뚜렷한 절약 후보는 없어요.'
                : '절약 후보 금액은 월 ${formatter.format(totalWasteCandidate)}원 정도예요.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4E5968),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final AppUsageInsight item;

  const _InsightCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final color = _gradeColor(item.grade);
    final usageText = item.usageMinutes >= 60
        ? '${(item.usageMinutes / 60).toStringAsFixed(item.usageMinutes >= 600 ? 0 : 1)}시간'
        : '${item.usageMinutes}분';
    final costText = item.costPerHour == null
        ? '시간당 비용 계산 불가'
        : '시간당 약 ${formatter.format(item.costPerHour!.round())}원';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.subscription.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  item.subscription.icon.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: item.subscription.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.subscription.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF191F28),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          item.grade.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _ChipText('${formatter.format(item.monthlyAmount)}원/월'),
                      _ChipText('사용 $usageText'),
                      _ChipText(costText),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.reason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7684),
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.packageName.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.packageName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB0B8C1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(UsageValueGrade grade) {
    switch (grade) {
      case UsageValueGrade.high:
        return const Color(0xFF34C759);
      case UsageValueGrade.medium:
        return const Color(0xFFFF9500);
      case UsageValueGrade.low:
        return const Color(0xFFFF4D4D);
      case UsageValueGrade.unknown:
        return const Color(0xFF8B95A1);
    }
  }
}

class _ChipText extends StatelessWidget {
  final String text;

  const _ChipText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7684),
        ),
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  const _InfoState({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSettingsButton = primaryLabel.contains('권한');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF8B95A1)),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B95A1),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (isSettingsButton)
              FilledButton.icon(
                onPressed: onPrimaryTap,
                icon: const Icon(Icons.settings_rounded),
                label: Text(primaryLabel),
              )
            else
              FilledButton.icon(
                onPressed: onPrimaryTap,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(primaryLabel),
              ),

            if (secondaryLabel != null && onSecondaryTap != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onSecondaryTap,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
