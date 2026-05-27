import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/widgets/glass_card.dart';
import 'data/protocol_status_service.dart';

class ProtocolStatusView extends StatefulWidget {
  const ProtocolStatusView({super.key});

  @override
  State<ProtocolStatusView> createState() => _ProtocolStatusViewState();
}

class _ProtocolStatusViewState extends State<ProtocolStatusView> {
  final ProtocolStatusService _service = ProtocolStatusService();
  late Future<ProtocolStatusModel> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _service.fetchStatus();
  }

  void _refresh() {
    setState(() {
      _statusFuture = _service.fetchStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: FutureBuilder<ProtocolStatusModel>(
          future: _statusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: PeraXColors.cyan),
              );
            }

            if (snapshot.hasError) {
              return _ErrorState(error: snapshot.error.toString(), onRetry: _refresh);
            }

            final status = snapshot.data ?? ProtocolStatusModel.mock();
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              children: [
                _Header(status: status, onRefresh: _refresh),
                const SizedBox(height: 20),
                _StatusGrid(status: status),
                const SizedBox(height: 20),
                _PolicyCard(status: status),
                const SizedBox(height: 20),
                _UtilityCard(status: status),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ProtocolStatusModel status;
  final VoidCallback onRefresh;

  const _Header({required this.status, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  status.status.toUpperCase(),
                  style: const TextStyle(
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
            '${status.protocolName} Protocol Status',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            status.note,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  final ProtocolStatusModel status;

  const _StatusGrid({required this.status});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _StatusItem('Token', status.tokenSymbol, Icons.token_rounded),
      _StatusItem('Network', status.network, Icons.hub_rounded),
      _StatusItem('Supply', _formatSupply(status.totalSupply), Icons.pie_chart_rounded),
      _StatusItem('Decimals', status.decimals.toString(), Icons.pin_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: crossAxisCount == 4 ? 1.35 : 1.15,
          ),
          itemBuilder: (context, index) => _StatusTile(item: rows[index]),
        );
      },
    );
  }

  String _formatSupply(int value) {
    if (value == 1000000000) return '1B PEX';
    return value.toString();
  }
}

class _StatusTile extends StatelessWidget {
  final _StatusItem item;

  const _StatusTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: PeraXColors.cyan, size: 26),
          const Spacer(),
          Text(
            item.label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final ProtocolStatusModel status;

  const _PolicyCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Policy Controls',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Program ID', value: status.programId),
          _InfoRow(label: 'Burn Mode', value: status.burnExecutionMode),
          _InfoRow(label: 'Immediate Burn', value: '${status.immediateBurnPercentage}%'),
          _InfoRow(label: 'Monthly Sell Cap', value: '${status.monthlySellCapPercentage}%'),
          _InfoRow(
            label: 'Locked Account',
            value: status.tradingCompanyLockedAccountConfigured ? 'Configured' : 'Not configured',
          ),
          _InfoRow(
            label: 'Revenue Account',
            value: status.tradingCompanyRevenueAccountConfigured ? 'Configured' : 'Not configured',
          ),
        ],
      ),
    );
  }
}

class _UtilityCard extends StatelessWidget {
  final ProtocolStatusModel status;

  const _UtilityCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      radius: 32,
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: PeraXColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.open_in_new_rounded, color: PeraXColors.cyan),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Utility App',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.utilityAppUrl,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
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
                'Protocol status unavailable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
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

class _StatusItem {
  final String label;
  final String value;
  final IconData icon;

  const _StatusItem(this.label, this.value, this.icon);
}
