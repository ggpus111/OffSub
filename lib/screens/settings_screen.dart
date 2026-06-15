import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/subscription_provider.dart';
import '../services/notification_service.dart';
import 'payment_history_screen.dart';
import 'price_change_screen.dart';
import 'app_usage_analysis_screen.dart';

const _kPrimary = Color(0xFF3182F6);
const _kBg = Color(0xFFF2F4F6);
const _kTextPrimary = Color(0xFF191F28);
const _kTextSecondary = Color(0xFF8B95A1);
const _kDanger = Color(0xFFFF4D4D);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _notificationKey = 'setting_notification_on';
  static const _biometricKey = 'setting_biometric_on';
  static const _userNameKey = 'local_user_name';

  bool _notificationOn = true;
  bool _biometricOn = false;
  String _userName = '사용자';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationOn = prefs.getBool(_notificationKey) ?? true;
      _biometricOn = prefs.getBool(_biometricKey) ?? false;
      _userName = prefs.getString(_userNameKey) ?? '사용자';
    });
  }
  Future<void> _changeUserName() async {
    final controller = TextEditingController(text: _userName);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사용자 이름 변경'),
        content: TextField(
          controller: controller,
          maxLength: 12,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '이름을 입력해 주세요',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(dialogContext, name);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, result);

    if (!mounted) return;
    setState(() => _userName = result);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('사용자 이름이 저장됐어요.')),
    );
  }

  Future<void> _setNotification(bool value) async {
    final provider = context.read<SubscriptionProvider>();
    await NotificationService.setEnabled(value, provider.subscriptions);

    final enabled = await NotificationService.isEnabled();
    if (!mounted) return;
    setState(() => _notificationOn = enabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? '결제 하루 전과 당일 오전 9시에 알림을 보낼게요.'
              : '결제 알림을 껐어요.',
        ),
      ),
    );
  }

  Future<void> _setBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, value);
    setState(() => _biometricOn = value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
        _ProfileCard(
        name: _userName,
        count: provider.subscriptions.length,
        onTap: _changeUserName,
      ),
          const SizedBox(height: 24),
          const _SectionLabel('알림'),
          _SettingsGroup(children: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              iconColor: const Color(0xFFFF9500),
              label: '결제 알림',
              subtitle: '결제 하루 전과 당일 오전 9시에 알려드려요.',
              value: _notificationOn,
              onChanged: _setNotification,
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionLabel('보안'),
          _SettingsGroup(children: [
            _SwitchTile(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF34C759),
              label: '생체 인증',
              subtitle: '앱 잠금에 사용할 설정을 저장해 둬요.',
              value: _biometricOn,
              onChanged: _setBiometric,
            ),
            const _DividerLine(),
            _ActionTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: _kPrimary,
              label: '온디바이스 처리',
              subtitle: '현재 앱 데이터는 기기 저장소에만 보관됩니다.',
              onTap: () => _showInfo(
                context,
                '개인정보 보호',
                'OffSub는 현재 등록한 구독 데이터를 서버로 전송하지 않고 기기 안에 저장합니다.',
              ),
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionLabel('데이터'),
          _SettingsGroup(children: [
            _ActionTile(
              icon: Icons.receipt_long_outlined,
              iconColor: _kPrimary,
              label: '결제 이력 보기',
              subtitle: '문자에서 감지된 실제 결제 기록을 확인해요.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
              ),
            ),
            const _DividerLine(),
            _ActionTile(
              icon: Icons.trending_up_rounded,
              iconColor: provider.priceChangeAlertCount > 0
                  ? _kDanger
                  : const Color(0xFF8B95A1),
              label: '가격 변동 감지',
              subtitle: provider.priceChangeAlertCount > 0
                  ? '${provider.priceChangeAlertCount}개의 가격 변동 후보가 있어요.'
                  : '최근 결제 금액 변화를 확인해요.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PriceChangeScreen()),
              ),
            ),
            const _DividerLine(),
            _ActionTile(
              icon: Icons.query_stats_rounded,
              iconColor: const Color(0xFF5856D6),
              label: '앱 사용량 분석',
              subtitle: '구독료와 실제 앱 사용 시간을 비교해요.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppUsageAnalysisScreen()),
              ),
            ),
            const _DividerLine(),
            _ActionTile(
              icon: Icons.file_download_outlined,
              iconColor: const Color(0xFF34C759),
              label: '데이터 내보내기',
              subtitle: '구독 목록과 결제 이력을 JSON으로 클립보드에 복사해요.',
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: provider.exportJson()));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('구독 데이터가 클립보드에 복사됐어요.')),
                );
              },
            ),
            const _DividerLine(),
            _ActionTile(
              icon: Icons.delete_forever_outlined,
              iconColor: _kDanger,
              label: '모든 서비스 삭제',
              labelColor: _kDanger,
              subtitle: '저장된 구독 서비스를 모두 지워요.',
              onTap: provider.subscriptions.isEmpty
                  ? null
                  : () => _confirmClearAll(context, provider),
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionLabel('정보'),
          const _SettingsGroup(children: [
            _InfoTile(
              icon: Icons.info_outline,
              iconColor: Color(0xFF636366),
              label: '앱 버전',
              trailing: '1.0.0',
            ),
          ]),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, SubscriptionProvider provider) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('모든 서비스를 삭제할까요?'),
        content: const Text('저장된 구독 목록이 모두 삭제되며 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kDanger),
            onPressed: () async {
              await provider.clearAll();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final int count;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '사' : name.trim()[0];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$count개 구독 관리 중',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 20,
                color: _kTextSecondary,
              ),
            ],
          ),
        ),
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
            fontWeight: FontWeight.w700,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(children: children),
      );
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) => const Divider(
        height: 0,
        indent: 56,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _iconBox(icon, iconColor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: onTap == null
                            ? _kTextSecondary
                            : labelColor ?? _kTextPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _kTextSecondary),
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
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _kTextSecondary,
                      ),
                    ),
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
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(fontSize: 14, color: _kTextSecondary),
            ),
          ],
        ),
      );
}
