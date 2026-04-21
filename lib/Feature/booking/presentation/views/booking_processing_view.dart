import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/booking_cubit.dart';
import '../../viewmodel/booking_state.dart';

// This screen keeps checking the booking status after returning from checkout.
class BookingProcessingView extends StatefulWidget {
  final String bookingId;

  const BookingProcessingView({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingProcessingView> createState() => _BookingProcessingViewState();
}

class _BookingProcessingViewState extends State<BookingProcessingView>
    with WidgetsBindingObserver {
  bool _hasNavigated = false;

  // ✅ Updated:
  // This flag makes sure the abandon/fail-on-return logic runs only once
  // when the user comes back from the external Paymob checkout.
  bool _handledCheckoutReturn = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingCubit>().waitForFinalBookingStatus(widget.bookingId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Updated:
    // When the app resumes from the external checkout,
    // resolve the returned checkout state immediately.
    if (state == AppLifecycleState.resumed &&
        mounted &&
        !_hasNavigated &&
        !_handledCheckoutReturn) {
      _handledCheckoutReturn = true;

      context
          .read<BookingCubit>()
          .resolveCheckoutReturnAfterExternalCheckout(widget.bookingId);
    }
  }

  void _goToResult() {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;

    context.go(
      '/booking/result',
      extra: {
        'bookingId': widget.bookingId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingConfirmed ||
            state is BookingFailed ||
            state is BookingPendingResult ||
            state is BookingError) {
          _goToResult();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Processing',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Checking payment result...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Please wait while we verify your booking with Paymob and refresh the final booking status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
