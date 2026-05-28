import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'voice_state.dart';

class VoiceCubit extends Cubit<VoiceState> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;

  VoiceCubit() : super(VoiceInitial());

  Future<void> toggleListening({String? localeId}) async {
    if (state is VoiceListening) {
      await _speech.stop();
      if (!isClosed) emit(VoiceIdle());
      return;
    }

    final available = await _initializeSpeech();

    if (!available) {
      if (!isClosed) emit(VoiceError('Microphone not available'));
      return;
    }

    if (!isClosed) emit(VoiceListening());

    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase().trim();

        if (words.isNotEmpty && !isClosed) {
          emit(
            VoiceResult(
              words,
              isFinal: result.finalResult,
            ),
          );
        }
      },

      // Gives the user more time to say the full command.
      listenFor: const Duration(seconds: 30),

      // Allows short pauses without stopping too early.
      pauseFor: const Duration(seconds: 5),

      // Enables better recognition while still handling only final results in the UI.
      partialResults: true,

      // Keeps listening safer if a recoverable error happens.
      cancelOnError: false,

      // Uses a command-friendly listening mode.
      listenMode: stt.ListenMode.confirmation,

      // Locale comes from the current app language in VoiceFAB.
      localeId: localeId,
    );
  }

  Future<bool> _initializeSpeech() async {
    if (_isInitialized) return true;

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (!isClosed && state is VoiceListening) {
            emit(VoiceIdle());
          }
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(VoiceError(error.errorMsg));
        }
      },
    );

    _isInitialized = available;
    return available;
  }

  Future<void> stopListening() async {
    await _speech.stop();

    if (!isClosed) {
      emit(VoiceIdle());
    }
  }

  @override
  Future<void> close() async {
    await _speech.stop();
    return super.close();
  }
}