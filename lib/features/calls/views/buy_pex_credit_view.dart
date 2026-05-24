import 'package:flutter/material.dart';

import '../data/call_service.dart';

class BuyPexCreditView extends StatefulWidget {
  const BuyPexCreditView({super.key});

  @override
  State<BuyPexCreditView> createState() => _BuyPexCreditViewState();
}

class _BuyPexCreditViewState extends State<BuyPexCreditView> {
  final CallService service = CallService();
  final TextEditingController amountController = TextEditingController();

  bool isLoading = true;
  bool isSubmitting = false;

  int selectedPackageIndex = 0;
  String selectedPaymentMethod = '';
  double pexBalance = 0.00;

  List<Map<String, dynamic>> packages = [];
  List<String> paymentMethods = [];

  Map<String, dynamic>? get selectedPackage {
    if (packages.isEmpty) return null;
    return packages[selectedPackageIndex];
  }

  @override
  void initState() {
    super.initState();
    loadTopUpData();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> loadTopUpData() async {
    final loadedBalance = await service.getPexBalance();
    final loadedPackages = await service.getPexPackages();
    final loadedPaymentMethods = await service.getPaymentMethods();

    if (!mounted) return;

    setState(() {
      pexBalance = loadedBalance;
      packages = loadedPackages;
      paymentMethods = loadedPaymentMethods;

      if (packages.isNotEmpty) {
        selectedPackageIndex = packages.length > 1 ? 1 : 0;
        amountController.text = packages[selectedPackageIndex]['pex']
            .toString();
      }

      if (paymentMethods.isNotEmpty) {
        selectedPaymentMethod = paymentMethods.first;
      }

      isLoading = false;
    });
  }

  void selectPackage(int index) {
    setState(() {
      selectedPackageIndex = index;
      amountController.text = packages[index]['pex'].toString();
    });
  }

  Future<void> confirmTopUp() async {
    final amountText = amountController.text.trim();
    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid PEX amount.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No payment method is available yet.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final success = await service.createTopUpRequest(
      pexAmount: amount,
      paymentMethod: selectedPaymentMethod,
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Top-up request created for $amount PEX.'
              : 'Top-up is not available yet.',
        ),
        backgroundColor: success
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF020617),
              Color(0xFF071A35),
              Color(0xFF052E2B),
              Color(0xFF020617),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 22),
                      _buildHeroCard(),
                      const SizedBox(height: 22),
                      const Text(
                        'Choose Package',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPackageList(),
                      const SizedBox(height: 22),
                      _buildCustomAmount(),
                      const SizedBox(height: 22),
                      _buildPaymentMethod(),
                      const SizedBox(height: 24),
                      _buildConfirmButton(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy PEX Credit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Top up your call credit balance',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF123D5A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.token_rounded, color: Color(0xFF38BDF8)),
              SizedBox(width: 8),
              Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${pexBalance.toStringAsFixed(2)} PEX',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF5EEAD4).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Use PEX credits for local and international calls',
              style: TextStyle(
                color: Color(0xFF5EEAD4),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageList() {
    if (packages.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.inventory_2_rounded,
        title: 'No packages available',
        message: 'Preset credit packages will appear here when available.',
      );
    }

    return Column(
      children: List.generate(packages.length, (index) {
        final item = packages[index];
        final active = selectedPackageIndex == index;

        return InkWell(
          onTap: () => selectPackage(index),
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF07111F).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active
                    ? const Color(0xFF14B8A6).withValues(alpha: 0.65)
                    : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF14B8A6).withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: active ? const Color(0xFF5EEAD4) : Colors.white60,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${item['pex']} PEX',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF14B8A6,
                              ).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              item['tag'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF5EEAD4),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['price']} • ${item['bonus']}',
                        style: const TextStyle(
                          color: Color(0x80FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  active
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: active ? const Color(0xFF5EEAD4) : Colors.white24,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCustomAmount() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom PEX Amount',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: const TextStyle(color: Colors.white30),
              suffixText: 'PEX',
              suffixStyle: const TextStyle(
                color: Color(0xFF5EEAD4),
                fontWeight: FontWeight.w900,
              ),
              filled: true,
              fillColor: const Color(0xFF020617),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF14B8A6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (paymentMethods.isEmpty)
            const _EmptyPanel(
              icon: Icons.account_balance_wallet_rounded,
              title: 'No payment methods available',
              message: 'Payment options will appear here when available.',
            ),
          ...paymentMethods.map((method) {
            final active = selectedPaymentMethod == method;

            return InkWell(
              onTap: () {
                setState(() {
                  selectedPaymentMethod = method;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF14B8A6).withValues(alpha: 0.16)
                      : const Color(0xFF020617),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active
                        ? const Color(0xFF14B8A6).withValues(alpha: 0.55)
                        : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _paymentIcon(method),
                      color: active ? const Color(0xFF5EEAD4) : Colors.white54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        method,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      active
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: active ? const Color(0xFF5EEAD4) : Colors.white24,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _paymentIcon(String method) {
    return Icons.payments_rounded;
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : confirmTopUp,
        icon: isSubmitting
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_card_rounded),
        label: Text(isSubmitting ? 'Processing...' : 'Confirm Top-Up'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF14B8A6),
          disabledBackgroundColor: const Color(
            0xFF14B8A6,
          ).withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white38, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
