// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF3182F6);
const _kBg = Colors.white;
const _kTextPrimary = Color(0xFF191F28);
const _kTextSecondary = Color(0xFF8B95A1);
const _kBorder = Color(0xFFE5E8EB);
const _kRadius = 14.0;
const _kPadH = 24.0;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _step = 0; // 0,1,2
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();
  bool _obscurePw = true;
  bool _obscurePw2 = true;

  bool _agreeAll = false;
  bool _agree1 = false; // 이용약관
  bool _agree2 = false; // 개인정보
  bool _agree3 = false; // 마케팅 (선택)

  void _toggleAll(bool? v) {
    final val = v ?? false;
    setState(() {
      _agreeAll = val;
      _agree1 = val;
      _agree2 = val;
      _agree3 = val;
    });
  }

  void _updateAll() {
    setState(() {
      _agreeAll = _agree1 && _agree2 && _agree3;
    });
  }

  bool get _canProceed {
    if (_step == 0) return _nameCtrl.text.isNotEmpty;
    if (_step == 1) {
      return _emailCtrl.text.contains('@') &&
          _pwCtrl.text.length >= 8 &&
          _pwCtrl.text == _pw2Ctrl.text;
    }
    return _agree1 && _agree2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: _step == 0
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: _kTextPrimary, size: 18),
          onPressed: () => setState(() => _step--),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기',
                style: TextStyle(color: _kTextSecondary, fontSize: 15)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _StepProgress(currentStep: _step, totalSteps: 3),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: _kPadH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Step label
                    Text(
                      'STEP ${_step + 1}/3',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        '어떻게 불러드릴까요?',
                        '계정 정보를 입력해주세요.',
                        '약관에 동의해주세요.',
                      ][_step],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        '서비스에서 사용할 이름을 알려주세요.',
                        '이메일과 안전한 비밀번호를 설정해주세요.',
                        '필수 약관 동의 후 서비스를 이용할 수 있어요.',
                      ][_step],
                      style: const TextStyle(
                          fontSize: 15, color: _kTextSecondary),
                    ),
                    const SizedBox(height: 36),

                    // Step content
                    if (_step == 0) _Step0(nameCtrl: _nameCtrl),
                    if (_step == 1)
                      _Step1(
                        emailCtrl: _emailCtrl,
                        pwCtrl: _pwCtrl,
                        pw2Ctrl: _pw2Ctrl,
                        obscurePw: _obscurePw,
                        obscurePw2: _obscurePw2,
                        onTogglePw: () =>
                            setState(() => _obscurePw = !_obscurePw),
                        onTogglePw2: () =>
                            setState(() => _obscurePw2 = !_obscurePw2),
                        onChanged: () => setState(() {}),
                      ),
                    if (_step == 2)
                      _Step2(
                        agreeAll: _agreeAll,
                        agree1: _agree1,
                        agree2: _agree2,
                        agree3: _agree3,
                        onAllChanged: _toggleAll,
                        onChanged1: (v) {
                          setState(() => _agree1 = v ?? false);
                          _updateAll();
                        },
                        onChanged2: (v) {
                          setState(() => _agree2 = v ?? false);
                          _updateAll();
                        },
                        onChanged3: (v) {
                          setState(() => _agree3 = v ?? false);
                          _updateAll();
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(_kPadH, 0, _kPadH, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canProceed
                      ? () {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      // Submit
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    disabledBackgroundColor: const Color(0xFFD9E5FC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadius),
                    ),
                  ),
                  child: Text(
                    _step < 2 ? '다음' : '가입 완료',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step Progress ────────────────────────────────────────────────
class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepProgress({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(left: i == 0 ? 0 : 2, right: i == totalSteps - 1 ? 0 : 2),
            decoration: BoxDecoration(
              color: i <= currentStep ? _kPrimary : const Color(0xFFE5E8EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Step 0 ───────────────────────────────────────────────────────
class _Step0 extends StatelessWidget {
  final TextEditingController nameCtrl;
  const _Step0({required this.nameCtrl});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _InputLabel('이름'),
      const SizedBox(height: 8),
      _TossField(controller: nameCtrl, hint: '홍길동', onChanged: (_) {}),
    ],
  );
}

// ── Step 1 ───────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController pwCtrl;
  final TextEditingController pw2Ctrl;
  final bool obscurePw;
  final bool obscurePw2;
  final VoidCallback onTogglePw;
  final VoidCallback onTogglePw2;
  final VoidCallback onChanged;

  const _Step1({
    required this.emailCtrl,
    required this.pwCtrl,
    required this.pw2Ctrl,
    required this.obscurePw,
    required this.obscurePw2,
    required this.onTogglePw,
    required this.onTogglePw2,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _InputLabel('이메일'),
      const SizedBox(height: 8),
      _TossField(
        controller: emailCtrl,
        hint: 'name@example.com',
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => onChanged(),
      ),
      const SizedBox(height: 20),
      const _InputLabel('비밀번호'),
      const SizedBox(height: 8),
      _TossField(
        controller: pwCtrl,
        hint: '8자 이상 입력해주세요',
        obscureText: obscurePw,
        suffixIcon: GestureDetector(
          onTap: onTogglePw,
          child: Icon(
            obscurePw ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: _kTextSecondary,
          ),
        ),
        onChanged: (_) => onChanged(),
      ),
      const SizedBox(height: 6),
      _PwStrengthBar(password: pwCtrl.text),
      const SizedBox(height: 20),
      const _InputLabel('비밀번호 확인'),
      const SizedBox(height: 8),
      _TossField(
        controller: pw2Ctrl,
        hint: '비밀번호를 다시 입력해주세요',
        obscureText: obscurePw2,
        isError: pw2Ctrl.text.isNotEmpty && pwCtrl.text != pw2Ctrl.text,
        suffixIcon: GestureDetector(
          onTap: onTogglePw2,
          child: Icon(
            obscurePw2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18,
            color: _kTextSecondary,
          ),
        ),
        onChanged: (_) => onChanged(),
      ),
      if (pw2Ctrl.text.isNotEmpty && pwCtrl.text != pw2Ctrl.text)
        const Padding(
          padding: EdgeInsets.only(top: 6, left: 4),
          child: Text(
            '비밀번호가 일치하지 않습니다.',
            style: TextStyle(fontSize: 12, color: Color(0xFFFF4D4D)),
          ),
        ),
    ],
  );
}

// ── Step 2 ───────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final bool agreeAll;
  final bool agree1;
  final bool agree2;
  final bool agree3;
  final ValueChanged<bool?> onAllChanged;
  final ValueChanged<bool?> onChanged1;
  final ValueChanged<bool?> onChanged2;
  final ValueChanged<bool?> onChanged3;

  const _Step2({
    required this.agreeAll,
    required this.agree1,
    required this.agree2,
    required this.agree3,
    required this.onAllChanged,
    required this.onChanged1,
    required this.onChanged2,
    required this.onChanged3,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      // All agree
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: agreeAll
              ? _kPrimary.withOpacity(0.06)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(_kRadius),
          border: Border.all(
            color: agreeAll ? _kPrimary.withOpacity(0.3) : _kBorder,
          ),
        ),
        child: Row(
          children: [
            _TossCheckbox(value: agreeAll, onChanged: onAllChanged),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '모두 동의합니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _AgreeTile(
        label: '[필수] 서비스 이용약관',
        value: agree1,
        onChanged: onChanged1,
      ),
      const SizedBox(height: 8),
      _AgreeTile(
        label: '[필수] 개인정보 수집·이용 동의',
        value: agree2,
        onChanged: onChanged2,
      ),
      const SizedBox(height: 8),
      _AgreeTile(
        label: '[선택] 마케팅 정보 수신 동의',
        value: agree3,
        onChanged: onChanged3,
        isOptional: true,
      ),
    ],
  );
}

class _AgreeTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isOptional;

  const _AgreeTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      children: [
        _TossCheckbox(value: value, onChanged: onChanged),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isOptional ? _kTextSecondary : _kTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(Icons.chevron_right, size: 18, color: _kTextSecondary),
      ],
    ),
  );
}

class _TossCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TossCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: value ? _kPrimary : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: value ? _kPrimary : const Color(0xFFCDD1D5),
          width: 1.5,
        ),
      ),
      child: value
          ? const Icon(Icons.check, color: Colors.white, size: 15)
          : null,
    ),
  );
}

// ── Password Strength ─────────────────────────────────────────────
class _PwStrengthBar extends StatelessWidget {
  final String password;
  const _PwStrengthBar({required this.password});

  int get _strength {
    if (password.length < 4) return 0;
    int s = 0;
    if (password.length >= 8) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.transparent,
      const Color(0xFFFF4D4D),
      const Color(0xFFFF9500),
      const Color(0xFF34C759),
      _kPrimary,
    ];
    final labels = ['', '취약', '보통', '강함', '매우 강함'];

    return Row(
      children: [
        ...List.generate(
          4,
              (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < _strength
                    ? colors[_strength]
                    : const Color(0xFFE5E8EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_strength > 0)
          Text(
            labels[_strength],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors[_strength],
            ),
          ),
      ],
    );
  }
}

// ── Shared ───────────────────────────────────────────────────────
class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: _kTextPrimary,
    ),
  );
}

class _TossField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool isError;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String> onChanged;

  const _TossField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.isError = false,
    this.keyboardType,
    this.suffixIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    onChanged: onChanged,
    style: const TextStyle(fontSize: 15, color: _kTextPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kTextSecondary),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      suffixIcon: suffixIcon != null
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: suffixIcon,
      )
          : null,
      suffixIconConstraints:
      const BoxConstraints(minWidth: 46, minHeight: 46),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kRadius),
        borderSide: BorderSide(
            color: isError ? const Color(0xFFFF4D4D) : _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kRadius),
        borderSide: BorderSide(
            color: isError ? const Color(0xFFFF4D4D) : _kPrimary,
            width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
