import 'package:flutter/material.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.privacyTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.privacyTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(loc.privacyUpdated, style: TextStyle(color: AppColors.grey600)),
            SizedBox(height: 24),
            _buildSection(loc.privacySection1Title, loc.privacySection1Content),
            _buildSection(loc.privacySection2Title, loc.privacySection2Content),
            _buildSection(loc.privacySection3Title, loc.privacySection3Content),
            _buildSection(loc.privacySection4Title, loc.privacySection4Content),
            _buildSection(loc.privacySection5Title, loc.privacySection5Content),
            _buildSection(loc.privacySection6Title, loc.privacySection6Content),
            _buildSection(loc.privacySection7Title, loc.privacySection7Content),
            _buildSection(loc.privacySection8Title, loc.privacySection8Content),
            _buildSection(loc.privacySection9Title, loc.privacySection9Content),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.grey700)),
        ],
      ),
    );
  }
}
