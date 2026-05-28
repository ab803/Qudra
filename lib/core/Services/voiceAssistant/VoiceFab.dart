// features/voice/widgets/voice_fab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/core/Services/voiceAssistant/VoiceCommandRouter.dart';
import 'package:qudra_0/core/Services/voiceAssistant/voice_cubit.dart';

class VoiceFAB extends StatelessWidget {
  const VoiceFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VoiceCubit(),
      child: BlocConsumer<VoiceCubit, VoiceState>(
        listener: (context, state) async {
          if (state is VoiceResult && state.isFinal) {
            final handled = VoiceCommandRouter.handle(state.words, context);

            await context.read<VoiceCubit>().stopListening();

            if (!handled && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Command not recognized: ${state.words}'),
                ),
              );
            }
          } else if (state is VoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voice error: ${state.message}')),
            );

            debugPrint('Voice error: ${state.message}');
          }
        },
        builder: (context, state) {
          final isListening = state is VoiceListening;

          return FloatingActionButton(
            onPressed: () {
              final locale = Localizations.localeOf(context);
              final voiceLocaleId =
              locale.languageCode == 'ar' ? 'ar_EG' : 'en_US';

              context.read<VoiceCubit>().toggleListening(
                localeId: voiceLocaleId,
              );
            },
            backgroundColor: isListening ? Colors.red : null,
            tooltip: isListening ? 'Stop' : 'Voice Command',
            child: Icon(isListening ? Icons.mic : Icons.mic_none),
          );
        },
      ),
    );
  }
}
