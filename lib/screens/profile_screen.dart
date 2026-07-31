import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/providers/locale_provider.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/models/user_model.dart';
import 'package:hamster_points/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profileTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          final user = provider.user;
          if (user == null) return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text(loc.errorLoadingData, style: TextStyle(color: Colors.red, fontSize: 16)),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                  child: Text(loc.login),
                ),
              ],
            ),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(context, user),
                SizedBox(height: 16),
                _buildStatsRow(context, user),
                SizedBox(height: 16),
                _buildTransactionsList(context, provider),
                SizedBox(height: 16),
                _buildLegalSection(context),
                SizedBox(height: 16),
                _buildLanguageSwitcher(context),
                SizedBox(height: 16),
                _buildDeleteAccountButton(context, provider),
                SizedBox(height: 16),
                _buildLogoutButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    final loc = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 36, color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(user.email ?? loc.noEmail, style: TextStyle(color: AppColors.grey600)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${loc.referralCode} ${user.referralCode}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserModel user) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        _buildMiniStat(loc.currentBalance, '${user.itcBalance.toStringAsFixed(2)} ITC', Colors.green),
        _buildMiniStat(loc.earned, '${user.totalEarned.toStringAsFixed(2)} ITC', Colors.blue),
        _buildMiniStat(loc.referrals, '${user.totalReferrals}', Colors.orange),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, DemoProvider provider) {
    final loc = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.transactionHistory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            if (provider.transactions.isEmpty)
              Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(loc.noTransactions, style: TextStyle(color: AppColors.grey600)),
              ))
            else
              ...provider.transactions.take(10).map((tx) => ListTile(
                    leading: Text(tx.typeEmoji, style: TextStyle(fontSize: 22)),
                    title: Text(tx.description, style: TextStyle(fontSize: 14)),
                    trailing: Text(
                      tx.formattedAmount,
                      style: TextStyle(
                        color: tx.isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    dense: true,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.legal, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: AppColors.primary),
              title: Text(loc.privacyPolicy),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/privacy'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.description, color: AppColors.primary),
              title: Text(loc.termsOfService),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    final languages = [
      {'code': 'ar', 'name': 'العربية', 'flag': '\u{1F1F8}\u{1F1E6}', 'locale': Locale('ar', 'SA')},
      {'code': 'en', 'name': 'English', 'flag': '\u{1F1FA}\u{1F1F8}', 'locale': Locale('en', 'US')},
      {'code': 'fr', 'name': 'Français', 'flag': '\u{1F1EB}\u{1F1F7}', 'locale': Locale('fr', 'FR')},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.languageLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...languages.map((Map<String, dynamic> lang) {
              final isSelected = localeProvider.locale.languageCode == lang['code'];
              return Column(
                children: [
                  ListTile(
                    leading: Text(lang['flag'] as String, style: TextStyle(fontSize: 24)),
                    title: Text(lang['name'] as String),
                    trailing: isSelected ? Icon(Icons.check, color: AppColors.primary) : null,
                    onTap: () {
                      localeProvider.setLocale(lang['locale'] as Locale);
                    },
                  ),
                  if (lang != languages.last) Divider(height: 1),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, DemoProvider provider) {
    final loc = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteAccountDialog(context, provider),
        icon: Icon(Icons.delete_forever, color: Colors.red),
        label: Text(loc.deleteAccount, style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Provider.of<DemoProvider>(context, listen: false).logout();
          Navigator.pushReplacementNamed(context, '/auth');
        },
        icon: Icon(Icons.logout, color: Colors.red),
        label: Text(loc.logout, style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, DemoProvider provider) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(loc.deleteConfirm),
            SizedBox(height: 8),
            Text(
              loc.deleteWarning,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteAccount();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/auth');
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.error), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(loc.delete),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
