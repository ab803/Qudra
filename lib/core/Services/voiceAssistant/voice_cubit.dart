import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'voice_state.dart';

class VoiceCubit extends Cubit<VoiceState> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  VoiceCubit() : super(VoiceInitial());

  Future<void> toggleListening() async {
    if (state is VoiceListening) {
      await _speech.stop();
      emit(VoiceIdle());
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (!isClosed) emit(VoiceIdle());
        }
      },
      onError: (error) {
        if (!isClosed) emit(VoiceError(error.errorMsg));
      },
    );

    if (!available) {
      emit(VoiceError('Microphone not available'));
      return;
    }

    emit(VoiceListening());

    _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.toLowerCase().trim();
        if (words.isNotEmpty && !isClosed) {
          emit(VoiceResult(words));
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      // Change to 'en_US' if you want English only
      localeId: 'ar_EG',
    );
  }

  void stopListening() {
    _speech.stop();
    if (!isClosed) emit(VoiceIdle());
  }

  @override
  Future<void> close() {
    _speech.stop();
    return super.close();
  }
}