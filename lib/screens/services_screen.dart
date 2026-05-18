// lib/screens/services_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        backgroundColor: const Color(0xFFF2F4F6),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddServiceScreen(),
                ),
              ),
              icon: const Icon(Icons.add_rounded,
                  size: 18, color: Color(0xFF3182F6)),
              label: const Text(
                '추가',
                style: TextStyle(
                  color: Color(0xFF3182F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          final subs = provider.subscriptions;
          if (subs.isEmpty) {
            return EmptyStateWidget(
              emoji: '📱',
              title: '아직 서비스가 없어요',
              description: '구독 중인 서비스를 추가하면\n한눈에 관리할 수 있어요.',
              buttonLabel: '첫 서비스 추가하기',
              onButtonTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddServiceScreen(),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: subs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => SubscriptionCard(
              subscription: subs[index],
              onDelete: () => _confirmDelete(context, provider, subs[index].id),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, SubscriptionProvider provider, String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E8EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '서비스를 삭제할까요?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191F28),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '삭제한 서비스는 복구할 수 없어요.',
              style: TextStyle(fontSize: 14, color: Color(0xFF8B95A1)),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Color(0xFFE5E8EB)),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: Color(0xFF4E5968),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.remove(id);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D4D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '삭제',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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
