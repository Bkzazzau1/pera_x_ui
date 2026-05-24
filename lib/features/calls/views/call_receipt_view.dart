import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/call_routes.dart';

class CallReceiptView extends StatelessWidget {
  final String phoneNumber;
  final String destination;
  final String duration;
  final double charge;
  final bool isInternational;

  const CallReceiptView({
    super.key,
    required this.phoneNumber,
    required this.destination,
    required this.duration,
    required this.charge,
    required this.isInternational,
  });

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              children: [
                _buildHeader(context),

                const SizedBox(height: 28),

                _buildSuccessIcon(),

                const SizedBox(height: 22),

                const Text(
                  'Call Completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your call has ended successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                _buildChargeCard(),

                const SizedBox(height: 20),

                _buildReceiptDetails(),

                const SizedBox(height: 24),

                _buildActions(context),
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
          child: Text(
            'Call Receipt',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
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
            Icons.ios_share_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      height: 98,
      width: 98,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF14B8A6).withValues(alpha: 0.14),
        border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.45),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.24),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        color: Color(0xFF5EEAD4),
        size: 52,
      ),
    );
  }

  Widget _buildChargeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102A43), Color(0xFF123D5A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text(
            'Total Charged',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${charge.toStringAsFixed(4)} PEX',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 35,
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
              'Successful',
              style: TextStyle(
                color: Color(0xFF5EEAD4),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _ReceiptRow(title: 'Phone Number', value: phoneNumber),
          _DividerLine(),
          _ReceiptRow(title: 'Destination', value: destination),
          _DividerLine(),
          _ReceiptRow(
            title: 'Call Type',
            value: isInternational ? 'International Call' : 'Local Call',
          ),
          _DividerLine(),
          _ReceiptRow(title: 'Duration', value: duration),
          _DividerLine(),
          _ReceiptRow(title: 'Payment Method', value: 'PEX Call Credit'),
          _DividerLine(),
          _ReceiptRow(title: 'Reference', value: _referenceCode),
        ],
      ),
    );
  }

  String get _referenceCode {
    final now = DateTime.now();
    return 'PERACALL-${now.millisecondsSinceEpoch.toString().substring(5)}';
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.go(CallRoutes.callHome);
            },
            icon: const Icon(Icons.phone_rounded),
            label: const Text('Make Another Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download Receipt'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white12),
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String title;
  final String value;

  const _ReceiptRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0x73FFFFFF),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 13),
      height: 1,
      color: Colors.white10,
    );
  }
}
