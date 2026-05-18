// lib/screens/permission_screen.dart
import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF3182F6);
const _kBg = Colors.white;
const _kTextPrimary = Color(0xFF191F28);
const _kTextSecondary = Color(0xFF8B95A1);
const _kBorder = Color(0xFFE5E8EB);
const _kRadius = 16.0;
const _kPadH = 24.0;

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  static const _permissions = [
    _PermissionItem(
      icon: Icons.notifications_outlined,
      iconBg: Color(0xFFFF9500),
      title: '알림 권한',
      badge: '권장',
      badgeColor: Color(0xFF34C759),
      reason: '결제일이 다가오면 미리 알려드려요. 놓치는 결제 없이 예산을 관리해보세요.',
      detail: '앱 알림이 허용되지 않으면 결제 예정 알림을 받을 수 없어요.',
    ),
    _PermissionItem(
      icon: Icons.contacts_outlined,
      iconBg: Color(0xFF3182F6),
      title: '연락처 접근',
      badge: '선택',
      badgeColor: Color(0xFF8B95A1),
      reason: '가족과 구독을 공유하거나 팀 계정을 관리할 때 사용돼요.',
      detail: '연락처 정보는 기기 내에서만 사용하며 외부로 전송되지 않아요.',
    ),
    _PermissionItem(
      icon: Icons.credit_card_outlined,
      iconBg: Color(0xFF5856D6),
      title: '결제 내역 접근',
      badge: '필수',
      badgeColor: Color(0xFFFF4D4D),
      reason: '결제 내역을 분석해 구독 서비스를 자동으로 감지해요. 이 권한 없이는 핵심 기능을 사용할 수 없어요.',
      detail: '결제 정보는 AI 분석 후 즉시 삭제되며 서버에 저장되지 않아요.',
    ),
    _PermissionItem(
      icon: Icons.lock_outline,
      iconBg: Color(0xFF34C759),
      title: '생체 인증',
      badge: '선택',
      badgeColor: Color(0xFF8B95A1),
      reason: '지문이나 Face ID로 빠르고 안전하게 로그인하세요.',
      detail: '생체 정보는 기기의 보안 영역에만 저장되며 앱에서 접근할 수 없어요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: _kPadH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Header
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.verified_user_outlined,
                          color: _kPrimary, size: 28),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '앱 사용을 위해\n권한이 필요해요',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '아래 권한들이 왜 필요한지 솔직하게 알려드릴게요.\n허용하지 않아도 일부 기능은 사용 가능해요.',
                      style: TextStyle(
                          fontSize: 15, color: _kTextSecondary, height: 1.6),
                    ),
                    const SizedBox(height: 32),

                    // Shield banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(_kRadius),
                        border: Border.all(
                            color: _kPrimary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _kPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.security,
                                color: _kPrimary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '개인정보 안심 보장',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _kPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '모든 데이터는 기기 내 처리 후 즉시 삭제돼요.',
                                  style: TextStyle(
                                      fontSize: 12, color: _kTextSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Permission Cards
                    ..._permissions.asMap().entries.map((e) => Padding(
                      padding: EdgeInsets.only(
                          bottom: e.key < _permissions.length - 1 ? 12 : 0),
                      child: _PermissionCard(item: e.value),
                    )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(
                _kPadH,
                0,
                _kPadH,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Request permissions then navigate
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_kRadius),
                        ),
                      ),
                      child: const Text(
                        '권한 허용하고 시작하기',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '나중에 설정할게요',
                      style: TextStyle(
                        fontSize: 14,
                        color: _kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Permission Card ───────────────────────────────────────────────
class _PermissionCard extends StatefulWidget {
  final _PermissionItem item;
  const _PermissionCard({required this.item});

  @override
  State<_PermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<_PermissionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kRadius),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(_kRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.iconBg.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(item.icon, color: item.iconBg, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.badgeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.badge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: item.badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.reason,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _kTextSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: _kTextSecondary, size: 20),
                  ),
                ],
              ),
            ),
          ),
          // Expanded detail
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: _kPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.detail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _kTextSecondary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Model ───────────────────────────────────────────────────
class _PermissionItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String badge;
  final Color badgeColor;
  final String reason;
  final String detail;

  const _PermissionItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.reason,
    required this.detail,
  });
}
