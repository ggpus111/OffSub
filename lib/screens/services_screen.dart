import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/subscription_card.dart';
import 'add_service_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text('서비스 관리'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: '서비스 추가',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddServiceScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final subscriptions = [...provider.subscriptions]
            ..sort((a, b) => a.name.compareTo(b.name));
          if (subscriptions.isEmpty) {
            return EmptyStateWidget(
              emoji: 'S',
              title: '아직 서비스가 없어요',
              description: '구독 중인 서비스를 추가하면 결제 금액과 결제일을 관리할 수 있어요.',
              buttonLabel: '첫 서비스 추가하기',
              onButtonTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddServiceScreen()),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: subscriptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final subscription = subscriptions[index];
              return SubscriptionCard(
                subscription: subscription,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddServiceScreen(subscription: subscription),
                  ),
                ),
                onDelete: () => _confirmDelete(context, provider, subscription),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SubscriptionProvider provider,
    Subscription subscription,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E8EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${subscription.name}을 삭제할까요?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191F28),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '삭제된 서비스는 다시 복구할 수 없어요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF8B95A1)),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D4D),
                    ),
                    onPressed: () {
                      provider.remove(subscription.id);
                      Navigator.pop(ctx);
                    },
                    child: const Text('삭제'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
