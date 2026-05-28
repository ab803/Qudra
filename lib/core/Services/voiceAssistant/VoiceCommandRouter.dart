// features/voice/voice_command_router.dart
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class VoiceCommandRouter {
  static bool handle(String command, BuildContext context) {
    final normalizedCommand = _normalize(command);

    // --- Bottom Nav / Shell routes ---
    if (_containsAny(normalizedCommand, [
      'home',
      'main',
      'الرئيسيه',
      'الصفحه الرئيسيه',
      'الصفحة الرئيسية',
      'الرئيسية',
      'البيت',
      'الهوم',
    ])) {
      context.go('/home');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'institution',
      'institutions',
      'organization',
      'organizations',
      'مؤسسه',
      'مؤسسات',
      'المؤسسات',
      'المنظمات',
      'منظمات',
      'مكان',
      'اماكن',
      'الأماكن',
      'الاماكن',
    ])) {
      context.go('/institution');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'reminder',
      'reminders',
      'medicine',
      'medical reminder',
      'medical reminders',
      'تذكير',
      'تذكيرات',
      'دواء',
      'ادويه',
      'أدوية',
      'العلاج',
      'مواعيد الدواء',
    ])) {
      context.push('/reminders');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'community',
      'مجتمع',
      'الكوميونيتي',
      'المجتمع',
      'منشورات',
      'بوستات',
    ])) {
      context.push('/community');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'profile',
      'account',
      'my account',
      'الملف',
      'الملف الشخصي',
      'حسابي',
      'الحساب',
      'البروفايل',
    ])) {
      context.push('/profile');
      return true;
    }

    // --- Top-level routes ---
    if (_containsAny(normalizedCommand, [
      'chat',
      'bot',
      'assistant',
      'ai',
      'ai assistant',
      'مساعد',
      'المساعد',
      'المساعد الذكي',
      'شات',
      'دردشه',
      'دردشة',
      'اسال',
      'إسأل',
      'اسأل',
    ])) {
      context.push('/chat');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'emergency',
      'help',
      'sos',
      'طوارئ',
      'الطوارئ',
      'نجده',
      'نجدة',
      'ساعدني',
      'مساعده',
      'مساعدة',
    ])) {
      context.push('/emergency-entry');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'accessibility',
      'accessibility hub',
      'accessibility help',
      'rights',
      'tips',
      'accessability',
      'accessability hub',
      'rigths',
      'rigths and tips',
      'rights and tips',
      'امكانيه الوصول',
      'إمكانية الوصول',
      'امكانية الوصول',
      'النصائح',
      'نصائح',
      'الحقوق',
      'حقوق',
      'حق',
    ])) {
      context.push('/accessibility');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'feedback',
      'review',
      'rate',
      'rating',
      'تقييم',
      'قيمني',
      'قيم',
      'ملاحظات',
      'ملاحظه',
      'ملاحظة',
      'فيدباك',
    ])) {
      context.push('/feedback');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'booking',
      'bookings',
      'my bookings',
      'reservation',
      'reservations',
      'appointment',
      'appointments',
      'حجز',
      'حجوزات',
      'حجوزاتي',
      'مواعيدي',
      'ميعاد',
      'المواعيد',
    ])) {
      context.push('/my-bookings');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'personal',
      'personal info',
      'personal information',
      'my information',
      'بيانات',
      'بياناتي',
      'معلومات',
      'معلوماتي',
      'معلومات شخصية',
      'المعلومات الشخصية',
    ])) {
      context.push('/personal');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'guidelines',
      'guide',
      'app guidelines',
      'instructions',
      'تعليمات',
      'ارشادات',
      'إرشادات',
      'ارشادات التطبيق',
      'إرشادات التطبيق',
      'دليل',
      'دليل التطبيق',
    ])) {
      context.push('/AppGuidelines');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'map',
      'smart map',
      'accessible map',
      'خريطه',
      'خريطة',
      'الخريطه',
      'الخريطة',
      'الماب',
      'اماكن قريبه',
      'أماكن قريبة',
    ])) {
      context.push('/smart-map');
      return true;
    }

    // --- Auth routes ---
    if (_containsAny(normalizedCommand, [
      'login',
      'log in',
      'sign in',
      'تسجيل دخول',
      'دخول',
      'سجل دخول',
    ])) {
      context.push('/login');
      return true;
    }

    if (_containsAny(normalizedCommand, [
      'signup',
      'sign up',
      'register',
      'create account',
      'تسجيل',
      'انشاء حساب',
      'إنشاء حساب',
      'اعمل حساب',
    ])) {
      context.push('/signUp');
      return true;
    }

    // Booking sub-routes (/booking/checkout, /booking/card, etc.) are intentionally
    // excluded because they require typed `extra` args that cannot come from voice alone.
    return false;
  }

  static bool _containsAny(String command, List<String> keywords) {
    return keywords.any((keyword) => command.contains(_normalize(keyword)));
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}