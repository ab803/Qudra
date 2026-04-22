import 'package:flutter/material.dart';
import '../viewmodel/emergency_sos_activation_viewmodel.dart';
import '../widgets/emergency_sos_countdown_circle.dart';

class EmergencySosActivationView extends StatefulWidget {
  const EmergencySosActivationView({
    super.key,
    required this.viewModel,
    this.onCompleted,
  });

  final EmergencySosActivationViewModel viewModel;
  final Future<void> Function()? onCompleted;

  @override
  State<EmergencySosActivationView> createState() =>
      _EmergencySosActivationViewState();
}

class _EmergencySosActivationViewState
    extends State<EmergencySosActivationView> {
  bool _hasHandledCompletion = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.startCountdown();
    });
  }

  void _viewModelListener() {
    if (!mounted) return;
    if (_hasHandledCompletion) return;
    if (!widget.viewModel.isCompleted) return;

    _hasHandledCompletion = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.onCompleted != null) {
        await widget.onCompleted!();
      }
    });
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_viewModelListener);
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final vm = widget.viewModel;

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'تفعيل الاستغاثة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(
                          theme.brightness == Brightness.dark ? 0.14 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: colorScheme.error.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        'سيتم تفعيل حالة الطوارئ تلقائيًا بعد انتهاء العد التنازلي.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    EmergencySosCountdownCircle(
                      progress: vm.progress,
                      label: vm.countdownLabel,
                    ),
                    const SizedBox(height: 26),
                    Text(
                      vm.isCompleted
                          ? 'تم تفعيل حالة الطوارئ'
                          : 'سيتم التفعيل خلال ${vm.countdownNumber} ثوانٍ',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'يمكنك الإلغاء الآن إذا تم الضغط بالخطأ.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.68),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: vm.isCompleted
                            ? null
                            : () {
                          vm.cancelCountdown();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
