import 'package:flutter/material.dart';

import '../../../app/theme.dart';

enum PaymentMethodType {
  pexToken,
  stablecoin,
  card,
  virtualAccountNg,
}

extension PaymentMethodTypeX on PaymentMethodType {
  String get title {
    switch (this) {
      case PaymentMethodType.pexToken:
        return 'Pera-X Token';
      case PaymentMethodType.stablecoin:
        return 'Stablecoin';
      case PaymentMethodType.card:
        return 'Card Payment';
      case PaymentMethodType.virtualAccountNg:
        return 'Bank Transfer / VA';
    }
  }

  String get subtitle {
    switch (this) {
      case PaymentMethodType.pexToken:
        return 'Best discount, wallet confirmation, burn impact later.';
      case PaymentMethodType.stablecoin:
        return 'Pay with USDT/USDC and receive service after confirmation.';
      case PaymentMethodType.card:
        return 'Use debit/credit card through provider checkout.';
      case PaymentMethodType.virtualAccountNg:
        return 'Nigeria only. Generate a virtual account for exact payment.';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.pexToken:
        return Icons.token_outlined;
      case PaymentMethodType.stablecoin:
        return Icons.currency_exchange_outlined;
      case PaymentMethodType.card:
        return Icons.credit_card_outlined;
      case PaymentMethodType.virtualAccountNg:
        return Icons.account_balance_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case PaymentMethodType.pexToken:
        return PeraXColors.cyan;
      case PaymentMethodType.stablecoin:
        return const Color(0xFF7CFFB2);
      case PaymentMethodType.card:
        return const Color(0xFFFFD166);
      case PaymentMethodType.virtualAccountNg:
        return const Color(0xFF9DB7FF);
    }
  }

  bool get earnsPexDiscount => this == PaymentMethodType.pexToken;

  bool get isNigeriaOnly => this == PaymentMethodType.virtualAccountNg;
}

List<PaymentMethodType> availablePaymentMethods({required String countryCode}) {
  final isNigeria = countryCode.toUpperCase() == 'NG';

  return [
    PaymentMethodType.pexToken,
    PaymentMethodType.stablecoin,
    PaymentMethodType.card,
    if (isNigeria) PaymentMethodType.virtualAccountNg,
  ];
}
