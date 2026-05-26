import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import 'data/admin_pricing_service.dart';

class AdminPricingView extends StatefulWidget {
  const AdminPricingView({super.key});

  @override
  State<AdminPricingView> createState() => _AdminPricingViewState();
}

class _AdminPricingViewState extends State<AdminPricingView> {
  final AdminPricingService service = AdminPricingService();
  bool loading = true;
  bool saving = false;
  String? error;
  AdminPricingSnapshot? data;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final snapshot = await service.getSnapshot();
      if (!mounted) return;
      setState(() {
        data = snapshot;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<double?> askValue(String title, double current) {
    final controller = TextEditingController(text: current.toString());
    return showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF07111F),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'New value'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, double.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<_NumberPriceEdit?> askNumberPrice(AdminNumberPrice item) {
    final setup = TextEditingController(text: item.setupFeeCredits.toString());
    final monthly = TextEditingController(text: item.monthlyFeeCredits.toString());
    final annual = TextEditingController(text: item.annualFeeCredits.toString());

    return showDialog<_NumberPriceEdit>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF07111F),
        title: Text(
          '${item.country} ${item.numberType}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogNumberInput(controller: setup, label: 'Setup fee Credits'),
            const SizedBox(height: 10),
            _DialogNumberInput(controller: monthly, label: 'Monthly fee Credits'),
            const SizedBox(height: 10),
            _DialogNumberInput(controller: annual, label: 'Annual fee Credits'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final setupFee = double.tryParse(setup.text.trim());
              final monthlyFee = double.tryParse(monthly.text.trim());
              final annualFee = double.tryParse(annual.text.trim());
              if (setupFee == null || monthlyFee == null || annualFee == null) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(
                context,
                _NumberPriceEdit(
                  setupFee: setupFee,
                  monthlyFee: monthlyFee,
                  annualFee: annualFee,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> saveUtility(AdminUtilityPrice item) async {
    final value = await askValue(item.serviceName, item.creditCost);
    if (value == null) return;
    await _save(() => service.updateUtilityPrice(serviceCode: item.serviceCode, creditCost: value));
  }

  Future<void> saveRate(AdminCreditRate item) async {
    final value = await askValue(item.assetName, item.creditsPerUnit);
    if (value == null) return;
    await _save(() => service.updateCreditRate(assetCode: item.assetCode, creditsPerUnit: value));
  }

  Future<void> saveNumberPrice(AdminNumberPrice item) async {
    final values = await askNumberPrice(item);
    if (values == null) return;
    await _save(
      () => service.updateNumberPrice(
        id: item.id,
        setupFeeCredits: values.setupFee,
        monthlyFeeCredits: values.monthlyFee,
        annualFeeCredits: values.annualFee,
      ),
    );
  }

  Future<void> _save(Future<void> Function() action) async {
    setState(() => saving = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin pricing updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = data;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            children: [
              const Text(
                'Admin Pricing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Backend source of truth for Credits, rates, calls, AI and number subscriptions.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              if (saving) const LinearProgressIndicator(color: PeraXColors.cyan),
              if (saving) const SizedBox(height: 14),
              if (loading)
                const Center(child: CircularProgressIndicator(color: PeraXColors.cyan)),
              if (error != null)
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Text(error!, style: const TextStyle(color: Colors.orange)),
                ),
              if (snapshot != null) ...[
                const _Title('Utility Charges'),
                ...snapshot.utilities.map(
                  (x) => _Tile(
                    title: x.serviceName,
                    subtitle: '${x.category} • ${x.billingUnit}',
                    value: '${x.creditCost} Credits',
                    onTap: () => saveUtility(x),
                  ),
                ),
                const SizedBox(height: 18),
                const _Title('Credit Exchange Rates'),
                ...snapshot.creditRates.map(
                  (x) => _Tile(
                    title: x.assetName,
                    subtitle: '${x.assetCode} • ${x.unitLabel}',
                    value: '${x.creditsPerUnit} Credits',
                    onTap: () => saveRate(x),
                  ),
                ),
                const SizedBox(height: 18),
                const _Title('Number Subscriptions'),
                ...snapshot.numberPrices.map(
                  (x) => _Tile(
                    title: '${x.country} ${x.numberType}',
                    subtitle:
                        'Setup ${x.setupFeeCredits} • Monthly ${x.monthlyFeeCredits} • Annual ${x.annualFeeCredits}',
                    value: x.currency,
                    onTap: () => saveNumberPrice(x),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;

  const _Tile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: GlassCard(
            radius: 20,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: PeraXColors.cyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
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
                Text(
                  value,
                  style: const TextStyle(
                    color: PeraXColors.cyan,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit_rounded, color: Colors.white38, size: 18),
              ],
            ),
          ),
        ),
      );
}

class _DialogNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _DialogNumberInput({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: PeraXColors.cyan),
        ),
      ),
    );
  }
}

class _NumberPriceEdit {
  final double setupFee;
  final double monthlyFee;
  final double annualFee;

  const _NumberPriceEdit({
    required this.setupFee,
    required this.monthlyFee,
    required this.annualFee,
  });
}
