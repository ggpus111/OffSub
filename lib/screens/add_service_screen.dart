import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(',', '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');
    final number = int.tryParse(digitsOnly);
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###').format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
  '넷플릭스': _ServicePreset(
    icon: 'N',
    colorValue: 0xFFE50914,
    category: 'OTT',
    defaultAmount: 17000,
  ),
  'netflix': _ServicePreset(
    icon: 'N',
    colorValue: 0xFFE50914,
    category: 'OTT',
    defaultAmount: 17000,
  ),
  '유튜브': _ServicePreset(
    icon: 'Y',
    colorValue: 0xFFFF0000,
    category: 'OTT',
    defaultAmount: 14900,
  ),
  'youtube': _ServicePreset(
    icon: 'Y',
    colorValue: 0xFFFF0000,
    category: 'OTT',
    defaultAmount: 14900,
  ),
  '스포티파이': _ServicePreset(
    icon: 'S',
    colorValue: 0xFF1DB954,
    category: '음악',
    defaultAmount: 10900,
  ),
  'spotify': _ServicePreset(
    icon: 'S',
    colorValue: 0xFF1DB954,
    category: '음악',
    defaultAmount: 10900,
  ),
  '디즈니': _ServicePreset(
    icon: 'D',
    colorValue: 0xFF113CCF,
    category: 'OTT',
    defaultAmount: 9900,
  ),
  '쿠팡': _ServicePreset(
    icon: 'C',
    colorValue: 0xFFEE2C2C,
    category: '쇼핑',
    defaultAmount: 7890,
  ),
  '멜론': _ServicePreset(
    icon: 'M',
    colorValue: 0xFF00CD3C,
    category: '음악',
    defaultAmount: 10900,
  ),
  'notion': _ServicePreset(
    icon: 'N',
    colorValue: 0xFF111111,
    category: '생산성',
    defaultAmount: 12000,
  ),
};

const _categories = ['OTT', '음악', '게임', '쇼핑', '생산성', '교육', '기타'];
const _categoryColors = <String, int>{
  'OTT': 0xFFE50914,
  '음악': 0xFF1DB954,
  '게임': 0xFF6441A4,
  '쇼핑': 0xFFFF6B35,
  '생산성': 0xFF3182F6,
  '교육': 0xFFF59E0B,
  '기타': 0xFF8B95A1,
};

class AddServiceScreen extends StatefulWidget {
  final Subscription? subscription;

  const AddServiceScreen({super.key, this.subscription});

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
  String _selectedIcon = 'S';
  int _selectedColorValue = 0xFF3182F6;
  int _billingDay = DateTime.now().day.clamp(1, 31).toInt();
  String _billingCycle = 'monthly';
  bool _isMatchedPreset = false;

  bool get _isEditing => widget.subscription != null;

  @override
  void initState() {
    super.initState();
    final subscription = widget.subscription;
    if (subscription != null) {
      _nameCtrl.text = subscription.name;
      _amountCtrl.text = NumberFormat('#,###').format(subscription.amount);
      _selectedCategory = subscription.category;
      _selectedIcon = subscription.icon;
      _selectedColorValue = subscription.colorValue;
      _billingDay = subscription.billingDay;
      _billingCycle = subscription.billingCycle;
    }
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
    if (_isEditing) return;
    final lower = _nameCtrl.text.toLowerCase().trim();
    _ServicePreset? matched;
    for (final entry in _presets.entries) {
      if (lower.length >= 2 && entry.key.toLowerCase().contains(lower)) {
        matched = entry.value;
        break;
      }
    }

    if (matched == null) {
      if (_isMatchedPreset) {
        setState(() {
          _selectedIcon = 'S';
          _selectedColorValue = 0xFF3182F6;
          _isMatchedPreset = false;
        });
      }
      return;
    }

    setState(() {
      _selectedIcon = matched!.icon;
      _selectedColorValue = matched.colorValue;
      _selectedCategory = matched.category;
      _isMatchedPreset = true;
      if (_amountCtrl.text.isEmpty) {
        _amountCtrl.text = NumberFormat('#,###').format(matched.defaultAmount);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final rawAmount = int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    if (rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('금액을 올바르게 입력해 주세요.')),
      );
      return;
    }

    final subscription = Subscription(
      id: widget.subscription?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      amount: rawAmount,
      category: _selectedCategory,
      colorValue: _selectedColorValue,
      icon: _selectedIcon,
      billingDay: _billingDay,
      billingCycle: _billingCycle,
    );

    final provider = context.read<SubscriptionProvider>();
    if (_isEditing) {
      await provider.update(subscription);
    } else {
      await provider.add(subscription);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: Text(_isEditing ? '서비스 수정' : '서비스 추가'),
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
              _PreviewCard(
                icon: _selectedIcon,
                name: _nameCtrl.text.isEmpty ? '서비스명' : _nameCtrl.text,
                colorValue: _selectedColorValue,
                isMatched: _isMatchedPreset,
              ),
              const SizedBox(height: 28),
              const _SectionLabel(label: '서비스명'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_amountFocus),
                decoration: InputDecoration(
                  hintText: '예: 넷플릭스, 스포티파이',
                  suffixIcon: _isMatchedPreset
                      ? const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Chip(label: Text('자동 매칭')),
                        )
                      : null,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? '서비스명을 입력해 주세요.'
                    : null,
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: '결제 금액'),
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
                  suffixText: '원',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? '금액을 입력해 주세요.' : null,
              ),
              const SizedBox(height: 12),
              _CycleSwitch(
                value: _billingCycle == 'yearly',
                onChanged: (value) => setState(
                    () => _billingCycle = value ? 'yearly' : 'monthly'),
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: '카테고리'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  final color = Color(_categoryColors[category] ?? 0xFF3182F6);
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: color.withOpacity(0.14),
                    checkmarkColor: color,
                    labelStyle: TextStyle(
                      color: isSelected ? color : const Color(0xFF6B7684),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? color : const Color(0xFFE5E8EB),
                    ),
                    onSelected: (_) => setState(() {
                      _selectedCategory = category;
                      if (!_isMatchedPreset) {
                        _selectedColorValue =
                            _categoryColors[category] ?? 0xFF3182F6;
                        _selectedIcon = category.substring(0, 1);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: '결제일'),
              const SizedBox(height: 12),
              _BillingDayPicker(
                value: _billingDay,
                onChanged: (value) => setState(() => _billingDay = value),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isEditing ? '변경사항 저장' : '서비스 추가하기',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
}

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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                icon.toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191F28),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMatched ? '알려진 서비스 정보가 자동으로 적용됐어요.' : '서비스 정보를 입력해 주세요.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isMatched
                        ? const Color(0xFF3182F6)
                        : const Color(0xFF8B95A1),
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

class _CycleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CycleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '연간 결제',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4E5968),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '켜면 월 환산 금액으로 통계에 반영돼요.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B95A1)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF3182F6),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _BillingDayPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _BillingDayPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(31, (index) {
          final day = index + 1;
          final selected = day == value;
          return ChoiceChip(
            label: Text('$day일'),
            selected: selected,
            selectedColor: const Color(0xFFEBF3FE),
            labelStyle: TextStyle(
              color:
                  selected ? const Color(0xFF3182F6) : const Color(0xFF6B7684),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            side: BorderSide(
              color:
                  selected ? const Color(0xFF3182F6) : const Color(0xFFE5E8EB),
            ),
            onSelected: (_) => onChanged(day),
          );
        }),
      ),
    );
  }
}
