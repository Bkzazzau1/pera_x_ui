import 'package:flutter/material.dart';

import '../data/call_service.dart';

class CallHistoryView extends StatefulWidget {
  const CallHistoryView({super.key});

  @override
  State<CallHistoryView> createState() => _CallHistoryViewState();
}

class _CallHistoryViewState extends State<CallHistoryView> {
  final CallService service = CallService();

  bool isLoading = true;
  String selectedFilter = 'All';

  List<Map<String, dynamic>> callHistory = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await service.getCallHistory();

    if (!mounted) return;

    setState(() {
      callHistory = data;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter == 'All') return callHistory;
    return callHistory.where((call) => call['type'] == selectedFilter).toList();
  }

  double get totalSpent {
    return callHistory.fold<double>(
      0,
      (sum, call) => sum + ((call['charge'] as num?)?.toDouble() ?? 0),
    );
  }

  int get totalCalls {
    return callHistory.length;
  }

  int get successfulCalls {
    return callHistory.where((call) => call['status'] == 'Successful').length;
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
                      const SizedBox(height: 18),
                      _buildSummaryCard(),
                      const SizedBox(height: 18),
                      _buildFilters(),
                      const SizedBox(height: 16),
                      _buildHistoryList(),
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
                'Call History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Track calls, duration and PEX charges',
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
            Icons.search_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF123D5A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
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
        children: [
          Row(
            children: [
              const Text(
                'Usage Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _SummaryItem(
                title: 'Spent',
                value: '${totalSpent.toStringAsFixed(2)} PEX',
              ),
              _VerticalDivider(),
              _SummaryItem(title: 'Calls', value: '$totalCalls'),
              _VerticalDivider(),
              _SummaryItem(title: 'Success', value: '$successfulCalls'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Local', 'International'];

    return Row(
      children: filters.map((filter) {
        final active = selectedFilter == filter;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF14B8A6)
                      : const Color(0xFF07111F).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active
                        ? const Color(0xFF5EEAD4).withValues(alpha: 0.45)
                        : Colors.white10,
                  ),
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryList() {
    if (filteredHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF07111F).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          children: [
            Icon(Icons.call_missed_rounded, color: Colors.white38, size: 42),
            SizedBox(height: 12),
            Text(
              'No call record found',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredHistory.map((call) {
        return _CallHistoryTile(call: call);
      }).toList(),
    );
  }
}

class _CallHistoryTile extends StatelessWidget {
  final Map<String, dynamic> call;

  const _CallHistoryTile({required this.call});

  @override
  Widget build(BuildContext context) {
    final bool isLocal = call['type'] == 'Local';
    final String status = call['status'] ?? 'Unknown';

    final Color tagColor = isLocal
        ? const Color(0xFF14B8A6)
        : const Color(0xFF38BDF8);

    final Color statusColor = status == 'Successful'
        ? const Color(0xFF14B8A6)
        : status == 'Missed'
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    final double charge = ((call['charge'] as num?)?.toDouble() ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  isLocal ? Icons.phone_rounded : Icons.public_rounded,
                  color: tagColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call['name'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${call['number'] ?? ''} • ${call['time'] ?? ''}',
                      style: const TextStyle(
                        color: Color(0x73FFFFFF),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${charge.toStringAsFixed(2)} PEX',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    call['duration'] ?? '00:00',
                    style: const TextStyle(
                      color: Color(0x73FFFFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _SmallPill(text: call['type'] ?? 'Unknown', color: tagColor),
              const SizedBox(width: 8),
              _SmallPill(
                text: call['destination'] ?? 'Unknown',
                color: const Color(0xFF38BDF8),
              ),
              const Spacer(),
              _SmallPill(text: status, color: statusColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 38, width: 1, color: Colors.white10);
  }
}
