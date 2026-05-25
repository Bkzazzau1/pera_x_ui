import 'package:flutter/material.dart';

class CallSettingsView extends StatefulWidget {
  const CallSettingsView({super.key});

  @override
  State<CallSettingsView> createState() => _CallSettingsViewState();
}

class _CallSettingsViewState extends State<CallSettingsView> {
  bool defaultInternational = false;
  bool lowCreditAlert = true;
  bool showCallerId = true;
  bool secureCallMode = true;
  bool autoSaveReceipts = true;

  String preferredPaymentMethod = '';

  final List<String> paymentMethods = [];

  void saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call settings saved successfully.'),
        backgroundColor: Color(0xFF16A34A),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),

                const SizedBox(height: 22),

                _buildProfileCard(),

                const SizedBox(height: 18),

                _buildSettingsCard(),

                const SizedBox(height: 18),

                _buildPaymentMethodCard(),

                const SizedBox(height: 24),

                _buildSaveButton(),
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
                'Call Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage your PeraCall preferences',
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
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 21),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
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
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.phone_in_talk_rounded,
              color: Color(0xFF5EEAD4),
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PeraCall Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your preferences will be used for local and international calls.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _SettingsSwitchTile(
            title: 'Default International Call',
            subtitle: 'Open call screen in international mode by default',
            icon: Icons.public_rounded,
            value: defaultInternational,
            onChanged: (value) {
              setState(() {
                defaultInternational = value;
              });
            },
          ),
          _DividerLine(),

          _SettingsSwitchTile(
            title: 'Low Credit Alert',
            subtitle: 'Notify me when my call Credits are low',
            icon: Icons.notifications_active_rounded,
            value: lowCreditAlert,
            onChanged: (value) {
              setState(() {
                lowCreditAlert = value;
              });
            },
          ),
          _DividerLine(),

          _SettingsSwitchTile(
            title: 'Show Caller ID',
            subtitle: 'Allow receiver to see my caller identity',
            icon: Icons.badge_rounded,
            value: showCallerId,
            onChanged: (value) {
              setState(() {
                showCallerId = value;
              });
            },
          ),
          _DividerLine(),

          _SettingsSwitchTile(
            title: 'Secure Call Mode',
            subtitle: 'Use enhanced protection for call session and billing',
            icon: Icons.security_rounded,
            value: secureCallMode,
            onChanged: (value) {
              setState(() {
                secureCallMode = value;
              });
            },
          ),
          _DividerLine(),

          _SettingsSwitchTile(
            title: 'Auto-Save Receipts',
            subtitle: 'Automatically save receipt after each completed call',
            icon: Icons.receipt_long_rounded,
            value: autoSaveReceipts,
            onChanged: (value) {
              setState(() {
                autoSaveReceipts = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preferred Purchase Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'This will be selected first when buying call Credits.',
            style: TextStyle(color: Color(0x73FFFFFF), fontSize: 12),
          ),

          const SizedBox(height: 14),

          if (paymentMethods.isEmpty)
            const _SettingsEmptyState(
              icon: Icons.account_balance_wallet_rounded,
              title: 'No payment methods available',
              message: 'Payment preferences will appear here when available.',
            ),

          ...paymentMethods.map((method) {
            final active = preferredPaymentMethod == method;

            return InkWell(
              onTap: () {
                setState(() {
                  preferredPaymentMethod = method;
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: saveSettings,
        icon: const Icon(Icons.save_rounded),
        label: const Text('Save Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF14B8A6),
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

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFF14B8A6).withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: value ? const Color(0xFF5EEAD4) : Colors.white54,
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0x73FFFFFF),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF14B8A6),
          activeTrackColor: const Color(0xFF14B8A6).withValues(alpha: 0.35),
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}

class _SettingsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _SettingsEmptyState({
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

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      height: 1,
      color: Colors.white10,
    );
  }
}
