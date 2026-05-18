// lib/screens/login_screen.dart
import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF3182F6);
const _kBg = Colors.white;
const _kTextPrimary = Color(0xFF191F28);
const _kTextSecondary = Color(0xFF8B95A1);
const _kBorder = Color(0xFFE5E8EB);
const _kRadius = 14.0;
const _kPadH = 24.0;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _kPadH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ── Logo ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.subscriptions_outlined,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Off',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _kTextPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'Sub',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _kPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                '다시 만나서 반가워요!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '로그인하고 구독 관리를 시작해보세요.',
                style: TextStyle(fontSize: 15, color: _kTextSecondary),
              ),
              const SizedBox(height: 40),

              // ── Email ─────────────────────────────────────────
              _InputLabel('이메일'),
              const SizedBox(height: 8),
              _TossTextField(
                controller: _emailCtrl,
                hint: 'name@example.com',
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.email_outlined,
                    size: 18, color: _kTextSecondary),
              ),
              const SizedBox(height: 16),

              // ── Password ──────────────────────────────────────
              _InputLabel('비밀번호'),
              const SizedBox(height: 8),
              _TossTextField(
                controller: _pwCtrl,
                hint: '비밀번호 입력',
                obscureText: _obscure,
                prefix: const Icon(Icons.lock_outline,
                    size: 18, color: _kTextSecondary),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: _kTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(
                      fontSize: 13,
                      color: _kPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Login Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kRadius),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    '로그인',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Divider ───────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: _kBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '또는',
                      style: TextStyle(
                          fontSize: 13,
                          color: _kTextSecondary.withOpacity(0.8)),
                    ),
                  ),
                  const Expanded(child: Divider(color: _kBorder)),
                ],
              ),
              const SizedBox(height: 24),

              // ── Social Buttons ────────────────────────────────
              _SocialButton(
                label: '카카오로 계속하기',
                bgColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF191919),
                icon: _KakaoIcon(),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                label: 'Google로 계속하기',
                bgColor: Colors.white,
                textColor: _kTextPrimary,
                borderColor: _kBorder,
                icon: _GoogleIcon(),
              ),
              const SizedBox(height: 12),
              _SocialButton(
                label: 'Apple로 계속하기',
                bgColor: const Color(0xFF000000),
                textColor: Colors.white,
                icon: const Icon(Icons.apple,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(height: 32),

              // ── Sign Up ───────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: RichText(
                    text: const TextSpan(
                      text: '계정이 없으신가요?  ',
                      style:
                      TextStyle(fontSize: 14, color: _kTextSecondary),
                      children: [
                        TextSpan(
                          text: '회원가입',
                          style: TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ───────────────────────────────────────────────

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

class _TossTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;

  const _TossTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 15, color: _kTextPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: _kTextSecondary, fontSize: 15),
      prefixIcon: prefix != null
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: prefix,
      )
          : null,
      prefixIconConstraints:
      const BoxConstraints(minWidth: 46, minHeight: 46),
      suffixIcon: suffix != null
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: suffix,
      )
          : null,
      suffixIconConstraints:
      const BoxConstraints(minWidth: 46, minHeight: 46),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kRadius),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kRadius),
        borderSide: const BorderSide(color: _kPrimary, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final Widget icon;

  const _SocialButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor,
        side: BorderSide(color: borderColor ?? bgColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 22, height: 22, child: icon),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    ),
  );
}

class _KakaoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text(
    'K',
    style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF191919)),
  );
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text(
    'G',
    style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4)),
  );
}
