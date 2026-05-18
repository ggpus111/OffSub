// lib/screens/add_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

// ──────────────────────────────────────────────
// 1. 콤마 자동 포매터
// ──────────────────────────────────────────────
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(',', '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final number = int.tryParse(digitsOnly);
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###').format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ──────────────────────────────────────────────
// 2. 서비스 프리셋
// ──────────────────────────────────────────────
class _ServicePreset {
  final String icon;
  final int colorValue;
  final String category;
  final int defaultAmount;

  const _ServicePreset({
    required this.icon,
    required this.colorValue,
    required this.category,
    required this.defaultAmount,
  });
}

const _presets = <String, _ServicePreset>{
  '넷플릭스': _ServicePreset(icon: '🎬', colorValue: 0xFFE50914, category: 'OTT', defaultAmount: 17000),
  'netflix': _ServicePreset(icon: '🎬', colorValue: 0xFFE50914, category: 'OTT', defaultAmount: 17000),
  '유튜브 프리미엄': _ServicePreset(icon: '▶️', colorValue: 0xFFFF0000, category: 'OTT', defaultAmount: 14900),
  'youtube premium': _ServicePreset(icon: '▶️', colorValue: 0xFFFF0000, category: 'OTT', defaultAmount: 14900),
  '스포티파이': _ServicePreset(icon: '🎵', colorValue: 0xFF1DB954, category: '음악', defaultAmount: 10900),
  'spotify': _ServicePreset(icon: '🎵', colorValue: 0xFF1DB954, category: '음악', defaultAmount: 10900),
  '애플 뮤직': _ServicePreset(icon: '🎸', colorValue: 0xFFFC3C44, category: '음악', defaultAmount: 8900),
  'apple music': _ServicePreset(icon: '🎸', colorValue: 0xFFFC3C44, category: '음악', defaultAmount: 8900),
  '디즈니+': _ServicePreset(icon: '🏰', colorValue: 0xFF113CCF, category: 'OTT', defaultAmount: 9900),
  'disney+': _ServicePreset(icon: '🏰', colorValue: 0xFF113CCF, category: 'OTT', defaultAmount: 9900),
  '쿠팡 로켓와우': _ServicePreset(icon: '📦', colorValue: 0xFFEE2C2C, category: '쇼핑', defaultAmount: 7890),
  '왓챠': _ServicePreset(icon: '🎞️', colorValue: 0xFFE63462, category: 'OTT', defaultAmount: 7900),
  '웨이브': _ServicePreset(icon: '🌊', colorValue: 0xFF2F6BFF, category: 'OTT', defaultAmount: 7900),
  '티빙': _ServicePreset(icon: '📺', colorValue: 0xFFFF153C, category: 'OTT', defaultAmount: 7900),
  '멜론': _ServicePreset(icon: '🍈', colorValue: 0xFF00CD3C, category: '음악', defaultAmount: 10900),
  '네이버 플러스': _ServicePreset(icon: '🟢', colorValue: 0xFF03C75A, category: '유틸', defaultAmount: 4900),
  '카카오 이모티콘': _ServicePreset(icon: '😊', colorValue: 0xFFFFE000, category: '유틸', defaultAmount: 4900),
  '애플 원': _ServicePreset(icon: '🍎', colorValue: 0xFF888888, category: '유틸', defaultAmount: 16900),
  'apple one': _ServicePreset(icon: '🍎', colorValue: 0xFF888888, category: '유틸', defaultAmount: 16900),
  '클래스101': _ServicePreset(icon: '📚', colorValue: 0xFFFF4545, category: '교육', defaultAmount: 29900),
  '밀리의서재': _ServicePreset(icon: '📖', colorValue: 0xFF4F46E5, category: '교육', defaultAmount: 9900),
  '노션': _ServicePreset(icon: '📝', colorValue: 0xFF000000, category: '유틸', defaultAmount: 12000),
  'notion': _ServicePreset(icon: '📝', colorValue: 0xFF000000, category: '유틸', defaultAmount: 12000),
};

const _categories = ['OTT', '음악', '게임', '쇼핑', '유틸', '교육', '기타'];
const _categoryColors = <String, int>{
  'OTT': 0xFFE50914,
  '음악': 0xFF1DB954,
  '게임': 0xFF6441A4,
  '쇼핑': 0xFFFF6B35,
  '유틸': 0xFF3182F6,
  '교육': 0xFFF59E0B,
  '기타': 0xFF8B95A1,
};

// ──────────────────────────────────────────────
// 3. AddServiceScreen
// ──────────────────────────────────────────────
class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _amountFocus = FocusNode();

  String _selectedCategory = 'OTT';
  String _selectedIcon = '💳';
  int _selectedColorValue = 0xFF3182F6;
  int _billingDay = DateTime.now().day;
  String _billingCycle = 'monthly';
  bool _isMatchedPreset = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _nameFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final lower = _nameCtrl.text.toLowerCase().trim();
    _ServicePreset? matched;
    String? matchedKey;
    for (final entry in _presets.entries) {
      if (entry.key.toLowerCase().contains(lower) && lower.length >= 2) {
        matched = entry.value;
        matchedKey = entry.key;
        break;
      }
    }
    if (matched != null && matchedKey != null) {
      setState(() {
        _selectedIcon = matched!.icon;
        _selectedColorValue = matched.colorValue;
        _selectedCategory = matched.category;
        _isMatchedPreset = true;
        if (_amountCtrl.text.isEmpty) {
          final formatted = NumberFormat('#,###').format(matched.defaultAmount);
          _amountCtrl.text = formatted;
        }
      });
    } else {
      if (_isMatchedPreset) {
        setState(() {
          _selectedIcon = '💳';
          _selectedColorValue = 0xFF3182F6;
          _isMatchedPreset = false;
        });
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final rawAmount =
        int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    if (rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('금액을 올바르게 입력해주세요')),
      );
      return;
    }
    final sub = Subscription(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      amount: rawAmount,
      category: _selectedCategory,
      colorValue: _selectedColorValue,
      icon: _selectedIcon,
      billingDay: _billingDay,
      billingCycle: _billingCycle,
    );
    context.read<SubscriptionProvider>().add(sub);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text('서비스 추가'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 서비스 미리보기 카드
              _PreviewCard(
                icon: _selectedIcon,
                name: _nameCtrl.text.isEmpty ? '서비스명' : _nameCtrl.text,
                colorValue: _selectedColorValue,
                isMatched: _isMatchedPreset,
              ),
              const SizedBox(height: 28),

              // 서비스명
              _SectionLabel(label: '서비스명'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_amountFocus),
                decoration: InputDecoration(
                  hintText: '예) 넷플릭스, 스포티파이',
                  hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
                  suffixIcon: _isMatchedPreset
                      ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                            const Color(0xFF3182F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '자동 매칭됨',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3182F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : null,
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? '서비스명을 입력해주세요' : null,
              ),
              const SizedBox(height: 20),

              // 금액
              _SectionLabel(label: '월 결제 금액'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountCtrl,
                focusNode: _amountFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsFormatter(),
                ],
                decoration: const InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(color: Color(0xFFB0B8C1)),
                  suffixText: '원',
                  suffixStyle: TextStyle(
                    color: Color(0xFF4E5968),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? '금액을 입력해주세요' : null,
              ),
              const SizedBox(height: 8),

              // 연간 결제 토글
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text(
                      '연간 결제',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4E5968)),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: _billingCycle == 'yearly',
                      activeColor: const Color(0xFF3182F6),
                      onChanged: (v) => setState(
                              () => _billingCycle = v ? 'yearly' : 'monthly'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 카테고리
              _SectionLabel(label: '카테고리'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final catColor = Color(
                      _categoryColors[cat] ?? 0xFF3182F6);
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = cat;
                      if (!_isMatchedPreset) {
                        _selectedColorValue =
                            _categoryColors[cat] ?? 0xFF3182F6;
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? catColor.withOpacity(0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected ? catColor : const Color(0xFFE5E8EB),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? catColor : const Color(0xFF8B95A1),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 결제일
              _SectionLabel(label: '결제일'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text(
                      '매월',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4E5968)),
                    ),
                    const Spacer(),
                    _DaySelector(
                      value: _billingDay,
                      onChanged: (v) => setState(() => _billingDay = v),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '일',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4E5968)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 추가 버튼
              SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    '서비스 추가하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 보조 위젯들
// ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4E5968),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String icon;
  final String name;
  final int colorValue;
  final bool isMatched;

  const _PreviewCard({
    required this.icon,
    required this.name,
    required this.colorValue,
    required this.isMatched,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191F28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isMatched ? '서비스가 자동으로 인식되었어요 ✨' : '서비스명을 입력하세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: isMatched
                        ? const Color(0xFF3182F6)
                        : const Color(0xFFB0B8C1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DaySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDialog<int>(
          context: context,
          builder: (ctx) => _DayPickerDialog(initialDay: value),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF3FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3182F6),
          ),
        ),
      ),
    );
  }
}

class _DayPickerDialog extends StatefulWidget {
  final int initialDay;
  const _DayPickerDialog({required this.initialDay});

  @override
  State<_DayPickerDialog> createState() => _DayPickerDialogState();
}

class _DayPickerDialogState extends State<_DayPickerDialog> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        '결제일 선택',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: 28,
          itemBuilder: (_, index) {
            final day = index + 1;
            final isSelected = day == _selected;
            return GestureDetector(
              onTap: () => setState(() => _selected = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3182F6)
                      : const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF4E5968),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소',
              style: TextStyle(color: Color(0xFF8B95A1))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3182F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text('확인',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
