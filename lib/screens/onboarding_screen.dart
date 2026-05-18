// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF3182F6);
const _kTextPrimary = Color(0xFF191F28);
const _kTextSecondary = Color(0xFF8B95A1);
const _kRadius = 16.0;
const _kPadH = 32.0;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardPage(
      gradient: [Color(0xFF3182F6), Color(0xFF5AC8FA)],
      icon: Icons.auto_awesome_outlined,
      tag: 'AI POWERED',
      title: '구독을 자동으로\n찾아드려요',
      desc: '결제 내역을 분석해 잊고 있던\n구독 서비스를 자동으로 감지해요.',
    ),
    _OnboardPage(
      gradient: [Color(0xFF34C759), Color(0xFF30B0C7)],
      icon: Icons.shield_outlined,
      tag: 'PRIVACY FIRST',
      title: '개인정보는 기기 안에만\n안전하게 보관해요',
      desc: '결제 정보는 외부 서버에 전송되지 않아요.\n내 기기에서만 분석이 이루어져요.',
    ),
    _OnboardPage(
      gradient: [Color(0xFFFF9500), Color(0xFFFF6B6B)],
      icon: Icons.insights_outlined,
      tag: 'ANALYTICS',
      title: '불필요한 구독을\n쉽게 찾아내요',
      desc: '월별 지출 분석으로 사용하지 않는\n구독을 파악하고 비용을 절약해보세요.',
    ),
    _OnboardPage(
      gradient: [Color(0xFF5856D6), Color(0xFFAF52DE)],
      icon: Icons.rocket_launch_outlined,
      tag: 'LET\'S START',
      title: '지금 바로\n시작해볼까요?',
      desc: '3분이면 구독 현황을 파악할 수 있어요.\n오늘부터 스마트하게 관리해보세요.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login
    }
  }

  void _skip() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
          ),

          // Skip button (top right)
          if (!isLast)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: _kPadH,
              child: TextButton(
                onPressed: _skip,
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(
                    color: _kTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            left: _kPadH,
            right: _kPadH,
            bottom: MediaQuery.of(context).padding.bottom + 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot indicator
                _DotIndicator(
                  count: _pages.length,
                  current: _currentPage,
                  activeColor:
                  _pages[_currentPage].gradient[0],
                ),
                const SizedBox(height: 32),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].gradient[0],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_kRadius),
                      ),
                    ),
                    child: Text(
                      isLast ? '시작하기' : '다음',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                if (!isLast) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {},
                    child: RichText(
                      text: const TextSpan(
                        text: '이미 계정이 있으신가요?  ',
                        style: TextStyle(
                            fontSize: 14, color: _kTextSecondary),
                        children: [
                          TextSpan(
                            text: '로그인',
                            style: TextStyle(
                              color: _kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Onboard Page View ────────────────────────────────────────────
class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        // Illustration area
        Container(
          width: double.infinity,
          height: size.height * 0.48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: page.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Stack(
            children: [
              // Background circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              // Main icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Icon(
                    page.icon,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(_kPadH, 36, _kPadH, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: page.gradient[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    page.tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: page.gradient[0],
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.desc,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _kTextSecondary,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dot Indicator ─────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const _DotIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(count, (i) {
      final isActive = i == current;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFD1D6DB),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
  );
}

// ── Data Model ───────────────────────────────────────────────────
class _OnboardPage {
  final List<Color> gradient;
  final IconData icon;
  final String tag;
  final String title;
  final String desc;

  const _OnboardPage({
    required this.gradient,
    required this.icon,
    required this.tag,
    required this.title,
    required this.desc,
  });
}
