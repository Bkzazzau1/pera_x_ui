import 'package:flutter/material.dart';

import '../data/call_service.dart';
import '../models/international_number_model.dart';

class BuyInternationalNumberView extends StatefulWidget {
  const BuyInternationalNumberView({super.key});

  @override
  State<BuyInternationalNumberView> createState() =>
      _BuyInternationalNumberViewState();
}

class _BuyInternationalNumberViewState
    extends State<BuyInternationalNumberView> {
  final CallService service = CallService();

  bool isLoading = true;
  bool isSubmitting = false;
  int selectedNumberIndex = 0;
  String selectedPlan = 'Monthly';
  double creditBalance = 0;
  List<InternationalNumberModel> numbers = [];

  InternationalNumberModel? get selectedNumber {
    if (numbers.isEmpty) return null;
    return numbers[selectedNumberIndex];
  }

  double get totalDue {
    final number = selectedNumber;
    if (number == null) return 0;
    final multiplier = selectedPlan == 'Annual' ? 10 : 1;
    return number.setupFeeCredit + (number.monthlyFeeCredit * multiplier);
  }

  @override
  void initState() {
    super.initState();
    loadNumbers();
  }

  Future<void> loadNumbers() async {
    final loadedBalance = await service.getCreditBalance();
    final loadedNumbers = await service.getInternationalNumbers();

    if (!mounted) return;

    setState(() {
      creditBalance = loadedBalance;
      numbers = loadedNumbers;
      final popularIndex = numbers.indexWhere((number) => number.popular);
      selectedNumberIndex = popularIndex == -1 ? 0 : popularIndex;
      isLoading = false;
    });
  }

  Future<void> confirmPurchase() async {
    final number = selectedNumber;
    if (number == null) return;

    if (creditBalance < totalDue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient Credits for this number package.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final success = await service.purchaseInternationalNumber(
      country: number.country,
      number: number.sampleNumber,
      plan: selectedPlan,
      creditAmount: totalDue,
    );

    if (!mounted) return;

    setState(() => isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${number.sampleNumber} reserved for your account.'
              : 'International number purchase is not available yet.',
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
                        'Available Countries',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNumberList(),
                      const SizedBox(height: 22),
                      _buildPlanSelector(),
                      const SizedBox(height: 22),
                      _buildSummaryCard(),
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
                'Buy Global Number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Reserve an international line',
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
            Icons.public_rounded,
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
              Icon(Icons.sim_card_rounded, color: Color(0xFF38BDF8)),
              SizedBox(width: 8),
              Text(
                'International Caller ID',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Receive calls and place outbound calls with a trusted local presence in supported countries.',
            style: TextStyle(color: Colors.white, fontSize: 20, height: 1.25),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroPill(label: 'Voice enabled'),
              _HeroPill(label: 'SMS ready'),
              _HeroPill(label: 'Credit billing'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberList() {
    if (numbers.isEmpty) {
      return const _EmptyPanel(
        icon: Icons.public_off_rounded,
        title: 'No countries available',
        message: 'International number inventory will appear here.',
      );
    }

    return Column(
      children: List.generate(numbers.length, (index) {
        final number = numbers[index];
        final active = selectedNumberIndex == index;

        return InkWell(
          onTap: () => setState(() => selectedNumberIndex = index),
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
                  height: 54,
                  width: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF14B8A6).withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    number.flag,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              number.country,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (number.popular) ...[
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
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Color(0xFF5EEAD4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${number.sampleNumber} • ${number.monthlyFeeCredit.toStringAsFixed(0)} Credits/mo',
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

  Widget _buildPlanSelector() {
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
            'Billing Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PlanButton(
                label: 'Monthly',
                subtitle: 'Pay every month',
                active: selectedPlan == 'Monthly',
                onTap: () => setState(() => selectedPlan = 'Monthly'),
              ),
              const SizedBox(width: 10),
              _PlanButton(
                label: 'Annual',
                subtitle: '2 months free',
                active: selectedPlan == 'Annual',
                onTap: () => setState(() => selectedPlan = 'Annual'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final number = selectedNumber;
    if (number == null) return const SizedBox.shrink();

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
            'Purchase Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Number', value: number.sampleNumber),
          _SummaryRow(
            label: 'Setup',
            value: '${number.setupFeeCredit.toStringAsFixed(0)} Credits',
          ),
          _SummaryRow(
            label: selectedPlan == 'Annual' ? 'Annual service' : 'Monthly',
            value:
                '${(totalDue - number.setupFeeCredit).toStringAsFixed(0)} Credits',
          ),
          const Divider(color: Colors.white10, height: 22),
          _SummaryRow(
            label: 'Total due today',
            value: '${totalDue.toStringAsFixed(0)} Credits',
            strong: true,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: number.capabilities
                .map((capability) => _CapabilityPill(label: capability))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : confirmPurchase,
        icon: isSubmitting
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.shopping_cart_checkout_rounded),
        label: Text(isSubmitting ? 'Reserving...' : 'Buy Number'),
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

class _PlanButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  const _PlanButton({
    required this.label,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white60,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? Colors.white : Colors.white54,
                fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: strong ? const Color(0xFF5EEAD4) : Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return _CapabilityPill(label: label);
  }
}

class _CapabilityPill extends StatelessWidget {
  final String label;

  const _CapabilityPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF5EEAD4).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF5EEAD4),
          fontSize: 12,
          fontWeight: FontWeight.w800,
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
