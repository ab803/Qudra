// features/voice/cubit/voice_state.dart
part of 'voice_cubit.dart';

abstract class VoiceState {}

class VoiceInitial extends VoiceState {}

class VoiceIdle extends VoiceState {}

class VoiceListening extends VoiceState {}

class VoiceResult extends VoiceState {
  final String words;

  // Indicates whether the speech result is final or still partial.
  final bool isFinal;

  VoiceResult(
      this.words, {
        this.isFinal = true,
      });
}

class VoiceError extends VoiceState {
  final String message;

  VoiceError(this.message);
}