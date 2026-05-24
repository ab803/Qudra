import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Chat_Bot/AIRepo/AIRepo.dart';
import 'package:qudra_0/Feature/Chat_Bot/view%20model/chat_cubit.dart';
import 'package:qudra_0/core/Models/ChatMessage.dart';

// ---------------------------------------------------------------------------
// Repository mock
// ---------------------------------------------------------------------------

class MockChatRepository extends Mock implements IChatRepository {}

// ---------------------------------------------------------------------------
// Cubit mock  (used in widget tests)
// ---------------------------------------------------------------------------

class MockChatCubit extends Mock implements ChatCubit {}

// ---------------------------------------------------------------------------
// Fallback registrations
// ---------------------------------------------------------------------------

void registerChatFallbacks() {
  registerFallbackValue(
    ChatMessage(text: '', isUser: false, time: DateTime(2025)),
  );
}