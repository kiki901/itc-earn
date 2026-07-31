import 'package:flutter/material.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.termsTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.termsTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(loc.termsUpdated, style: TextStyle(color: AppColors.grey600)),
            SizedBox(height: 24),
            _buildSection(loc.termsSection1Title, loc.termsSection1Content),
            _buildSection(loc.termsSection2Title, loc.termsSection2Content),
            _buildSection(loc.termsSection3Title, loc.termsSection3Content),
            _buildSection(loc.termsSection4Title, loc.termsSection4Content),
            _buildSection(loc.termsSection5Title, loc.termsSection5Content),
            _buildSection(loc.termsSection6Title, loc.termsSection6Content),
            _buildSection(loc.termsSection7Title, loc.termsSection7Content),
            _buildSection(loc.termsSection8Title, loc.termsSection8Content),
            _buildSection(loc.termsSection9Title, loc.termsSection9Content),
            _buildSection(loc.termsSection10Title, loc.termsSection10Content),
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
