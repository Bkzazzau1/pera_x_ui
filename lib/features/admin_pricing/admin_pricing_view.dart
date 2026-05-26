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
  String? error;
  AdminPricingSnapshot? data;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try {
      final snapshot = await service.getSnapshot();
      if (!mounted) return;
      setState(() { data = snapshot; loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e.toString(); loading = false; });
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, double.tryParse(controller.text.trim())), child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> saveUtility(AdminUtilityPrice item) async {
    final value = await askValue(item.serviceName, item.creditCost);
    if (value == null) return;
    await service.updateUtilityPrice(serviceCode: item.serviceCode, creditCost: value);
    await load();
  }

  Future<void> saveRate(AdminCreditRate item) async {
    final value = await askValue(item.assetName, item.creditsPerUnit);
    if (value == null) return;
    await service.updateCreditRate(assetCode: item.assetCode, creditsPerUnit: value);
    await load();
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
              const Text('Admin Pricing', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Backend source of truth for Credits, rates, calls, AI and number subscriptions.', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 20),
              if (loading) const Center(child: CircularProgressIndicator(color: PeraXColors.cyan)),
              if (error != null) GlassCard(radius: 20, padding: const EdgeInsets.all(16), child: Text(error!, style: const TextStyle(color: Colors.orange))),
              if (snapshot != null) ...[
                const _Title('Utility Charges'),
                ...snapshot.utilities.map((x) => _Tile(title: x.serviceName, subtitle: '${x.category} • ${x.billingUnit}', value: '${x.creditCost} Credits', onTap: () => saveUtility(x))),
                const SizedBox(height: 18),
                const _Title('Credit Exchange Rates'),
                ...snapshot.creditRates.map((x) => _Tile(title: x.assetName, subtitle: '${x.assetCode} • ${x.unitLabel}', value: '${x.creditsPerUnit} Credits', onTap: () => saveRate(x))),
                const SizedBox(height: 18),
                const _Title('Number Subscriptions'),
                ...snapshot.numberPrices.map((x) => _Tile(title: '${x.country} ${x.numberType}', subtitle: 'Setup ${x.setupFeeCredits} • Monthly ${x.monthlyFeeCredits} • Annual ${x.annualFeeCredits}', value: x.currency, onTap: () {})),
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
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
  );
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final VoidCallback onTap;
  const _Tile({required this.title, required this.subtitle, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Icon(Icons.tune_rounded, color: PeraXColors.cyan),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ])),
          Text(value, style: const TextStyle(color: PeraXColors.cyan, fontWeight: FontWeight.w900)),
        ]),
      ),
    ),
  );
}
