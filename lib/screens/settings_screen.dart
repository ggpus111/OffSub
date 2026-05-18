// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const _kPrimary = Color(0xFF3182F6);
const _kBg = Color(0xFFF2F4F6);
const _kSurface = Colors.white;
const _kTextPrimary = Color(0xFF191F28);
const _kTextSecondary = Color(0xFF8B95A1);
const _kDanger = Color(0xFFFF4D4D);
const _kRadius = 16.0;
const _kPadH = 20.0;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationOn = true;
  bool _biometricOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '설정',
          style: TextStyle(
            color: _kTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: _kPadH, vertical: 8),
        children: [
          // Profile Card
          _ProfileCard(),
          const SizedBox(height: 24),

          // Section: 알림
          _SectionLabel('알림'),
          _SettingsGroup(children: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFFF9500),
              label: '결제 알림',
              subtitle: '결제일 3일 전 알림',
              value: _notificationOn,
              onChanged: (v) => setState(() => _notificationOn = v),
            ),
            _DividerLine(),
            _ArrowTile(
              icon: Icons.tune_outlined,
              iconColor: const Color(0xFF5856D6),
              label: '알림 설정 상세',
            ),
          ]),
          const SizedBox(height: 20),

          // Section: 보안
          _SectionLabel('보안'),
          _SettingsGroup(children: [
            _SwitchTile(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF34C759),
              label: '생체 인증',
              subtitle: '지문 / Face ID 사용',
              value: _biometricOn,
              onChanged: (v) => setState(() => _biometricOn = v),
            ),
            _DividerLine(),
            _ArrowTile(
              icon: Icons.lock_outline,
              iconColor: _kPrimary,
              label: '비밀번호 변경',
            ),
            _DividerLine(),
            _ArrowTile(
              icon: Icons.devices_outlined,
              iconColor: const Color(0xFF636366),
              label: '연결된 기기 관리',
            ),
          ]),
          const SizedBox(height: 20),

          // Section: 계정
          _SectionLabel('계정'),
          _SettingsGroup(children: [
            _ArrowTile(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF007AFF),
              label: '프로필 편집',
            ),
            _DividerLine(),
            _ArrowTile(
              icon: Icons.sync_outlined,
              iconColor: const Color(0xFF30B0C7),
              label: '구독 데이터 동기화',
            ),
            _DividerLine(),
            _ArrowTile(
              icon: Icons.file_download_outlined,
              iconColor: const Color(0xFF34C759),
              label: '데이터 내보내기',
            ),
          ]),
          const SizedBox(height: 20),

          // Section: 정보
          _SectionLabel('정보'),
          _SettingsGroup(children: [
            _ArrowTile(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF636366),
              label: '개인정보 처리방침',
            ),
            _DividerLine(),
            _ArrowTile(
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF636366),
              label: '서비스 이용약관',
            ),
            _DividerLine(),
            _InfoTile(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF636366),
              label: '앱 버전',
              trailing: '1.0.0',
            ),
          ]),
          const SizedBox(height: 20),

          // Danger Zone
          _SettingsGroup(children: [
            _ArrowTile(
              icon: Icons.logout,
              iconColor: _kDanger,
              label: '로그아웃',
              labelColor: _kDanger,
              showArrow: false,
            ),
            _DividerLine(),
            _ArrowTile(
              icon: Icons.delete_forever_outlined,
              iconColor: _kDanger,
              label: '계정 삭제',
              labelColor: _kDanger,
              showArrow: false,
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Sub Widgets ─────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(_kRadius),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3182F6), Color(0xFF5AC8FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '홍길동',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'hong@example.com',
                  style: TextStyle(fontSize: 13, color: _kTextSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: _kTextSecondary),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _kTextSecondary,
      ),
    ),
  );
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(_kRadius),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    ),
    child: Column(children: children),
  );
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    height: 0,
    indent: 56,
    endIndent: 0,
    color: Color(0xFFF2F4F6),
  );
}

Widget _iconBox(IconData icon, Color color) => Container(
  width: 32,
  height: 32,
  margin: const EdgeInsets.only(right: 14),
  decoration: BoxDecoration(
    color: color.withOpacity(0.12),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(icon, color: color, size: 18),
);

class _ArrowTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final bool showArrow;

  const _ArrowTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(_kRadius),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _iconBox(icon, iconColor),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: labelColor ?? _kTextPrimary,
              ),
            ),
          ),
          if (showArrow)
            const Icon(Icons.chevron_right,
                color: _kTextSecondary, size: 20),
        ],
      ),
    ),
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        _iconBox(icon, iconColor),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _kTextPrimary,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 12, color: _kTextSecondary)),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: _kPrimary,
        ),
      ],
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String trailing;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        _iconBox(icon, iconColor),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _kTextPrimary,
            ),
          ),
        ),
        Text(trailing,
            style: const TextStyle(
                fontSize: 14, color: _kTextSecondary)),
      ],
    ),
  );
}
