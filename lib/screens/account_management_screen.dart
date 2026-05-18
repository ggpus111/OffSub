// lib/screens/account_management_screen.dart
import 'package:flutter/material.dart';

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '계정 관리',
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 계정 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF3182F6).withOpacity(0.12),
                        child: const Text('김',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3182F6))),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C073),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('김오프',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        const Text('koff@email.com',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF888888))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3182F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('현재 계정',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3182F6))),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3182F6)),
                    child: const Text('편집',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionLabel('계정 전환'),
            const SizedBox(height: 8),
            _SettingsCard(children: [
              _AccountTile(
                initial: '이',
                name: '이서브',
                email: 'esub@email.com',
                color: const Color(0xFFFF6B6B),
                onTap: () => _showSwitchAccountDialog(context),
              ),
              const _Divider(),
              _AddAccountTile(
                onTap: () => _showAddAccountSheet(context),
              ),
            ]),
            const SizedBox(height: 24),

            _SectionLabel('로그인 & 인증'),
            const SizedBox(height: 8),
            _SettingsCard(children: [
              _MenuTile(
                icon: Icons.logout,
                iconColor: const Color(0xFF888888),
                title: '로그아웃',
                onTap: () => _showLogoutDialog(context),
              ),
              const _Divider(),
              _MenuTile(
                icon: Icons.sync_alt,
                iconColor: const Color(0xFF888888),
                title: '소셜 계정 연동',
                trailing: const Text('Google 연동됨',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            _SectionLabel('데이터 & 개인정보'),
            const SizedBox(height: 8),
            _SettingsCard(children: [
              _MenuTile(
                icon: Icons.download_outlined,
                iconColor: const Color(0xFF3182F6),
                title: '내 데이터 내보내기',
                onTap: () {},
              ),
              const _Divider(),
              _MenuTile(
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFFF6B6B),
                title: '회원 탈퇴',
                titleColor: const Color(0xFFFF6B6B),
                onTap: () => _showWithdrawDialog(context),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showSwitchAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('계정 전환',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text('이서브 계정으로 전환할까요?',
            style: TextStyle(color: Color(0xFF555555))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소',
                style: TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('전환',
                style: TextStyle(
                    color: Color(0xFF3182F6), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 28,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('계정 추가',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('최대 5개의 계정을 연결할 수 있어요.',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
            const SizedBox(height: 24),
            _SheetOption(
                icon: Icons.email_outlined,
                label: '이메일로 로그인',
                onTap: () => Navigator.pop(context)),
            const SizedBox(height: 12),
            _SheetOption(
                icon: Icons.person_add_outlined,
                label: '새 계정 만들기',
                onTap: () => Navigator.pop(context)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('로그아웃',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text('정말 로그아웃할까요?',
            style: TextStyle(color: Color(0xFF555555))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소',
                style: TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('로그아웃',
                style: TextStyle(
                    color: Color(0xFFFF6B6B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('정말 탈퇴하시겠어요?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                '탈퇴 시 모든 데이터가 삭제되며\n복구할 수 없어요.',
                style: TextStyle(color: Color(0xFF555555), fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: '"탈퇴합니다" 입력',
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                filled: true,
                fillColor: const Color(0xFFF5F6F8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소',
                style: TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('탈퇴',
                style: TextStyle(
                    color: Color(0xFFFF6B6B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ───────── widgets ─────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF888888))),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, thickness: 1, color: Color(0xFFF0F0F0), indent: 56);
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon,
        required this.iconColor,
        required this.title,
        this.titleColor,
        this.trailing,
        required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? Colors.black)),
          ),
          trailing ??
              const Icon(Icons.chevron_right,
                  color: Color(0xFFCCCCCC), size: 20),
        ],
      ),
    ),
  );
}

class _AccountTile extends StatelessWidget {
  final String initial;
  final String name;
  final String email;
  final Color color;
  final VoidCallback onTap;
  const _AccountTile(
      {required this.initial,
        required this.name,
        required this.email,
        required this.color,
        required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Text(initial,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color, fontSize: 14)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(email,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
          const Text('전환',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3182F6))),
        ],
      ),
    ),
  );
}

class _AddAccountTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAccountTile({required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, color: Color(0xFF888888), size: 20),
          ),
          const SizedBox(width: 14),
          const Text('계정 추가',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3182F6))),
        ],
      ),
    ),
  );
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetOption(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3182F6), size: 22),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}
