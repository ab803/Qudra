import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class ChatMessageTile extends StatelessWidget {
  final bool isUser;
  final String name;
  final String time;
  final String text;

  const ChatMessageTile({
    super.key,
    required this.isUser,
    required this.name,
    required this.time,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? Appcolors.primaryColor : Colors.white;
    final textColor   = isUser ? Colors.white : Appcolors.textDark;
    final borderColor = isUser ? Colors.transparent : Colors.grey.shade200;
    final shadow = isUser
        ? const <BoxShadow>[]
        : [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

    final radius = isUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(6),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(6),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(18),
    );

    // أفاتار بسيط بدون صور خارجية
    final avatar = CircleAvatar(
      radius: 18,
      backgroundColor: isUser ? Colors.orange.shade200 : Appcolors.cardTeal,
      child: Text(
        isUser ? 'U' : 'AI',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );

    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final cross     = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: cross,
      children: [
        // اسم المرسل
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: isUser ? 0 : 52, // مساحة الأفاتار
            end: isUser ? 52 : 0,
            bottom: 6,
          ),
          child: Text(
            name,
            style: AppTextStyles.body.copyWith(
              color: Appcolors.secondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // صف الأفاتار + الفقاعة
        Row(
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              avatar,
              const SizedBox(width: 10),
            ],

            // الفقاعة نفسها
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = MediaQuery.of(context).size.width * 0.72;
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW, minHeight: 44),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        border: Border.all(color: borderColor),
                        borderRadius: radius,
                        boxShadow: shadow,
                      ),
                      child: Text(
                        text,
                        style: AppTextStyles.body.copyWith(
                          color: textColor,
                          fontSize: 14,
                          height: 1.25,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (isUser) ...[
              const SizedBox(width: 10),
              avatar,
            ],
          ],
        ),

        // الوقت أسفل الفقاعة
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: isUser ? 0 : 52,
            end: isUser ? 52 : 0,
            top: 6,
          ),
          child: Text(
            time,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              color: Appcolors.secondaryColor,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}