import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/Services/voiceAssistant/VoiceFab.dart';
import '../widgets/Category_section.dart';
import '../widgets/QuickSection.dart';
import '../widgets/Recommended_section.dart';
import '../widgets/custom_searchBar.dart';
import '../widgets/home_header.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  // This controller handles the first entrance of the AI teaser from screen edge.
  late final AnimationController _entryController;

  // This controller runs the idle floating + waving motion continuously.
  late final AnimationController _idleController;

  late final Animation<Offset> _slideAnimation;
  bool _showAiTeaser = true;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // This animation slides the teaser from the right side into view.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.15, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final aiTitle = isArabic ? 'مساعد قدرة الذكي' : 'Qudra AI Assistant';
    final aiMessage = isArabic
        ? 'محتاج مساعدة؟ اسأل المساعد الذكي في أي وقت.'
        : 'Need help? Ask the AI assistant anytime.';

    return Scaffold(
      floatingActionButton: const VoiceFAB(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  HomeHeader(),
                  SizedBox(height: 24),
                  CustomSearchBar(),
                  SizedBox(height: 24),
                  CategorySection(),
                  SizedBox(height: 24),
                  RecommendedSection(),
                  SizedBox(height: 24),
                  QuickAccessSection(),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // This AI teaser introduces the assistant visually without changing the main layout.
            if (_showAiTeaser)
              PositionedDirectional(
                end: 14,
                bottom: 108,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: AnimatedBuilder(
                    animation: _idleController,
                    builder: (context, child) {
                      final floatY = math.sin(_idleController.value * math.pi * 2) * 4;
                      return Transform.translate(
                        offset: Offset(0, floatY),
                        child: child,
                      );
                    },
                    child: _AiAssistantTeaser(
                      title: aiTitle,
                      message: aiMessage,
                      isArabic: isArabic,
                      idleController: _idleController,
                      onOpenChat: () => context.push('/chat'),
                      onDismiss: () => setState(() => _showAiTeaser = false),
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

// This widget renders a premium AI teaser with a simple mascot and speech bubble.
class _AiAssistantTeaser extends StatelessWidget {
  final String title;
  final String message;
  final bool isArabic;
  final AnimationController idleController;
  final VoidCallback onOpenChat;
  final VoidCallback onDismiss;

  const _AiAssistantTeaser({
    required this.title,
    required this.message,
    required this.isArabic,
    required this.idleController,
    required this.onOpenChat,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onOpenChat,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 215),
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.18 : 0.06,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // This small tail makes the container feel like a speech bubble.
                PositionedDirectional(
                  end: -7,
                  bottom: 18,
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border(
                          top: BorderSide(color: theme.dividerColor),
                          right: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 18),
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Directionality(
                        textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                        child: Text(
                          title,
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                        child: Text(
                          message,
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // This close control dismisses the teaser with no effect on app logic.
                PositionedDirectional(
                  top: -4,
                  end: -2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: onDismiss,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // This mascot is built fully in Flutter with no assets.
        GestureDetector(
          onTap: onOpenChat,
          child: AnimatedBuilder(
            animation: idleController,
            builder: (context, _) {
              final waveRotation =
                  math.sin(idleController.value * math.pi * 2) * 0.35;
              final tilt =
                  math.sin((idleController.value * math.pi * 2) + 0.6) * 0.04;

              return Transform.rotate(
                angle: tilt,
                child: SizedBox(
                  width: 82,
                  height: 92,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 0,
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.dark ? 0.26 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF2DD4BF),
                                Color(0xFF0F766E),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withOpacity(
                                  theme.brightness == Brightness.dark
                                      ? 0.28
                                      : 0.18,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 16,
                        right: 16,
                        top: 0,
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF5EEAD4),
                                Color(0xFF14B8A6),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF14B8A6).withOpacity(
                                  theme.brightness == Brightness.dark
                                      ? 0.32
                                      : 0.18,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  theme.brightness == Brightness.dark ? 0.92 : 0.96,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      _MascotEye(),
                                      SizedBox(width: 8),
                                      _MascotEye(),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 14,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFF0F766E),
                                          width: 1.8,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // This small waving hand creates the "hello" motion.
                      Positioned(
                        top: 9,
                        right: 4,
                        child: Transform.rotate(
                          angle: waveRotation,
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF99F6E4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.45),
                              ),
                            ),
                            child: const Icon(
                              Icons.waving_hand_rounded,
                              size: 14,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MascotEye extends StatelessWidget {
  const _MascotEye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        shape: BoxShape.circle,
      ),
    );
  }
}