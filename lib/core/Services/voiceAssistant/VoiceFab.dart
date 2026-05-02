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
      create: (_) => VoiceCubit(), // or getIt<VoiceCubit>() if singleton
      child: BlocConsumer<VoiceCubit, VoiceState>(
        listener: (context, state) {
          if (state is VoiceResult) {
            VoiceCommandRouter.handle(state.words, context);

            context.read<VoiceCubit>().stopListening();
          } else if (state is VoiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Voice error: ${state.message}')),
            );
            print("voice error" + state.message );
          }
        },
        builder: (context, state) {
          final isListening = state is VoiceListening;
          return FloatingActionButton(
            onPressed: () => context.read<VoiceCubit>().toggleListening(),
            backgroundColor: isListening ? Colors.red : null,
            tooltip: isListening ? 'Stop' : 'Voice Command',
            child: Icon(isListening ? Icons.mic : Icons.mic_none),
          );
        },
      ),
    );
  }
}