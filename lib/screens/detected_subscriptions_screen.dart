import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/payment_record.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/native_bridge.dart';
import '../services/sms_subscription_candidate.dart';
import '../services/sms_subscription_detector.dart';

class DetectedSubscriptionsScreen extends StatefulWidget {
  const DetectedSubscriptionsScreen({super.key});

  @override
  State<DetectedSubscriptionsScreen> createState() =>
      _DetectedSubscriptionsScreenState();
}

class _DetectedSubscriptionsScreenState extends State<DetectedSubscriptionsScreen> {
  bool _loading = true;
  String? _error;
  List<SmsSubscriptionCandidate> _candidates = [];
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSmsCandidates();
  }

  Future<void> _loadSmsCandidates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final hasPermission =
        await NativeBridge.hasSmsPermission() || await NativeBridge.requestSmsPermission();
    if (!hasPermission) {
      setState(() {
        _loading = false;
        _error = '문자 접근 권한이 없어 결제 문자를 분석할 수 없어요.';
      });
      return;
    }

    final messages = await NativeBridge.getSmsMessages(limit: 500);
    final candidates = SmsSubscriptionDetector.detect(messages);
    setState(() {
      _candidates = candidates;
      _selectedIds
        ..clear()
        ..addAll(candidates.map((e) => e.id));
      _loading = false;
    });
  }

  Future<void> _addSelected() async {
    final provider = context.read<SubscriptionProvider>();
    final selected = _candidates.where((item) => _selectedIds.contains(item.id));
    var subscriptionAddedCount = 0;
    var subscriptionSkippedCount = 0;
    var paymentRecordAddedCount = 0;
    var paymentRecordSkippedCount = 0;

    for (final item in selected) {
      final newSubscription = Subscription(
        id: const Uuid().v4(),
        name: item.serviceName,
        amount: item.amount,
        category: item.category,
        colorValue: item.colorValue,
        icon: item.icon,
        billingDay: item.billingDay,
        billingCycle: 'monthly',
        source: SubscriptionSource.sms,
        rawMessage: item.rawMessage,
        sender: item.sender,
        detectedAt: item.detectedAt,
        confidence: item.confidence,
        confirmed: item.confidence >= 0.8,
      );

      // 가격이 변한 경우에도 같은 서비스 결제 이력으로 묶이도록
      // 이름 기준 매칭을 먼저 시도합니다.
      final existingByName = provider.findSubscriptionByName(item.serviceName);
      final existingSimilar = provider.findSimilarSubscription(newSubscription);
      final existing = existingByName ?? existingSimilar;
      final subscription = existing ?? newSubscription;

      if (existing == null) {
        final added = await provider.addIfNotExists(newSubscription);
        if (added) {
          subscriptionAddedCount++;
        } else {
          subscriptionSkippedCount++;
        }
      } else {
        subscriptionSkippedCount++;
      }

      final record = PaymentRecord(
        id: const Uuid().v4(),
        subscriptionId: subscription.id,
        subscriptionName: subscription.name,
        amount: item.amount,
        paidAt: item.detectedAt,
        source: SubscriptionSource.sms,
        rawMessage: item.rawMessage,
        sender: item.sender,
        cardName: null,
        createdAt: DateTime.now(),
      );

      final recordAdded = await provider.addPaymentRecordIfNotExists(record);
      if (recordAdded) {
        paymentRecordAddedCount++;
      } else {
        paymentRecordSkippedCount++;
      }
    }

    if (!mounted) return;
    final message = StringBuffer()
      ..write('구독 $subscriptionAddedCount개')
      ..write(', 결제 이력 $paymentRecordAddedCount건을 추가했어요.');
    if (subscriptionSkippedCount > 0 || paymentRecordSkippedCount > 0) {
      message.write(' 중복은 제외했어요.');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message.toString())),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text('자동 감지 결과'),
        actions: [
          IconButton(
            tooltip: '다시 분석',
            onPressed: _loading ? null : _loadSmsCandidates,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _candidates.isEmpty || _loading
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _selectedIds.isEmpty ? null : _addSelected,
                    child: Text('선택한 ${_selectedIds.length}개 추가하기'),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _InfoState(
        icon: Icons.sms_failed_outlined,
        title: '분석할 수 없어요',
        description: _error!,
        buttonLabel: '다시 시도',
        onTap: _loadSmsCandidates,
      );
    }

    if (_candidates.isEmpty) {
      return _InfoState(
        icon: Icons.search_off_rounded,
        title: '감지된 구독 후보가 없어요',
        description: '최근 문자에서 넷플릭스, 유튜브, 스포티파이 등 알려진 구독 결제 문자를 찾지 못했어요.',
        buttonLabel: '다시 분석',
        onTap: _loadSmsCandidates,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _candidates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _candidates[index];
        final selected = _selectedIds.contains(item.id);
        return _CandidateCard(
          item: item,
          selected: selected,
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedIds.add(item.id);
              } else {
                _selectedIds.remove(item.id);
              }
            });
          },
        );
      },
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final SmsSubscriptionCandidate item;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _CandidateCard({
    required this.item,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final isReliable = item.confidence >= 0.8;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(!selected),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: selected, onChanged: (v) => onChanged(v ?? false)),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.icon,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: item.color,
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
                            item.serviceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF191F28),
                            ),
                          ),
                        ),
                        _StatusChip(
                          text: isReliable ? '자동 확정' : '확인 필요',
                          color: isReliable
                              ? const Color(0xFF3182F6)
                              : const Color(0xFFF57C00),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${formatter.format(item.amount)}원 · 매월 ${item.billingDay}일 추정',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4E5968),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '결제 이력으로도 저장 · 신뢰도 ${(item.confidence * 100).round()}% · ${DateFormat('yyyy.MM.dd').format(item.detectedAt)} 감지',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.rawMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8B95A1), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _InfoState({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8B95A1), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onTap, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
