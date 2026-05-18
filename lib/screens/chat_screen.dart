import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_Message> _messages = [
    _Message.ai('안녕하세요. 구독 지출을 같이 정리해 드릴게요.'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final provider = context.read<SubscriptionProvider>();
    setState(() {
      _messages.add(_Message.user(trimmed));
      _messages.add(_Message.ai(_answer(trimmed, provider)));
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _answer(String text, SubscriptionProvider provider) {
    final lower = text.toLowerCase();
    final formatter = NumberFormat('#,###');
    if (provider.subscriptions.isEmpty) {
      return '아직 등록된 구독이 없어요. 서비스 탭에서 첫 구독을 추가하면 총액과 결제일을 바로 분석할 수 있어요.';
    }
    if (lower.contains('총') || lower.contains('얼마') || lower.contains('지출')) {
      return '현재 월 구독 총액은 ${formatter.format(provider.totalMonthlyAmount)}원이고, ${provider.subscriptions.length}개 서비스를 관리 중이에요.';
    }
    if (lower.contains('줄') || lower.contains('절약') || lower.contains('해지')) {
      final highest = [...provider.subscriptions]
        ..sort((a, b) => b.monthlyAmount.compareTo(a.monthlyAmount));
      final target = highest.first;
      return '절약 후보로는 ${target.name}을 먼저 확인해 보세요. 월 환산 ${formatter.format(target.monthlyAmount)}원이라 영향이 가장 큽니다.';
    }
    if (lower.contains('결제') || lower.contains('언제')) {
      final next = provider.upcomingBills.first;
      return '가장 가까운 결제는 ${next.name}이고 매월 ${next.billingDay}일에 ${formatter.format(next.monthlyAmount)}원이 예정돼 있어요.';
    }
    return '총 지출, 다음 결제, 절약 후보처럼 물어보면 지금 등록된 구독 데이터를 기준으로 답해 드릴게요.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(title: const Text('AI 상담')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _Bubble(message: _messages[index]),
            ),
          ),
          _InputBar(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '구독 지출에 대해 물어보세요',
                  filled: true,
                  fillColor: const Color(0xFFF2F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: onSend,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => onSend(controller.text),
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message message;

  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF3182F6) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF191F28),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  const _Message._(this.text, this.isUser);

  factory _Message.user(String text) => _Message._(text, true);

  factory _Message.ai(String text) => _Message._(text, false);
}
