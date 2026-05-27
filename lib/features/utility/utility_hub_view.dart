import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import 'data/utility_catalog_service.dart';

class UtilityHubView extends StatefulWidget {
  const UtilityHubView({super.key});

  @override
  State<UtilityHubView> createState() => _UtilityHubViewState();
}

class _UtilityHubViewState extends State<UtilityHubView> {
  final UtilityCatalogService _service = UtilityCatalogService();
  late Future<UtilityCatalogModel> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = _service.fetchCatalog();
  }

  void _refresh() {
    setState(() {
      _catalogFuture = _service.fetchCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FutureBuilder<UtilityCatalogModel>(
          future: _catalogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: PeraXColors.cyan),
              );
            }

            if (snapshot.hasError) {
              return _ErrorState(error: snapshot.error.toString(), onRetry: _refresh);
            }

            final catalog = snapshot.data ?? UtilityCatalogModel.mock();
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              children: [
                _Hero(catalog: catalog, onRefresh: _refresh),
                const SizedBox(height: 20),
                _ServiceGrid(services: catalog.services),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final UtilityCatalogModel catalog;
  final VoidCallback onRefresh;

  const _Hero({required this.catalog, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final activeCount = catalog.services.where((service) => service.isActive).length;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PeraXColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PeraXColors.cyan.withValues(alpha: 0.25)),
                ),
                child: const Text(
                  'CREDITS UTILITY HUB',
                  style: TextStyle(
                    color: PeraXColors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            catalog.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            catalog.description,
            style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _Metric(label: 'Services', value: catalog.services.length.toString()),
              const SizedBox(width: 12),
              _Metric(label: 'Active', value: activeCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  final List<UtilityServiceModel> services;

  const _ServiceGrid({required this.services});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1000 ? 3 : constraints.maxWidth >= 640 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: crossAxisCount == 1 ? 1.65 : 1.05,
          ),
          itemBuilder: (context, index) => _ServiceCard(service: services[index]),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final UtilityServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      radius: 30,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: service.isActive ? () => context.go(service.route) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: PeraXColors.cyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(_iconFor(service.code), color: PeraXColors.cyan),
                ),
                const Spacer(),
                _StatusPill(status: service.status),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              service.category,
              style: const TextStyle(color: PeraXColors.cyan, fontWeight: FontWeight.w800, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                service.description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.creditUnit,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
                Icon(
                  service.isActive ? Icons.arrow_forward_rounded : Icons.lock_clock_rounded,
                  color: service.isActive ? PeraXColors.cyan : Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String code) {
    switch (code) {
      case 'AI_LAB':
        return Icons.auto_awesome_rounded;
      case 'CALLS':
        return Icons.call_rounded;
      case 'SMS':
        return Icons.sms_rounded;
      case 'NUMBERS':
        return Icons.phone_in_talk_rounded;
      case 'BILLS':
        return Icons.receipt_long_rounded;
      case 'WEB_TOOLS':
        return Icons.web_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isActive ? PeraXColors.cyan : Colors.orangeAccent).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: isActive ? PeraXColors.cyan : Colors.orangeAccent,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          radius: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_rounded, color: Colors.orangeAccent, size: 42),
              const SizedBox(height: 16),
              const Text(
                'Utility catalog unavailable',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
