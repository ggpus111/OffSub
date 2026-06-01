// lib/screens/price_change_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/price_change_alert.dart';
import '../providers/subscription_provider.dart';

class PriceChangeScreen extends StatelessWidget {
  const PriceChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(title: const Text('가격 변동 감지')),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final alerts = provider.priceChangeAlerts;

          if (alerts.isEmpty) {
            return const _EmptyPriceChangeState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _PriceChangeCard(alert: alert, formatter: formatter);
            },
          );
        },
      ),
    );
  }
}

class _PriceChangeCard extends StatelessWidget {
  final PriceChangeAlert alert;
  final NumberFormat formatter;

  const _PriceChangeCard({required this.alert, required this.formatter});

  @override
  Widget build(BuildContext context) {
    final color = alert.increased
        ? const Color(0xFFFF4D4D)
        : alert.decreased
            ? const Color(0xFF3182F6)
            : const Color(0xFF8B95A1);
    final diffText = alert.difference == 0
        ? '변동 없음'
        : '${alert.increased ? '+' : ''}${formatter.format(alert.difference)}원';
    final rateText = alert.changeRate == 0
        ? '0%'
        : '${alert.increased ? '+' : ''}${alert.changeRate.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  alert.increased
                      ? Icons.trending_up_rounded
                      : alert.decreased
                          ? Icons.trending_down_rounded
                          : Icons.compare_arrows_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.subscription.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF191F28),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$diffText · $rateText',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _AmountBox(
                  label: alert.type == PriceChangeType.changedFromPrevious
                      ? '이전 결제'
                      : '등록 금액',
                  amount: alert.oldAmount,
                  formatter: formatter,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8B95A1)),
              const SizedBox(width: 10),
              Expanded(
                child: _AmountBox(
                  label: '최근 결제',
                  amount: alert.newAmount,
                  formatter: formatter,
                  highlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '최근 감지일: ${DateFormat('yyyy.MM.dd').format(alert.latestRecord.paidAt)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1)),
          ),
          if ((alert.latestRecord.rawMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              alert.latestRecord.rawMessage!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1), height: 1.45),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () async {
                await context.read<SubscriptionProvider>().applyLatestAmount(
                      alert.subscription.id,
                      alert.newAmount,
                    );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${alert.subscription.name} 금액을 최신 결제 금액으로 반영했어요.')),
                );
              },
              child: const Text('최신 금액으로 반영'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  final String label;
  final int amount;
  final NumberFormat formatter;
  final bool highlighted;

  const _AmountBox({
    required this.label,
    required this.amount,
    required this.formatter,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFEBF3FE) : const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B95A1),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${formatter.format(amount)}원',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: highlighted ? const Color(0xFF3182F6) : const Color(0xFF191F28),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPriceChangeState extends StatelessWidget {
  const _EmptyPriceChangeState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.price_check_rounded, size: 60, color: Color(0xFF8B95A1)),
            SizedBox(height: 18),
            Text(
              '가격 변동이 없어요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '문자에서 같은 구독의 결제 이력이 2번 이상 쌓이거나, 최근 결제 금액이 등록 금액과 다르면 여기에 표시돼요.',
              style: TextStyle(fontSize: 14, color: Color(0xFF8B95A1), height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
