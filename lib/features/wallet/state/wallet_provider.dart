import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

import '../../../core/storage/local_storage.dart';

class WalletState {
  final double sol;
  final double usdc;
  final double pex;
  final double pexUsdValue;
  final double burnedPex;
  final double pexUsdRate;

  const WalletState({
    required this.sol,
    required this.usdc,
    required this.pex,
    required this.pexUsdValue,
    required this.burnedPex,
    required this.pexUsdRate,
  });

  factory WalletState.initial() {
    return const WalletState(
      sol: 12.45,
      usdc: 850.00,
      pex: 24850,
      pexUsdValue: 2485.00,
      burnedPex: 120430,
      pexUsdRate: 0.10,
    );
  }

  factory WalletState.fromJson(Map<String, dynamic> json) {
    final pex = (json['PEX'] as num?)?.toDouble() ?? 24850;
    final pexUsdRate = (json['pexUsdRate'] as num?)?.toDouble() ?? 0.10;

    return WalletState(
      sol: (json['sol'] as num?)?.toDouble() ?? 12.45,
      usdc: (json['usdc'] as num?)?.toDouble() ?? 850.00,
      pex: pex,
      pexUsdValue:
          (json['pexUsdValue'] as num?)?.toDouble() ?? pex * pexUsdRate,
      burnedPex: (json['burnedPex'] as num?)?.toDouble() ?? 120430,
      pexUsdRate: pexUsdRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sol': sol,
      'usdc': usdc,
      'PEX': pex,
      'pexUsdValue': pexUsdValue,
      'burnedPex': burnedPex,
      'pexUsdRate': pexUsdRate,
    };
  }

  WalletState copyWith({
    double? sol,
    double? usdc,
    double? pex,
    double? pexUsdValue,
    double? burnedPex,
    double? pexUsdRate,
  }) {
    return WalletState(
      sol: sol ?? this.sol,
      usdc: usdc ?? this.usdc,
      pex: pex ?? this.pex,
      pexUsdValue: pexUsdValue ?? this.pexUsdValue,
      burnedPex: burnedPex ?? this.burnedPex,
      pexUsdRate: pexUsdRate ?? this.pexUsdRate,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  static const String _storageKey = 'pera_x_wallet_state';

  WalletNotifier() : super(_loadInitialState());

  static WalletState _loadInitialState() {
    final raw = LocalStorage.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return WalletState.initial();
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) {
        return WalletState.fromJson(decoded);
      }

      return WalletState.initial();
    } catch (_) {
      return WalletState.initial();
    }
  }

  Future<void> _persist() async {
    await LocalStorage.setString(_storageKey, jsonEncode(state.toJson()));
  }

  void _update(WalletState newState) {
    state = newState;
    _persist();
  }

  /// Temporary frontend demo rate:
  /// 1 SOL = 2,000 PEX.
  /// Later this will come from Meteora / backend quote API.
  double get solToPexRate => 2000;

  void burnPex(double amount) {
    if (amount <= 0) return;

    final safeAmount = amount > state.pex ? state.pex : amount;
    final newPex = state.pex - safeAmount;

    _update(
      state.copyWith(
        pex: newPex,
        pexUsdValue: newPex * state.pexUsdRate,
        burnedPex: state.burnedPex + safeAmount,
      ),
    );
  }

  void addPexFromSwap({required double solAmount, required double pexAmount}) {
    if (solAmount <= 0 || pexAmount <= 0) return;
    if (state.sol < solAmount) return;

    final newSol = state.sol - solAmount;
    final newPex = state.pex + pexAmount;

    _update(
      state.copyWith(
        sol: newSol,
        pex: newPex,
        pexUsdValue: newPex * state.pexUsdRate,
      ),
    );
  }

  void swapSolToPex(double solAmount) {
    if (solAmount <= 0) return;
    if (state.sol < solAmount) return;

    final pexAmount = solAmount * solToPexRate;
    final newSol = state.sol - solAmount;
    final newPex = state.pex + pexAmount;

    _update(
      state.copyWith(
        sol: newSol,
        pex: newPex,
        pexUsdValue: newPex * state.pexUsdRate,
      ),
    );
  }

  void swapPexToSol(double pexAmount) {
    if (pexAmount <= 0) return;
    if (state.pex < pexAmount) return;

    final solAmount = pexAmount / solToPexRate;
    final newSol = state.sol + solAmount;
    final newPex = state.pex - pexAmount;

    _update(
      state.copyWith(
        sol: newSol,
        pex: newPex,
        pexUsdValue: newPex * state.pexUsdRate,
      ),
    );
  }

  void addUsdc(double amount) {
    if (amount <= 0) return;

    _update(state.copyWith(usdc: state.usdc + amount));
  }

  void deductUsdc(double amount) {
    if (amount <= 0) return;

    final safeAmount = amount > state.usdc ? state.usdc : amount;

    _update(state.copyWith(usdc: state.usdc - safeAmount));
  }

  Future<void> resetWallet() async {
    state = WalletState.initial();
    await LocalStorage.remove(_storageKey);
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier();
});
