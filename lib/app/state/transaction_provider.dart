import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/storage/local_storage.dart';

enum TransactionType { aiPrompt, marketPurchase, burn, swap, topUp, checkout }

class AppTransaction {
  final String id;
  final TransactionType type;
  final String title;
  final String subtitle;
  final String amount;
  final DateTime createdAt;
  final String? solscanHash;

  const AppTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.createdAt,
    this.solscanHash,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id']?.toString() ?? '',
      type: _transactionTypeFromString(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      solscanHash: json['solscanHash']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'solscanHash': solscanHash,
    };
  }

  static TransactionType _transactionTypeFromString(String? value) {
    switch (value) {
      case 'aiPrompt':
        return TransactionType.aiPrompt;
      case 'marketPurchase':
        return TransactionType.marketPurchase;
      case 'burn':
        return TransactionType.burn;
      case 'swap':
        return TransactionType.swap;
      case 'topUp':
        return TransactionType.topUp;
      case 'checkout':
        return TransactionType.checkout;
      default:
        return TransactionType.checkout;
    }
  }

  bool get isBurn => type == TransactionType.burn;
  bool get isAiPrompt => type == TransactionType.aiPrompt;
  bool get isSwap => type == TransactionType.swap;
  bool get isPurchase => type == TransactionType.marketPurchase;
  bool get isTopUp => type == TransactionType.topUp;
  bool get isCheckout => type == TransactionType.checkout;

  String get activityIcon {
    switch (type) {
      case TransactionType.aiPrompt:
        return '🤖';
      case TransactionType.marketPurchase:
        return '🛒';
      case TransactionType.burn:
        return '🔥';
      case TransactionType.swap:
        return '🔁';
      case TransactionType.topUp:
        return '💳';
      case TransactionType.checkout:
        return '✅';
    }
  }

  String get activityMessage {
    switch (type) {
      case TransactionType.aiPrompt:
        return '$activityIcon ${amount.replaceFirst('-', '')} used for $subtitle AI request.';
      case TransactionType.marketPurchase:
        return '$activityIcon $subtitle purchased successfully.';
      case TransactionType.burn:
        return '$activityIcon ${amount.replaceFirst('-', '')} burned from $subtitle.';
      case TransactionType.swap:
        return '$activityIcon $subtitle completed.';
      case TransactionType.topUp:
        return '$activityIcon Wallet topped up: $amount.';
      case TransactionType.checkout:
        return '$activityIcon Checkout completed: $subtitle.';
    }
  }
}

class TransactionNotifier extends StateNotifier<List<AppTransaction>> {
  static const String _storageKey = 'pera_x_transactions';

  TransactionNotifier() : super(_loadInitialTransactions());

  static List<AppTransaction> _demoTransactions() {
    return [
      AppTransaction(
        id: 'tx_ai_001',
        type: TransactionType.aiPrompt,
        title: 'AI Prompt',
        subtitle: 'AI Detector request',
        amount: '-4 PEX',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        solscanHash: 'demo_ai_hash_001',
      ),
      AppTransaction(
        id: 'tx_burn_001',
        type: TransactionType.burn,
        title: 'Token Burn',
        subtitle: 'AI Detector document request',
        amount: '-4 PEX',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        solscanHash: 'demo_burn_ai_hash_001',
      ),
      AppTransaction(
        id: 'tx_purchase_001',
        type: TransactionType.marketPurchase,
        title: 'Service Credit Conversion',
        subtitle: 'Call Credit Pack',
        amount: '-20 PEX',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        solscanHash: 'demo_purchase_hash_001',
      ),
      AppTransaction(
        id: 'tx_burn_002',
        type: TransactionType.burn,
        title: 'Token Burn',
        subtitle: 'Call Credit Pack activation',
        amount: '-20 PEX',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        solscanHash: 'demo_burn_purchase_hash_001',
      ),
      AppTransaction(
        id: 'tx_swap_001',
        type: TransactionType.swap,
        title: 'Token Swap',
        subtitle: 'SOL → PEX Swap',
        amount: '+1,500 PEX',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        solscanHash: 'demo_swap_hash_001',
      ),
    ];
  }

  static List<AppTransaction> _loadInitialTransactions() {
    final raw = LocalStorage.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return _demoTransactions();
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(AppTransaction.fromJson)
            .toList();
      }

      return _demoTransactions();
    } catch (_) {
      return _demoTransactions();
    }
  }

  Future<void> _persist() async {
    final data = state.map((transaction) => transaction.toJson()).toList();

    await LocalStorage.setString(_storageKey, jsonEncode(data));
  }

  String _newId(String prefix) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _newDemoHash(String prefix) {
    return 'demo_${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }

  void addTransaction(AppTransaction transaction) {
    state = [transaction, ...state];
    _persist();
  }

  void addSwap({required double solAmount, required double pexAmount}) {
    addTransaction(
      AppTransaction(
        id: _newId('tx_swap'),
        type: TransactionType.swap,
        title: 'Token Swap',
        subtitle:
            '${solAmount.toStringAsFixed(2)} SOL → ${pexAmount.toStringAsFixed(0)} PEX',
        amount: '+${pexAmount.toStringAsFixed(0)} PEX',
        createdAt: DateTime.now(),
        solscanHash: _newDemoHash('swap'),
      ),
    );
  }

  void addReverseSwap({required double pexAmount, required double solAmount}) {
    addTransaction(
      AppTransaction(
        id: _newId('tx_swap'),
        type: TransactionType.swap,
        title: 'Token Swap',
        subtitle:
            '${pexAmount.toStringAsFixed(0)} PEX → ${solAmount.toStringAsFixed(4)} SOL',
        amount: '+${solAmount.toStringAsFixed(4)} SOL',
        createdAt: DateTime.now(),
        solscanHash: _newDemoHash('reverse_swap'),
      ),
    );
  }

  void addPurchase({
    required String productName,
    required double amountUsd,
    required bool paidWithPex,
  }) {
    addTransaction(
      AppTransaction(
        id: _newId('tx_purchase'),
        type: TransactionType.marketPurchase,
        title: 'Service Credit Conversion',
        subtitle: productName,
        amount: paidWithPex
            ? '-\$${amountUsd.toStringAsFixed(2)} with PEX'
            : '-\$${amountUsd.toStringAsFixed(2)}',
        createdAt: DateTime.now(),
        solscanHash: _newDemoHash('purchase'),
      ),
    );
  }

  void addCheckout({
    required String productName,
    required double amountUsd,
    required bool paidWithPex,
  }) {
    addTransaction(
      AppTransaction(
        id: _newId('tx_checkout'),
        type: TransactionType.checkout,
        title: 'Checkout',
        subtitle: paidWithPex
            ? '$productName paid with PEX'
            : '$productName paid with standard checkout',
        amount: '-\$${amountUsd.toStringAsFixed(2)}',
        createdAt: DateTime.now(),
        solscanHash: _newDemoHash('checkout'),
      ),
    );
  }

  void addBurn({required String reason, required double pexAmount}) {
    if (pexAmount <= 0) return;

    addTransaction(
      AppTransaction(
        id: _newId('tx_burn'),
        type: TransactionType.burn,
        title: 'Token Burn',
        subtitle: reason,
        amount: '-${pexAmount.toStringAsFixed(0)} PEX',
        createdAt: DateTime.now(),
        solscanHash: _newDemoHash('burn'),
      ),
    );
  }

  void addAiPrompt({required String model, required double pexCost}) {
    if (pexCost <= 0) return;

    addTransaction(
      AppTransaction(
        id: _newId('tx_ai'),
        type: TransactionType.aiPrompt,
        title: 'AI Prompt',
        subtitle: '$model request',
        amount: '-${pexCost.toStringAsFixed(0)} PEX',
        createdAt: DateTime.now(),
        solscanHash: _newDemoHash('ai'),
      ),
    );
  }

  void addAiBurn({required String model, required double pexAmount}) {
    addBurn(reason: '$model AI request', pexAmount: pexAmount);
  }

  void addTopUp({required String method, required double pexAmount}) {
    if (pexAmount <= 0) return;

    addTransaction(
      AppTransaction(
        id: _newId('tx_topup'),
        type: TransactionType.topUp,
        title: 'Wallet Top Up',
        subtitle: method,
        amount: '+${pexAmount.toStringAsFixed(0)} PEX',
        createdAt: DateTime.now(),
        solscanHash: _newDemoHash('topup'),
      ),
    );
  }

  Future<void> clearTransactions() async {
    state = _demoTransactions();
    await LocalStorage.remove(_storageKey);
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<AppTransaction>>((ref) {
      return TransactionNotifier();
    });

final recentTransactionsProvider = Provider<List<AppTransaction>>((ref) {
  final transactions = ref.watch(transactionProvider);
  return transactions.take(8).toList();
});

final latestActivityProvider = Provider<AppTransaction?>((ref) {
  final transactions = ref.watch(transactionProvider);

  if (transactions.isEmpty) return null;

  return transactions.first;
});

final latestBurnProvider = Provider<AppTransaction?>((ref) {
  final transactions = ref.watch(transactionProvider);

  for (final transaction in transactions) {
    if (transaction.isBurn) {
      return transaction;
    }
  }

  return null;
});

final latestAiUsageProvider = Provider<AppTransaction?>((ref) {
  final transactions = ref.watch(transactionProvider);

  for (final transaction in transactions) {
    if (transaction.isAiPrompt) {
      return transaction;
    }
  }

  return null;
});

final todayBurnedPexProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();

  double total = 0;

  for (final transaction in transactions) {
    final isToday =
        transaction.createdAt.year == now.year &&
        transaction.createdAt.month == now.month &&
        transaction.createdAt.day == now.day;

    if (!isToday || !transaction.isBurn) continue;

    final numericAmount = transaction.amount
        .replaceAll('-', '')
        .replaceAll('+', '')
        .replaceAll('PEX', '')
        .replaceAll(',', '')
        .trim();

    total += double.tryParse(numericAmount) ?? 0;
  }

  return total;
});

final todayAiSpendProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();

  double total = 0;

  for (final transaction in transactions) {
    final isToday =
        transaction.createdAt.year == now.year &&
        transaction.createdAt.month == now.month &&
        transaction.createdAt.day == now.day;

    if (!isToday || !transaction.isAiPrompt) continue;

    final numericAmount = transaction.amount
        .replaceAll('-', '')
        .replaceAll('+', '')
        .replaceAll('PEX', '')
        .replaceAll(',', '')
        .trim();

    total += double.tryParse(numericAmount) ?? 0;
  }

  return total;
});

final utilityScoreProvider = Provider<int>((ref) {
  final transactions = ref.watch(transactionProvider);
  final todayBurned = ref.watch(todayBurnedPexProvider);
  final todayAiSpend = ref.watch(todayAiSpendProvider);

  final activityScore = transactions.length * 4;
  final burnScore = todayBurned * 1.2;
  final aiScore = todayAiSpend * 2;

  final score = (activityScore + burnScore + aiScore).round();

  if (score > 100) return 100;
  if (score < 0) return 0;

  return score;
});
