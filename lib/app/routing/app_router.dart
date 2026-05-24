import 'package:go_router/go_router.dart';

import '../../features/ai_lab/ai_lab_view.dart';
import '../../features/calls/routes/call_routes.dart';
import '../../features/calls/views/active_call_view.dart';
import '../../features/calls/views/buy_international_number_view.dart';
import '../../features/calls/views/buy_pex_credit_view.dart';
import '../../features/calls/views/call_history_view.dart';
import '../../features/calls/views/call_receipt_view.dart';
import '../../features/calls/views/call_settings_view.dart';
import '../../features/calls/views/pera_x_call_view.dart';
import '../../features/checkout/checkout_view.dart';
import '../../features/dashboard/dashboard_view.dart';
import '../../features/market/market_view.dart';
import '../../features/wallet/wallet_view.dart';
import '../../shared/layout/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardView(),
        ),
        GoRoute(
          path: '/ai-lab',
          builder: (context, state) => const AiLabView(),
        ),
        GoRoute(
          path: CallRoutes.callHome,
          builder: (context, state) => const PeraXCallView(),
        ),
        GoRoute(
          path: CallRoutes.callHistory,
          builder: (context, state) => const CallHistoryView(),
        ),
        GoRoute(
          path: CallRoutes.buyCredit,
          builder: (context, state) => const BuyPexCreditView(),
        ),
        GoRoute(
          path: CallRoutes.buyInternationalNumber,
          builder: (context, state) => const BuyInternationalNumberView(),
        ),
        GoRoute(
          path: CallRoutes.settings,
          builder: (context, state) => const CallSettingsView(),
        ),
        GoRoute(
          path: '/market',
          builder: (context, state) => const MarketView(),
        ),
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletView(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutView(),
        ),
      ],
    ),
    GoRoute(
      path: CallRoutes.activeCall,
      builder: (context, state) {
        final args = state.extra as ActiveCallArgs;

        return ActiveCallView(
          phoneNumber: args.phoneNumber,
          destination: args.destination,
          isInternational: args.isInternational,
          ratePerMinute: args.ratePerMinute,
        );
      },
    ),
    GoRoute(
      path: CallRoutes.callReceipt,
      builder: (context, state) {
        final args = state.extra as CallReceiptArgs;

        return CallReceiptView(
          phoneNumber: args.phoneNumber,
          destination: args.destination,
          duration: args.duration,
          charge: args.charge,
          isInternational: args.isInternational,
        );
      },
    ),
  ],
);
