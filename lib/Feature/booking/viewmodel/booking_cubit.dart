import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/booking_model.dart';
import '../models/booking_payment_model.dart';
import '../services/booking_service.dart';
import 'booking_state.dart';

// This cubit manages booking creation and post-checkout status polling.
class BookingCubit extends Cubit<BookingState> {
  final BookingService _bookingService;

  BookingCubit(this._bookingService) : super(BookingInitial());

  static const int _maxStatusChecks = 10;
  static const Duration _statusCheckDelay = Duration(seconds: 3);

  // ✅ Updated:
  // This token cancels any previous polling work when a newer status flow starts.
  int _statusRequestToken = 0;

  // This method creates a booking session for card, wallet, or cash.
  Future<void> createBookingSession({
    required String serviceId,
    required String institutionId,
    required DateTime requestedDate,
    required String requestedTime,
    required String paymentMethod,
    String? notes,
  }) async {
    emit(BookingLoading());

    try {
      final data = await _bookingService.createBookingSession(
        serviceId: serviceId,
        institutionId: institutionId,
        requestedDate: requestedDate,
        requestedTime: requestedTime,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      final requiresRedirect = data['requires_redirect'] == true;

      if (requiresRedirect) {
        emit(
          BookingSessionCreated(
            bookingId: data['booking_id'] as String,
            checkoutUrl: data['checkout_url'] as String,
            paymentMethod: paymentMethod,
            message: (data['message'] as String?) ??
                'Booking session created successfully.',
          ),
        );
        return;
      }

      final bookingMap = Map<String, dynamic>.from(data['booking'] as Map);
      final paymentMap = Map<String, dynamic>.from(data['payment'] as Map);

      final booking = BookingModel.fromJson(bookingMap);
      final payment = BookingPaymentModel.fromJson(paymentMap);

      if (booking.bookingStatus.toLowerCase() == 'confirmed') {
        emit(
          BookingConfirmed(
            booking: booking,
            payment: payment,
          ),
        );
      } else {
        emit(
          BookingFailed(
            errorMessage: 'Booking was not confirmed.',
            booking: booking,
            payment: payment,
          ),
        );
      }
    } catch (e) {
      emit(
        BookingError(
          errorMessage: e.toString(),
        ),
      );
    }
  }

  String _resolvePaymentStatus(
      BookingModel? booking,
      BookingPaymentModel? payment,
      ) {
    return (payment?.paymentStatus ?? booking?.paymentStatus ?? '').toLowerCase();
  }

  bool _isConfirmed(BookingModel? booking) {
    return booking?.bookingStatus.toLowerCase() == 'confirmed';
  }

  bool _isFailed(
      BookingModel? booking,
      BookingPaymentModel? payment,
      ) {
    final bookingStatus = booking?.bookingStatus.toLowerCase();
    final paymentStatus = _resolvePaymentStatus(booking, payment);

    return bookingStatus == 'failed' ||
        bookingStatus == 'cancelled' ||
        paymentStatus == 'failed';
  }

  bool _isPending(
      BookingModel? booking,
      BookingPaymentModel? payment,
      ) {
    final bookingStatus = booking?.bookingStatus.toLowerCase();
    final paymentStatus = _resolvePaymentStatus(booking, payment);

    return bookingStatus == 'pending_payment' || paymentStatus == 'pending';
  }

  // ✅ Updated:
  // Poll the booking snapshot several times after returning from Paymob.
  Future<void> waitForFinalBookingStatus(String bookingId) async {
    final requestToken = ++_statusRequestToken;

    emit(BookingProcessing(bookingId: bookingId));

    for (var attempt = 0; attempt < _maxStatusChecks; attempt++) {
      if (requestToken != _statusRequestToken) return;

      try {
        final snapshot = await _bookingService.getBookingSnapshot(bookingId);

        if (requestToken != _statusRequestToken) return;

        final booking = snapshot['booking'] as BookingModel?;
        final payment = snapshot['payment'] as BookingPaymentModel?;

        if (_isConfirmed(booking)) {
          emit(
            BookingConfirmed(
              booking: booking!,
              payment: payment,
            ),
          );
          return;
        }

        if (_isFailed(booking, payment)) {
          emit(
            BookingFailed(
              errorMessage: 'Payment was not completed.',
              booking: booking,
              payment: payment,
            ),
          );
          return;
        }
      } catch (e) {
        if (attempt == _maxStatusChecks - 1) {
          if (requestToken != _statusRequestToken) return;

          emit(
            BookingError(
              errorMessage: 'Could not verify your payment status right now.',
            ),
          );
          return;
        }
      }

      if (attempt < _maxStatusChecks - 1) {
        await Future.delayed(_statusCheckDelay);
      }
    }

    if (requestToken != _statusRequestToken) return;

    try {
      final snapshot = await _bookingService.getBookingSnapshot(bookingId);

      if (requestToken != _statusRequestToken) return;

      final booking = snapshot['booking'] as BookingModel?;
      final payment = snapshot['payment'] as BookingPaymentModel?;

      if (booking == null) {
        emit(
          BookingError(
            errorMessage: 'Could not load booking status right now.',
          ),
        );
        return;
      }

      emit(
        BookingPendingResult(
          bookingId: bookingId,
          message: 'Payment status is still being processed.',
          booking: booking,
          payment: payment,
        ),
      );
    } catch (_) {
      if (requestToken != _statusRequestToken) return;

      emit(
        BookingError(
          errorMessage: 'Could not load booking status right now.',
        ),
      );
    }
  }

  // ✅ Updated:
  // This method is called when the app resumes from the external Paymob checkout.
  // If the booking is still pending after a very short grace period,
  // we treat this as an abandoned checkout and fail it immediately.
  Future<void> resolveCheckoutReturnAfterExternalCheckout(String bookingId) async {
    final requestToken = ++_statusRequestToken;

    try {
      final firstSnapshot = await _bookingService.getBookingSnapshot(bookingId);

      if (requestToken != _statusRequestToken) return;

      final firstBooking = firstSnapshot['booking'] as BookingModel?;
      final firstPayment = firstSnapshot['payment'] as BookingPaymentModel?;

      if (_isConfirmed(firstBooking)) {
        emit(
          BookingConfirmed(
            booking: firstBooking!,
            payment: firstPayment,
          ),
        );
        return;
      }

      if (_isFailed(firstBooking, firstPayment)) {
        emit(
          BookingFailed(
            errorMessage: 'Payment was not completed.',
            booking: firstBooking,
            payment: firstPayment,
          ),
        );
        return;
      }

      if (_isPending(firstBooking, firstPayment)) {
        // ✅ Updated:
        // Give the processed callback a very small grace period in case
        // a real success is landing at the same moment the user returns.
        await Future.delayed(const Duration(milliseconds: 900));

        if (requestToken != _statusRequestToken) return;

        final secondSnapshot = await _bookingService.getBookingSnapshot(bookingId);

        if (requestToken != _statusRequestToken) return;

        final secondBooking = secondSnapshot['booking'] as BookingModel?;
        final secondPayment = secondSnapshot['payment'] as BookingPaymentModel?;

        if (_isConfirmed(secondBooking)) {
          emit(
            BookingConfirmed(
              booking: secondBooking!,
              payment: secondPayment,
            ),
          );
          return;
        }

        if (_isFailed(secondBooking, secondPayment)) {
          emit(
            BookingFailed(
              errorMessage: 'Payment was not completed.',
              booking: secondBooking,
              payment: secondPayment,
            ),
          );
          return;
        }

        if (_isPending(secondBooking, secondPayment)) {
          // ✅ Updated:
          // If the user returned from checkout and the booking is still pending,
          // mark it failed immediately so the user does not end on a pending result.
          await _bookingService.forceFailPendingBooking(bookingId);

          if (requestToken != _statusRequestToken) return;

          final failedSnapshot =
          await _bookingService.getBookingSnapshot(bookingId);

          if (requestToken != _statusRequestToken) return;

          final failedBooking = failedSnapshot['booking'] as BookingModel?;
          final failedPayment =
          failedSnapshot['payment'] as BookingPaymentModel?;

          emit(
            BookingFailed(
              errorMessage: 'Payment was not completed.',
              booking: failedBooking,
              payment: failedPayment,
            ),
          );
          return;
        }
      }

      // Fallback:
      await waitForFinalBookingStatus(bookingId);
    } catch (_) {
      if (requestToken != _statusRequestToken) return;

      // If anything goes wrong during resume handling, fall back to normal polling.
      await waitForFinalBookingStatus(bookingId);
    }
  }

  // Keep backward compatibility with older call sites.
  Future<void> loadBookingStatusOnce(String bookingId) async {
    await waitForFinalBookingStatus(bookingId);
  }
}