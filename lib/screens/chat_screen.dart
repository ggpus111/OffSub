// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subscription_service.dart';

enum _MessageType { user, ai, guide }

class _Message {
  final String id;
  final String text;
  final _MessageType type;
  final DateTime timestamp;
  final SubscriptionService? guideService;

  _Message({
    required this.id,
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.guideService,
  }) : timestamp = timestamp ?? DateTime.now();
}

const _kAiBlue = Color(0xFF3182F6);
const _kBg = Color(0xFFF2F4F6);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingController;

  final List<_QuickAction> _quickActions = const [
    _QuickAction('💸', '유튜브 해지 도와줘', 'youtube'),
    _QuickAction('🎵', '스포티파이 해지할래', 'spotify'),
    _QuickAction('📊', '내 구독 분석해줘', null),
    _QuickAction('💡', '요금 아끼는 방법?', null),
    _QuickAction('🔍', '안 쓰는 구독 찾아줘', null),
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 400), () {
      _addAiMessage(
        '안녕하세요! 저는 OffSub AI 어시스턴트예요 🤖\n'
            '구독 관리, 해지 가이드, 비용 절약 팁을 도와드릴게요.\n\n'
            '지금 바로 해지를 원하는 서비스를 알려주세요!',
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_Message(
        id: DateTime.now().toIso8601String(),
        text: text,
        type: _MessageType.user,
      ));
      _isTyping = true;
    });
    _scrollToBottom();
    _textController.clear();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isTyping = false);
      _processAiResponse(text);
    });
  }

  void _processAiResponse(String userText) {
    final lower = userText.toLowerCase();

    if (lower.contains('유튜브') || lower.contains('youtube')) {
      _addAiMessage(
        '유튜브 프리미엄 해지를 도와드릴게요 📋\n'
            '이번 달 사용량이 240분으로 평균보다 낮아요.\n'
            '아래 해지 가이드를 확인해주세요!',
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _messages.add(_Message(
            id: '${DateTime.now().toIso8601String()}_guide',
            text: '',
            type: _MessageType.guide,
            guideService: mockSubscriptions.firstWhere((s) => s.id == 'youtube'),
          ));
        });
        _scrollToBottom();
      });
    } else if (lower.contains('스포티파이') || lower.contains('spotify')) {
      _addAiMessage(
        '스포티파이를 이번 달 한 번도 사용하지 않으셨네요 😮\n'
            '월 10,900원을 아낄 수 있어요!\n해지 가이드를 바로 보여드릴게요.',
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _messages.add(_Message(
            id: '${DateTime.now().toIso8601String()}_guide',
            text: '',
            type: _MessageType.guide,
            guideService:
            mockSubscriptions.firstWhere((s) => s.id == 'spotify'),
          ));
        });
        _scrollToBottom();
      });
    } else if (lower.contains('분석') || lower.contains('구독')) {
      final total = mockSubscriptions.fold(0.0, (s, e) => s + e.monthlyCost);
      final unused =
          mockSubscriptions.where((s) => s.monthlyUsageMinutes == 0).length;
      _addAiMessage(
        '현재 구독 현황을 분석했어요 🔍\n\n'
            '• 총 구독료: 월 ${_fmt(total.round())}원\n'
            '• 총 구독 수: ${mockSubscriptions.length}개\n'
            '• 이번 달 미사용: $unused개\n\n'
            '미사용 서비스를 모두 해지하면 월 최대 ${_fmt(unused * 11000)}원 절약 가능해요!',
      );
    } else if (lower.contains('절약') || lower.contains('아끼')) {
      _addAiMessage(
        '구독료 절약 팁을 알려드릴게요 💡\n\n'
            '1️⃣ 가족 요금제 활용 (최대 50% 할인)\n'
            '2️⃣ 연간 구독 전환 (월 대비 약 20% 저렴)\n'
            '3️⃣ 학생 할인 여부 확인\n'
            '4️⃣ 미사용 서비스 즉시 해지\n\n'
            'OffSub AI가 최적의 플랜을 찾아드릴게요!',
      );
    } else {
      _addAiMessage(
        '죄송해요, 아직 배우는 중이에요 🤖\n'
            '아래 버튼을 눌러 빠르게 시작하거나,\n'
            '"유튜브 해지 도와줘"처럼 입력해보세요!',
      );
    }
  }

  void _addAiMessage(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(_Message(
        id: DateTime.now().toIso8601String(),
        text: text,
        type: _MessageType.ai,
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageItem(msg, index);
              },
            ),
          ),
          _buildQuickActions(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3182F6), Color(0xFF5B6FF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OffSub AI',
                style: TextStyle(
                  color: Color(0xFF191F28),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '온디바이스 · 항상 활성',
                style: TextStyle(
                  color: Color(0xFF00C73C),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _messages.clear());
            Future.delayed(const Duration(milliseconds: 300), () {
              _addAiMessage('대화가 초기화됐어요! 무엇을 도와드릴까요? 😊');
            });
          },
          icon: const Icon(Icons.refresh_rounded,
              color: Color(0xFF8B95A1), size: 22),
        ),
      ],
    );
  }

  Widget _buildMessageItem(_Message msg, int index) {
    if (msg.type == _MessageType.guide && msg.guideService != null) {
      return _buildGuideCard(msg.guideService!, index);
    }

    final isUser = msg.type == _MessageType.user;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(isUser ? 20 * (1 - value) : -20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3182F6), Color(0xFF5B6FF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 14),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? _kAiBlue : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? _kAiBlue.withOpacity(0.25)
                            : const Color(0x0A000000),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF191F28),
                      fontSize: 14,
                      height: 1.55,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(SubscriptionService service, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) =>
          Transform.translate(
            offset: Offset(0, 20 * (1 - v)),
            child: Opacity(opacity: v, child: child),
          ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 38),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    service.brandColor.withOpacity(0.08),
                    service.brandColor.withOpacity(0.02),
                  ],
                ),
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: service.brandColorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        service.name[0],
                        style: TextStyle(
                          color: service.brandColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${service.name} 해지 가이드',
                        style: const TextStyle(
                          color: Color(0xFF191F28),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '월 ${_fmt(service.monthlyCost.round())}원 절약 예정',
                        style: TextStyle(
                          color: service.brandColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Steps
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _GuideStep(step: 1, text: '${service.name} 앱 열기 또는 웹사이트 접속'),
                  _GuideStep(step: 2, text: '설정 → 계정 → 구독 관리 선택'),
                  _GuideStep(step: 3, text: '구독 취소 버튼 탭'),
                  _GuideStep(step: 4, text: '취소 사유 선택 후 최종 확인'),
                  const SizedBox(height: 12),
                  // Deep Link Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${service.name} 해지 페이지로 이동 중...'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF191F28),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: service.brandColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: Text(
                        '${service.name} 바로 해지하기',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_rounded,
                          size: 12, color: Color(0xFF8B95A1)),
                      const SizedBox(width: 4),
                      Text(
                        service.cancelUrl ?? '공식 해지 링크',
                        style: const TextStyle(
                          color: Color(0xFF8B95A1),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 38),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _typingController,
              builder: (_, __) {
                final offset = ((_typingController.value + i * 0.3) % 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: Transform.translate(
                    offset: Offset(0, -4 * (1 - (offset - 0.5).abs() * 2)),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _kAiBlue.withOpacity(0.4 + offset * 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final qa = _quickActions[i];
          return GestureDetector(
            onTap: () => _addUserMessage(qa.text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E8EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(qa.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(
                    qa.text,
                    style: const TextStyle(
                      color: Color(0xFF3B4552),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(
                  color: Color(0xFF191F28),
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: '해지하고 싶은 구독을 알려주세요',
                  hintStyle: TextStyle(
                    color: Color(0xFFB0B8C1),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _addUserMessage,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _addUserMessage(_textController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3182F6), Color(0xFF5B6FF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3182F6).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

// ─── Guide Step Widget ────────────────────────────────────────────────────────

class _GuideStep extends StatelessWidget {
  final int step;
  final String text;
  const _GuideStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _kAiBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: _kAiBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF3B4552),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Model ───────────────────────────────────────────────────────

class _QuickAction {
  final String emoji;
  final String text;
  final String? serviceId;
  const _QuickAction(this.emoji, this.text, this.serviceId);
}
