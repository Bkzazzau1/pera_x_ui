import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/state/service_providers.dart';
import '../../app/state/transaction_provider.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import 'state/wallet_provider.dart';

class WalletView extends ConsumerStatefulWidget {
  const WalletView({super.key});

  @override
  ConsumerState<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends ConsumerState<WalletView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kineticController;

  @override
  void initState() {
    super.initState();

    _kineticController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _kineticController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final transactions = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        children: [
          const _CommandHeader(),
          const SizedBox(height: 28),
          _AssetList(wallet: wallet, kineticAnimation: _kineticController),
          const SizedBox(height: 24),
          _LiquidBurnCard(
            burnedPex: wallet.burnedPex,
            kineticAnimation: _kineticController,
          ),
          const SizedBox(height: 24),
          const _SwapCard(),
          const SizedBox(height: 24),
          _NeuralTransactionPreview(transactions: transactions),
        ],
      ),
    );
  }
}

class _CommandHeader extends StatelessWidget {
  const _CommandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Command Center',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: PeraXColors.cyan,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Real-time Pera-X Tokenomics',
              style: TextStyle(
                color: PeraXColors.cyan,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AssetList extends StatelessWidget {
  final WalletState wallet;
  final Animation<double> kineticAnimation;

  const _AssetList({required this.wallet, required this.kineticAnimation});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Institutional Assets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _KineticAssetTile(
            symbol: 'SOL',
            name: 'Solana L1',
            balance: wallet.sol.toStringAsFixed(2),
            value: '\$1,742.00',
            animation: kineticAnimation,
          ),
          const SizedBox(height: 12),
          _KineticAssetTile(
            symbol: 'PEX',
            name: 'Pera-X (Utility)',
            balance: wallet.pex.toStringAsFixed(0),
            value: '\$${wallet.pexUsdValue.toStringAsFixed(2)}',
            isPrimary: true,
            animation: kineticAnimation,
          ),
        ],
      ),
    );
  }
}

class _KineticAssetTile extends StatelessWidget {
  final String symbol;
  final String name;
  final String balance;
  final String value;
  final bool isPrimary;
  final Animation<double> animation;

  const _KineticAssetTile({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.value,
    this.isPrimary = false,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PeraXColors.surfaceBlue.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPrimary
                  ? PeraXColors.cyan.withValues(
                      alpha: 0.1 + (animation.value * 0.3),
                    )
                  : Colors.white.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isPrimary
                    ? PeraXColors.cyan
                    : PeraXColors.darkBlue,
                radius: 20,
                child: Text(
                  symbol[0],
                  style: TextStyle(
                    color: isPrimary ? PeraXColors.darkBlue : PeraXColors.cyan,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balance,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: PeraXColors.cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiquidBurnCard extends StatelessWidget {
  final double burnedPex;
  final Animation<double> kineticAnimation;

  const _LiquidBurnCard({
    required this.burnedPex,
    required this.kineticAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supply Liquidation (Burn)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: PeraXColors.darkBlue.withValues(alpha: 0.5),
              border: Border.all(color: PeraXColors.glassBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: kineticAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _LiquidPainter(
                            fillLevel: 0.7 - (burnedPex / 1000000),
                            waveAnim: kineticAnimation.value,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Network Equilibrium',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        Text(
                          '${(10000000 - burnedPex).toInt()} PEX',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.whatshot,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'BURNED: ${burnedPex.toInt()} PEX',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double fillLevel;
  final double waveAnim;

  _LiquidPainter({required this.fillLevel, required this.waveAnim});

  @override
  void paint(Canvas canvas, Size size) {
    final safeFillLevel = fillLevel.clamp(0.05, 0.95);
    final paint = Paint()..color = PeraXColors.cyan.withValues(alpha: 0.15);
    final path = Path();
    final y = size.height * (1 - safeFillLevel);

    path.moveTo(0, y);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, y + (8 * waveAnim * (i % 40 == 0 ? 1 : -1)));
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SwapCard extends ConsumerStatefulWidget {
  const _SwapCard();

  @override
  ConsumerState<_SwapCard> createState() => _SwapCardState();
}

class _SwapCardState extends ConsumerState<_SwapCard> {
  final TextEditingController _amountController = TextEditingController(
    text: '1',
  );

  bool solToPex = true;
  bool isSwapping = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get inputAmount {
    return double.tryParse(_amountController.text.trim()) ?? 0;
  }

  double get outputAmount {
    if (inputAmount <= 0) return 0;

    final rate = ref.read(walletProvider.notifier).solToPexRate;

    if (solToPex) {
      return inputAmount * rate;
    }

    return inputAmount / rate;
  }

  String get fromAsset => solToPex ? 'SOL' : 'PEX';

  String get toAsset => solToPex ? 'PEX' : 'SOL';

  bool _canSwap(WalletState wallet) {
    if (inputAmount <= 0) return false;

    if (solToPex) {
      return wallet.sol >= inputAmount;
    }

    return wallet.pex >= inputAmount;
  }

  String _formatAmount(double value) {
    if (value <= 0) return '0';

    return value
        .toStringAsFixed(value % 1 == 0 ? 0 : 4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> _executeSwap() async {
    if (isSwapping) return;

    final wallet = ref.read(walletProvider);
    final amount = inputAmount;

    if (amount <= 0) {
      _showSnack('Enter a valid swap amount.');
      return;
    }

    if (!_canSwap(wallet)) {
      _showSnack('Insufficient $fromAsset balance.');
      return;
    }

    setState(() => isSwapping = true);

    try {
      final walletService = ref.read(walletServiceProvider);

      await walletService.executeSwap(
        fromAsset: fromAsset,
        toAsset: toAsset,
        amount: amount,
      );

      if (!mounted) return;

      final calculatedOutput = outputAmount;

      if (solToPex) {
        ref.read(walletProvider.notifier).swapSolToPex(amount);

        ref
            .read(transactionProvider.notifier)
            .addSwap(solAmount: amount, pexAmount: calculatedOutput);
      } else {
        ref.read(walletProvider.notifier).swapPexToSol(amount);

        ref
            .read(transactionProvider.notifier)
            .addReverseSwap(pexAmount: amount, solAmount: calculatedOutput);
      }

      _showSnack(
        'Swap executed: ${_formatAmount(amount)} $fromAsset → ${_formatAmount(calculatedOutput)} $toAsset',
      );

      setState(() => isSwapping = false);
    } catch (error) {
      if (!mounted) return;

      setState(() => isSwapping = false);
      _showSnack(error.toString());
    }
  }

  void _toggleDirection() {
    if (isSwapping) return;

    setState(() {
      solToPex = !solToPex;
      _amountController.text = '1';
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final canSwap = _canSwap(wallet);

    return GlassCard(
      padding: const EdgeInsets.all(22),
      radius: 32,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hyper-Swap',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _SwapInput(
            label: 'From',
            asset: fromAsset,
            controller: _amountController,
            readOnly: isSwapping,
            onChanged: (_) => setState(() {}),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: GestureDetector(
              onTap: _toggleDirection,
              child: const Icon(
                Icons.swap_vert_circle,
                color: PeraXColors.cyan,
                size: 40,
              ),
            ),
          ),
          _SwapInput(
            label: 'To',
            asset: toAsset,
            amountText: _formatAmount(outputAmount),
            readOnly: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: canSwap && !isSwapping ? _executeSwap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: PeraXColors.cyan,
                disabledBackgroundColor: Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: isSwapping
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: PeraXColors.cyan,
                      ),
                    )
                  : Text(
                      canSwap ? 'EXECUTE SWAP' : 'INSUFFICIENT $fromAsset',
                      style: const TextStyle(
                        color: PeraXColors.darkBlue,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapInput extends StatelessWidget {
  final String label;
  final String asset;
  final String? amountText;
  final TextEditingController? controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const _SwapInput({
    required this.label,
    required this.asset,
    this.amountText,
    this.controller,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PeraXColors.darkBlue.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PeraXColors.glassBorder),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (readOnly && controller == null)
            Text(
              amountText ?? '0',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            )
          else
            SizedBox(
              width: 100,
              child: TextField(
                controller: controller,
                enabled: !readOnly,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: onChanged,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          const SizedBox(width: 12),
          Text(
            asset,
            style: const TextStyle(
              color: PeraXColors.cyan,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NeuralTransactionPreview extends StatelessWidget {
  final List<AppTransaction> transactions;

  const _NeuralTransactionPreview({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Neural Log',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...transactions.map(
            (tx) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PeraXColors.surfaceBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.data_exploration,
                      color: PeraXColors.cyan,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          tx.subtitle,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    tx.amount,
                    style: const TextStyle(
                      color: PeraXColors.cyan,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
