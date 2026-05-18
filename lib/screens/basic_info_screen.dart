// lib/screens/basic_info_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: '김오프');
  final _nicknameCtrl = TextEditingController(text: '오프서브');
  final _emailCtrl = TextEditingController(text: 'koff@email.com');
  final _phoneCtrl = TextEditingController(text: '010-1234-5678');
  final _birthCtrl = TextEditingController(text: '1995-06-15');
  String _selectedGender = '남성';
  bool _hasChanges = false;

  final List<String> _genders = ['남성', '여성', '선택 안함'];

  @override
  void initState() {
    super.initState();
    for (final c in [_nameCtrl, _nicknameCtrl, _emailCtrl, _phoneCtrl, _birthCtrl]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _nicknameCtrl, _emailCtrl, _phoneCtrl, _birthCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

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
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('기본 정보',
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _hasChanges ? _save : null,
            child: Text(
              '저장',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _hasChanges
                      ? const Color(0xFF3182F6)
                      : const Color(0xFFCCCCCC)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 프로필 사진
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3182F6), Color(0xFF5BA4FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3182F6).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('김',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 15, color: Color(0xFF555555)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () {},
                child: const Text('프로필 사진 변경',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3182F6),
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),

              // 이름
              _FormSection(
                label: '이름',
                child: _InputField(
                  controller: _nameCtrl,
                  hint: '이름을 입력해주세요',
                  validator: (v) => (v == null || v.isEmpty) ? '이름을 입력해주세요' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 닉네임
              _FormSection(
                label: '닉네임',
                helperText: '다른 사람에게 보여지는 이름이에요',
                child: _InputField(
                  controller: _nicknameCtrl,
                  hint: '닉네임을 입력해주세요',
                  maxLength: 15,
                  validator: (v) => (v == null || v.length < 2) ? '2자 이상 입력해주세요' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 이메일
              _FormSection(
                label: '이메일',
                helperText: '인증된 이메일은 변경 시 재인증이 필요해요',
                child: _InputField(
                  controller: _emailCtrl,
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                  (v == null || !v.contains('@')) ? '올바른 이메일을 입력해주세요' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 전화번호
              _FormSection(
                label: '전화번호',
                child: _InputField(
                  controller: _phoneCtrl,
                  hint: '010-0000-0000',
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 16),

              // 생년월일
              _FormSection(
                label: '생년월일',
                child: GestureDetector(
                  onTap: () => _pickDate(context),
                  child: AbsorbPointer(
                    child: _InputField(
                      controller: _birthCtrl,
                      hint: 'YYYY-MM-DD',
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 성별
              _FormSection(
                label: '성별',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: _genders.map((g) {
                      final selected = g == _selectedGender;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedGender = g;
                            _hasChanges = true;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF3182F6)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                g,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF888888),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasChanges
                        ? const Color(0xFF3182F6)
                        : const Color(0xFFCCCCCC),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _hasChanges ? _save : null,
                  child: const Text('변경사항 저장',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 6, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF3182F6)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _birthCtrl.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _hasChanges = true);
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('변경사항이 저장됐어요 ✓',
              style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF00C073),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _hasChanges = false);
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('변경사항 취소',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text('변경사항이 저장되지 않아요.\n정말 나가시겠어요?',
            style: TextStyle(color: Color(0xFF555555))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 편집',
                style: TextStyle(
                    color: Color(0xFF3182F6), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('나가기',
                style: TextStyle(
                    color: Color(0xFFFF6B6B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ───────── widgets ─────────

class _FormSection extends StatelessWidget {
  final String label;
  final String? helperText;
  final Widget child;
  const _FormSection(
      {required this.label, this.helperText, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555))),
      ),
      child,
      if (helperText != null) ...[
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(helperText!,
              style:
              const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
        ),
      ],
    ],
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final IconData? suffixIcon;
  const _InputField(
      {required this.controller,
        required this.hint,
        this.keyboardType,
        this.validator,
        this.maxLength,
        this.suffixIcon});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    maxLength: maxLength,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: const Color(0xFFAAAAAA), size: 18)
          : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF3182F6), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFFF6B6B), width: 1.5)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
