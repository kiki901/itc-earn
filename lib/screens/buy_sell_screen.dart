import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/utils/constants.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class BuySellScreen extends StatefulWidget {
  const BuySellScreen({super.key});

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> {
  bool _isBuy = true;
  final _amountController = TextEditingController();
  final _txHashController = TextEditingController();
  final _walletController = TextEditingController();
  String _selectedPayment = 'USDT TRC20';
  double _currentPrice = AppConstants.itcPrice;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'USDT TRC20', 'icon': '💰', 'address': 'TN4k3f9L2r8mPqX5vW1yZ7bN3cH6jD4sA8'},
    {'name': 'Bitcoin', 'icon': '₿', 'address': 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'},
    {'name': 'Ethereum', 'icon': '⟠', 'address': '0x4a3B8c9D1e2F5g6H7i8J9k0L1m2N3o4P5q6R7'},
    {'name': 'Baridimob', 'icon': '📱', 'address': '+213 555 123 456'},
    {'name': 'CCP', 'icon': '🏦', 'address': 'CCP: 0012345678/001'},
    {'name': 'Virement IBAN', 'icon': '🏦', 'address': 'DZ45 0000 0000 0000 0000 0000 00'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _txHashController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  double get _amountItc => double.tryParse(_amountController.text) ?? 0;
  double get _amountUsd => _amountItc * _currentPrice;
  String get _selectedAddress {
    try {
      return _paymentMethods.firstWhere((m) => m['name'] == _selectedPayment)['address'];
    } catch (_) {
      return '';
    }
  }

  void _submitRequest() async {
    final loc = AppLocalizations.of(context);
    if (_amountItc <= 0) {
      _showMsg(loc.enterValidAmount, isError: true);
      return;
    }
    if (!_isBuy && _amountItc < AppConstants.minWithdrawalItc) {
      _showMsg('${loc.minWithdrawalMsg} ${AppConstants.minWithdrawalItc.toInt()} ITC (${AppConstants.minWithdrawalUsd.toInt()} USD)', isError: true);
      return;
    }
    if (_txHashController.text.trim().isEmpty && _isBuy) {
      _showMsg(loc.enterTxHash, isError: true);
      return;
    }
    if (!_isBuy && _walletController.text.trim().isEmpty) {
      _showMsg(loc.enterWalletAddress, isError: true);
      return;
    }

    final provider = Provider.of<DemoProvider>(context, listen: false);
    try {
      await provider.submitBuySellRequest({
        'type': _isBuy ? 'buy' : 'sell',
        'amountItc': _amountItc,
        'amountUsd': _amountUsd,
        'paymentMethod': _selectedPayment,
        'txHash': _txHashController.text.trim(),
        'walletAddress': _walletController.text.trim(),
      });
    } catch (e) {
      if (!mounted) return;
      _showMsg(loc.error, isError: true);
      return;
    }

    if (!mounted) return;
    _showMsg(loc.requestSentSuccess);
    _amountController.clear();
    _txHashController.clear();
    _walletController.clear();
    setState(() {});
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<DemoProvider>(context, listen: false);
    final balance = provider.user?.itcBalance ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.buySellTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBalanceCard(balance, loc),
            SizedBox(height: 16),
            _buildToggleButton(loc),
            SizedBox(height: 16),
            _buildAmountInput(loc),
            if (!_isBuy) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${loc.minWithdrawalMsg} ${AppConstants.minWithdrawalItc} ITC (${AppConstants.minWithdrawalUsd} USD)',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12),
            _buildPriceSummary(loc),
            SizedBox(height: 16),
            _buildPaymentMethods(loc),
            SizedBox(height: 12),
            if (_isBuy) ...[
              _buildAddressBox(loc),
              SizedBox(height: 12),
              _buildTxHashInput(loc),
            ],
            if (!_isBuy) ...[
              _buildWalletInput(loc),
            ],
            SizedBox(height: 16),
            _buildSubmitButton(loc, balance),
            SizedBox(height: 16),
            _buildPendingRequests(provider, loc),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance, AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.yourBalance, style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Text('${balance.toStringAsFixed(2)} ITC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(loc.marketValue, style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Text('\$${(balance * _currentPrice).toStringAsFixed(2)}', style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(AppLocalizations loc) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _amountController.clear();
                _txHashController.clear();
                _walletController.clear();
                setState(() => _isBuy = true);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isBuy ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('${loc.buyLabel} ITC', style: TextStyle(
                  color: _isBuy ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _amountController.clear();
                _txHashController.clear();
                _walletController.clear();
                setState(() => _isBuy = false);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !_isBuy ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('${loc.sellLabel} ITC', style: TextStyle(
                  color: !_isBuy ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(AppLocalizations loc) {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: _isBuy ? loc.howMuchBuy : loc.howMuchSell,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixText: 'ITC',
        suffixStyle: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriceSummary(AppLocalizations loc) {
    final feeItc = (_amountItc * AppConstants.sellFeePercent).toInt().toDouble();
    final netItc = _amountItc - feeItc;
    final netUsd = netItc * _currentPrice;
    final feeUsd = feeItc * _currentPrice;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.marketPrice, style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('\$${_currentPrice.toStringAsFixed(3)}', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          Divider(color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.amountInUsd, style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('\$${_amountUsd.toStringAsFixed(2)}', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          if (!_isBuy) ...[
            Divider(color: Colors.white12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${loc.sellFee} (${(AppConstants.sellFeePercent * 100).toInt()}%)', style: TextStyle(color: Colors.red, fontSize: 14)),
                Text('-\$${feeUsd.toStringAsFixed(2)}', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.youWillReceive, style: TextStyle(color: Colors.green, fontSize: 14)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${netUsd.toStringAsFixed(2)}', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${netItc.toInt()} ITC', style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_isBuy ? loc.sendVia : loc.receiveVia, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _paymentMethods.map((m) {
            final isSelected = _selectedPayment == m['name'];
            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = m['name']),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? AppColors.accent : Colors.white12),
                ),
                child: Text('${m['icon']} ${m['name']}', style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 13,
                )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddressBox(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isBuy ? loc.sendToAddress : loc.sendItcTo, style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(_selectedAddress, style: TextStyle(color: AppColors.gold, fontSize: 13, fontFamily: 'monospace')),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.white54, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _selectedAddress));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.copied), backgroundColor: Colors.green),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInput(AppLocalizations loc) {
    return TextField(
      controller: _walletController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: loc.walletAddressHint,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.grey),
      ),
    );
  }

  Widget _buildTxHashInput(AppLocalizations loc) {
    return TextField(
      controller: _txHashController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: loc.txHashHint,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(Icons.receipt, color: Colors.grey),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations loc, double balance) {
    final bool canSell = _isBuy || balance >= AppConstants.minWithdrawalItc;
    return ElevatedButton(
      onPressed: canSell ? _submitRequest : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canSell ? (_isBuy ? Colors.green : Colors.red) : Colors.grey,
        disabledBackgroundColor: Colors.grey,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        canSell ? (_isBuy ? loc.submitBuyRequest : loc.submitSellRequest) : '${loc.minWithdrawalMsg} ${AppConstants.minWithdrawalItc} ITC',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPendingRequests(DemoProvider provider, AppLocalizations loc) {
    final requests = provider.userBuySellRequests;
    if (requests.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.yourRequests, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...requests.map((r) {
          final isBuy = r['type'] == 'buy';
          final status = r['status'] ?? 'pending';
          final statusColor = status == 'pending' ? Colors.orange : status == 'approved' ? Colors.green : Colors.red;
          final statusText = status == 'pending' ? loc.pendingStatus : status == 'approved' ? loc.approvedStatus : loc.rejectedStatus;

          return Card(
            color: AppColors.surface,
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(isBuy ? Icons.shopping_cart : Icons.sell, color: isBuy ? Colors.green : Colors.red),
              title: Text('${isBuy ? loc.buyLabel : loc.sellLabel} ${r['amountItc']} ITC', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('\$${r['amountUsd']} | ${r['paymentMethod']}', style: TextStyle(color: Colors.grey)),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
