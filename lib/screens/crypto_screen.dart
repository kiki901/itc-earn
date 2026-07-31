import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/utils/constants.dart';

class CryptoScreen extends StatefulWidget {
  @override
  State<CryptoScreen> createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).itcWalletTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Row(
            children: [
              _buildTab(AppLocalizations.of(context).balance, 0),
              _buildTab(AppLocalizations.of(context).deposit, 1),
              _buildTab(AppLocalizations.of(context).withdraw, 2),
            ],
          ),
        ),
      ),
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          switch (_currentTab) {
            case 0: return _buildBalanceTab(provider);
            case 1: return _buildDepositTab(context, provider);
            case 2: return _buildWithdrawTab(context, provider);
            default: return _buildBalanceTab(provider);
          }
        },
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceTab(DemoProvider provider) {
    final itcBalance = provider.user?.itcBalance ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF6C5CE7).withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🪙', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ITC Coin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('ITC', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  itcBalance.toStringAsFixed(6),
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositTab(BuildContext context, DemoProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).depositITC, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Text('🪙', style: TextStyle(fontSize: 32)),
              title: Text('ITC Coin', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppLocalizations.of(context).depositViaITC),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDepositDialog(context, provider),
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, DemoProvider provider) {
    final amountController = TextEditingController();
    final txHashController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context).depositITC),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).depositAddress, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      SizedBox(height: 4),
                      Text(
                        AppConstants.itcDepositAddress,
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(AppLocalizations.of(context).amountITC, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixText: 'ITC',
                  ),
                ),
                SizedBox(height: 12),
                Text(AppLocalizations.of(context).txHash, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                TextField(
                  controller: txHashController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).enterTxHash,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).cancel)),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).error), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (txHashController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).enterTxHash), backgroundColor: Colors.orange),
                  );
                  return;
                }
                provider.requestDeposit(amount, txHashController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context).depositPending), backgroundColor: Colors.green),
                );
              },
              child: Text(AppLocalizations.of(context).sendRequest),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C5CE7), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    ).then((_) {
      amountController.dispose();
      txHashController.dispose();
    });
  }

  Widget _buildWithdrawTab(BuildContext context, DemoProvider provider) {
    final itcBalance = provider.user?.itcBalance ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).withdrawITC, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Text('🪙', style: TextStyle(fontSize: 32)),
              title: Text('ITC Coin', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${AppLocalizations.of(context).availableBalance} ${itcBalance.toStringAsFixed(6)} ITC'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showWithdrawDialog(context, provider, itcBalance),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, DemoProvider provider, double balance) {
    final amountController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).withdrawITC),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${AppLocalizations.of(context).availableBalance} ${balance.toStringAsFixed(6)} ITC', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context).amountITC, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixText: 'ITC',
                ),
              ),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context).walletAddress, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).enterWalletAddress,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).cancel)),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                final currentBalance = provider.user?.itcBalance ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).error), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (amount > currentBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).insufficientBalance), backgroundColor: Colors.orange),
                  );
                  return;
                }
                if (addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).enterWalletAddress), backgroundColor: Colors.orange),
                  );
                  return;
                }
                provider.requestWithdrawal(amount, addressController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).withdrawPending), backgroundColor: Colors.orange),
                );
              },
            child: Text(AppLocalizations.of(context).sendRequest),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C5CE7), foregroundColor: Colors.white),
          ),
        ],
      ),
    ).then((_) {
      amountController.dispose();
      addressController.dispose();
    });
  }
}
