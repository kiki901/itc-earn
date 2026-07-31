import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/models/user_model.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/utils/constants.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class ReferralScreen extends StatefulWidget {
  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).referralsTitle),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          final user = provider.user;
          if (user == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReferralHeader(context, user.referralCode),
                SizedBox(height: 24),
                _buildReferralStats(user),
                SizedBox(height: 24),
                _buildReferralRewards(),
                SizedBox(height: 24),
                _buildEnterReferralCode(context, provider, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReferralHeader(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                l10n.yourReferralCode,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _copyCode(context, code),
                    icon: Icon(Icons.copy, color: AppColors.secondary),
                    label: Text(l10n.copyCode, style: TextStyle(color: AppColors.secondary)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _shareCode(code),
                    icon: Icon(Icons.share, color: Colors.white),
                    label: Text(l10n.shareCode),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralStats(UserModel user) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(l10n.referralsTitle, '${user.totalReferrals}', Icons.people, Colors.blue),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(l10n.active, '${user.activeReferrals}', Icons.person_add, Colors.green),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('ITC', '${user.referralEarnings.toStringAsFixed(2)}', Icons.monetization_on, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey600)),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralRewards() {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.referralRewards,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildRewardItem(l10n.perFriend, '+${AppConstants.referralSignupBonus} ITC', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(String title, String reward, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            reward,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterReferralCode(BuildContext context, DemoProvider provider, UserModel user) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.enterReferralCode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              l10n.enterReferralHint,
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l10n.codeField,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.code),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _applyReferralCode(context, provider, user),
                  child: Text(l10n.apply),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.codeCopied),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareCode(String code) {
    final l10n = AppLocalizations.of(context);
    final text = '''
${l10n.joinHamsterPoints}

${l10n.useMyCode}: $code
${l10n.getBonus}
''';

    Share.share(text, subject: l10n.shareSubject);
  }

  Future<void> _applyReferralCode(BuildContext context, DemoProvider provider, UserModel user) async {
    final l10n = AppLocalizations.of(context);
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterCodeFirst), backgroundColor: Colors.orange),
      );
      return;
    }

    if (code.toUpperCase() == user.referralCode.toUpperCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cantUseOwnCode), backgroundColor: Colors.orange),
      );
      return;
    }

    if (user.referredBy != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.alreadyUsedCode), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final success = await provider.applyReferralCode(code);
      _controller.clear();
      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.codeApplied),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invalidCode),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _controller.clear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
