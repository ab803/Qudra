import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import '../widgets/chat_message_tile.dart';
import '../widgets/chat_typing_indicator.dart';
import '../widgets/chat_suggestion_pill.dart';
import '../widgets/chat_input_bar.dart';

class ChatBotView extends StatelessWidget {
  const ChatBotView({super.key});

  @override
  Widget build(BuildContext context) {
    // رسائل Mock للعرض فقط
    final items = const [
      ChatMessageTile(
        isUser: false,
        name: 'Qudra AI',
        time: '10:24 AM',
        text: 'How can I help you today?',
      ),
      ChatMessageTile(
        isUser: true,
        name: 'You',
        time: '10:25 AM',
        text: 'I need assistance finding the nearest accessible transit station.',
      ),
      // مؤشر كتابة (بدون أنيميشن — UI فقط)
      ChatTypingIndicator(
        time: '10:25 AM',
      ),
    ];

    final suggestions = const [
      ('Emergency help', Icons.emergency_outlined, true),
      ('Nearby institutions', Icons.place_outlined, false),
    ];

    return Scaffold(
      backgroundColor: Appcolors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Appcolors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Qudra AI',
              style: AppTextStyles.subtitle.copyWith(
                color: Appcolors.primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Appcolors.successColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'ONLINE',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.secondaryColor,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Appcolors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // قائمة الرسائل
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => items[i],
              ),
            ),

            // شِبس الاقتراحات
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final (label, icon, isCritical) in suggestions) ...[
                      ChatSuggestionPill(
                        label: label,
                        icon: icon,
                        isCritical: isCritical,
                      ),
                      const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
            ),

            // شريط الإدخال السفلي (UI فقط)
            const ChatInputBar(),
          ],
        ),
      ),
    );
  }
}