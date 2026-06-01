import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/subscription_card.dart';
import 'add_service_screen.dart';
import 'price_change_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      body: SafeArea(
        child: Consumer<SubscriptionProvider>(
          builder: (context, provider, _) {
            final subscriptions = provider.upcomingBills;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8B95A1),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'OffSub',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF191F28),
                              ),
                            ),
                          ],
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF3182F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddServiceScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _MonthlyCard(
                      total: provider.totalMonthlyAmount,
                      paidThisMonth: provider.totalPaidThisMonth,
                      count: provider.subscriptions.length,
                    ),
                  ),
                ),
                if (provider.priceChangeAlertCount > 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: _PriceChangeBanner(count: provider.priceChangeAlertCount),
                    ),
                  ),
                if (subscriptions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      emoji: 'S',
                      title: '등록된 구독 서비스가 없어요',
                      description: '자주 사용하는 구독 서비스를 추가하고 결제일을 한눈에 관리해 보세요.',
                      buttonLabel: '서비스 추가하기',
                      onButtonTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddServiceScreen(),
                        ),
                      ),
                    ),
                  )
                else ...[
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '다가오는 결제',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191F28),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    sliver: SliverList.separated(
                      itemCount: subscriptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final subscription = subscriptions[index];
                        return SubscriptionCard(
                          subscription: subscription,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddServiceScreen(
                                subscription: subscription,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '좋은 아침이에요';
    if (hour < 18) return '좋은 오후예요';
    return '오늘도 고생 많았어요';
  }
}

class _MonthlyCard extends StatelessWidget {
  final int total;
  final int paidThisMonth;
  final int count;

  const _MonthlyCard({
    required this.total,
    required this.paidThisMonth,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3182F6), Color(0xFF1A5DC8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이번 달 구독료',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${NumberFormat('#,###').format(total)}원',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(label: '구독 중인 서비스 $count개'),
              _InfoPill(label: '이번 달 실제 결제 ${NumberFormat('#,###').format(paidThisMonth)}원'),
            ],
          ),
        ],
      ),
    );
  }
}


class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


class _PriceChangeBanner extends StatelessWidget {
  final int count;

  const _PriceChangeBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PriceChangeScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFFFF4D4D),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '가격 변동 후보가 있어요',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF191F28),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$count개 구독의 최근 결제 금액을 확인해 주세요.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B95A1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8B95A1)),
            ],
          ),
        ),
      ),
    );
  }
}
