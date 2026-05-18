// lib/screens/security_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricEnabled = true;
  bool _autoLockEnabled = false;
  bool _loginAlertEnabled = true;

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
          '보안 설정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('로그인 보안'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.lock_outline,
                  iconColor: const Color(0xFF3182F6),
                  title: '비밀번호 변경',
                  subtitle: '주기적으로 변경하면 계정을 지킬 수 있어요',
                  onTap: () => _showPasswordChangeSheet(context),
                ),
                _Divider(),
                _ActionTile(
                  icon: Icons.pin_outlined,
                  iconColor: const Color(0xFF3182F6),
                  title: 'PIN 번호 변경',
                  subtitle: '앱 잠금에 사용되는 6자리 번호',
                  onTap: () => _showPinChangeSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel('생체 인식'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _ToggleTile(
                  icon: Icons.fingerprint,
                  iconColor: const Color(0xFF00C073),
                  title: '지문 / Face ID 사용',
                  subtitle: '빠르고 안전하게 로그인할 수 있어요',
                  value: _biometricEnabled,
                  onChanged: (v) => setState(() => _biometricEnabled = v),
                ),
                _Divider(),
                _ToggleTile(
                  icon: Icons.timer_outlined,
                  iconColor: const Color(0xFF00C073),
                  title: '자동 잠금',
                  subtitle: '일정 시간 후 앱을 자동으로 잠가요',
                  value: _autoLockEnabled,
                  onChanged: (v) => setState(() => _autoLockEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel('알림'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _ToggleTile(
                  icon: Icons.notifications_active_outlined,
                  iconColor: const Color(0xFFFFA500),
                  title: '로그인 알림',
                  subtitle: '새로운 기기에서 로그인 시 알림을 받아요',
                  value: _loginAlertEnabled,
                  onChanged: (v) => setState(() => _loginAlertEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel('기타'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.history,
                  iconColor: const Color(0xFF888888),
                  title: '로그인 기록',
                  subtitle: '접속 기기 및 시간을 확인해요',
                  onTap: () {},
                ),
                _Divider(),
                _ActionTile(
                  icon: Icons.devices_outlined,
                  iconColor: const Color(0xFF888888),
                  title: '연결된 기기 관리',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPasswordChangeSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 28,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('비밀번호 변경',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            _SheetTextField(controller: currentCtrl, label: '현재 비밀번호', obscure: true),
            const SizedBox(height: 14),
            _SheetTextField(controller: newCtrl, label: '새 비밀번호', obscure: true),
            const SizedBox(height: 14),
            _SheetTextField(controller: confirmCtrl, label: '새 비밀번호 확인', obscure: true),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3182F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('변경하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinChangeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PIN 번호 변경',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('새로운 6자리 PIN을 설정해주세요',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                    (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3182F6), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ───────── shared widgets ─────────

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
  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, thickness: 1, color: Color(0xFFF0F0F0), indent: 56, endIndent: 0);
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon,
        required this.iconColor,
        required this.title,
        this.subtitle,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
        ],
      ),
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile(
      {required this.icon,
        required this.iconColor,
        required this.title,
        this.subtitle,
        required this.value,
        required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          activeColor: const Color(0xFF3182F6),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  const _SheetTextField(
      {required this.controller, required this.label, this.obscure = false});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F6F8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
