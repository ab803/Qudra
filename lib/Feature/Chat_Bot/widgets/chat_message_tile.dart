import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bubbleColor = isUser ? colorScheme.primary : theme.cardColor;
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final borderColor = isUser ? Colors.transparent : theme.dividerColor;
    final shadow = isUser
        ? const <BoxShadow>[]
        : [
      BoxShadow(
        color: theme.shadowColor.withOpacity(
          theme.brightness == Brightness.dark ? 0.08 : 0.04,
        ),
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
      backgroundColor: isUser
          ? colorScheme.primary
          : colorScheme.primary.withOpacity(
        theme.brightness == Brightness.dark ? 0.20 : 0.12,
      ),
      child: Text(
        isUser ? 'U' : 'AI',
        style: TextStyle(
          color: isUser ? colorScheme.onPrimary : colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final alignment = isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final cross = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

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
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.65),
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
                        style: theme.textTheme.bodyMedium?.copyWith(
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
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}