import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/models/transaction_model.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).walletTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          final user = provider.user;
          if (user == null) return Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                _buildBalanceCard(user.itcBalance),
                SizedBox(height: 16),
                _buildPointsInfo(context, user.itcBalance),
                SizedBox(height: 16),
                _buildDepositWithdrawButtons(context),
                SizedBox(height: 16),
                _buildHistoryButton(context),
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double itcBalance) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.purple.withValues(alpha: 0.3), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text('¢', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            ),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${itcBalance.toStringAsFixed(2)}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('ITC', style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfo(BuildContext context, double currentPoints) {
    final l10n = AppLocalizations.of(context);
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.gold, size: 22),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context).itcInfo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoRow(l10n.currentBalance, '${currentPoints.toStringAsFixed(2)} ITC'),
          SizedBox(height: 8),
          _buildInfoRow(l10n.availableTasks, l10n.collectFromTasks),
          SizedBox(height: 8),
          _buildInfoRow(l10n.store, l10n.buyAnimalsITC),
        ],
      ),
    );
  }

  Widget _buildDepositWithdrawButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/buy_sell'),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(l10n.buyITC, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/buy_sell'),
            icon: Icon(Icons.remove, color: Colors.white),
            label: Text(l10n.sellITC, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.grey600, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showHistorySheet(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(Icons.chevron_right, color: AppColors.gold, size: 22),
                Spacer(),
                Text(AppLocalizations.of(context).transactionHistory, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<DemoProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  Container(margin: EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey600, borderRadius: BorderRadius.circular(2))),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context).transactionHistory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 16),
                  Expanded(
                    child: provider.transactions.isEmpty
                        ? Center(child: Text(AppLocalizations.of(context).noTransactions, style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: provider.transactions.length,
                            itemBuilder: (context, index) {
                              final tx = provider.transactions[index];
                              return _buildHistoryTile(tx);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryTile(TransactionModel tx) {
    Color amountColor = tx.isPositive ? Colors.green : Colors.red;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Text(tx.typeEmoji, style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                SizedBox(height: 2),
                Text(tx.typeName, style: TextStyle(fontSize: 12, color: AppColors.grey600)),
              ],
            ),
          ),
          Text(tx.formattedAmount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
