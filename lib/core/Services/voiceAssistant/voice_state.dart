// features/voice/cubit/voice_state.dart
part of 'voice_cubit.dart';

abstract class VoiceState {}

class VoiceInitial extends VoiceState {}
class VoiceIdle extends VoiceState {}
class VoiceListening extends VoiceState {}
class VoiceResult extends VoiceState {
  final String words;
  VoiceResult(this.words);
}
class VoiceError extends VoiceState {
  final String message;
  VoiceError(this.message);
}