import 'package:flutter/material.dart';

import '../../../app/theme.dart';

enum OrderStatusStep {
  awaitingPayment,
  paymentConfirmed,
  processingService,
  delivered,
}

extension OrderStatusStepX on OrderStatusStep {
  String get title {
    switch (this) {
      case OrderStatusStep.awaitingPayment:
        return 'Awaiting Payment';
      case OrderStatusStep.paymentConfirmed:
        return 'Payment Confirmed';
      case OrderStatusStep.processingService:
        return 'Processing Service';
      case OrderStatusStep.delivered:
        return 'Service Delivered';
    }
  }

  String get description {
    switch (this) {
      case OrderStatusStep.awaitingPayment:
        return 'Waiting for user payment or provider confirmation.';
      case OrderStatusStep.paymentConfirmed:
        return 'Payment has been received and matched to the order reference.';
      case OrderStatusStep.processingService:
        return 'The utility gateway is processing the selected service.';
      case OrderStatusStep.delivered:
        return 'The service has been delivered and the receipt is ready.';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatusStep.awaitingPayment:
        return Icons.hourglass_top_rounded;
      case OrderStatusStep.paymentConfirmed:
        return Icons.verified_rounded;
      case OrderStatusStep.processingService:
        return Icons.settings_suggest_rounded;
      case OrderStatusStep.delivered:
        return Icons.done_all_rounded;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatusStep.awaitingPayment:
        return const Color(0xFFFFD166);
      case OrderStatusStep.paymentConfirmed:
        return PeraXColors.cyan;
      case OrderStatusStep.processingService:
        return const Color(0xFF9DB7FF);
      case OrderStatusStep.delivered:
        return const Color(0xFF7CFFB2);
    }
  }
}
