// features/voice/voice_command_router.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class VoiceCommandRouter {
  static void handle(String command, BuildContext context) {
    // --- Bottom Nav (ShellRoute) ---
    if (command.contains('home') || command.contains('الرئيسية')) {
      context.go('/home');

    } else if (command.contains('institution') || command.contains('مؤسس') || command.contains('مؤسسات')) {
      context.go('/institution');

    } else if (command.contains('reminder') || command.contains('تذكير') || command.contains('دواء')) {
      context.go('/reminders');

    } else if (command.contains('community') || command.contains('مجتمع')) {
      context.go('/community');

    } else if (command.contains('profile') || command.contains('الملف') || command.contains('حسابي')) {
      context.go('/profile');

      // --- Top-level Push Routes ---
    } else if (command.contains('chat') || command.contains('مساعد') || command.contains('شات')) {
      context.push('/chat');

    } else if (command.contains('emergency') || command.contains('طوارئ')) {
      context.push('/emergency-entry');

    } else if (command.contains('accessibility') || command.contains('إمكانية الوصول') || command.contains('حقوق')) {
      context.push('/accessibility');

    } else if (command.contains('feedback') || command.contains('تقييم') || command.contains('ملاحظات')) {
      context.push('/feedback');

    } else if (command.contains('booking') || command.contains('حجز') || command.contains('حجوزاتي')) {
      context.push('/my-bookings');

    } else if (command.contains('personal') || command.contains('بيانات') || command.contains('معلومات شخصية')) {
      context.push('/personal');

    } else if (command.contains('guidelines') || command.contains('تعليمات') || command.contains('دليل')) {
      context.push('/AppGuidelines');

      // --- Auth (only reachable when logged out, router handles guard) ---
    } else if (command.contains('login') || command.contains('تسجيل دخول')) {
      context.go('/login');

    } else if (command.contains('sign up') || command.contains('تسجيل')) {
      context.go('/signUp');
    }
    else if (command.contains('Accessability hub') || command.contains('النصائح')|| command.contains('الحقوق') || command.contains('rigths&tips')) {
      context.go('/accessibility');
    }else if (command.contains('App Guidelines') || command.contains('ارشادات التطببق')) {
      context.go('/AppGuidelines');
    }else if (command.contains('personal info') || command.contains('معلوماتي')) {
      context.go('/personal');
    }else if (command.contains('sign up') || command.contains('تسجيل')) {
      context.go('/signUp');
    }
    // Booking sub-routes (/booking/checkout, /booking/card, etc.) are intentionally
    // excluded — they require typed `extra` args that can't come from voice alone.
  }
}