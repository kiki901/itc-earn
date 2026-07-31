import 'package:flutter/material.dart';
import 'package:hamster_points/models/exchange_model.dart';
import 'package:hamster_points/theme/app_theme.dart';

class TradeHistoryWidget extends StatelessWidget {
  final List<ExchangeTrade> trades;
  final String currentUserEmail;

  const TradeHistoryWidget({
    required this.trades,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text('Trade History', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Spacer(),
              Text('${trades.length} trades', style: TextStyle(color: AppColors.grey600, fontSize: 12)),
            ],
          ),
          SizedBox(height: 12),
          if (trades.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('لا توجد معاملات بعد', style: TextStyle(color: AppColors.grey600)),
              ),
            )
          else
            ...trades.take(10).map((t) => _buildTradeRow(t)),
        ],
      ),
    );
  }

  Widget _buildTradeRow(ExchangeTrade trade) {
    final isBuy = trade.buyerEmail == currentUserEmail;
    final isSell = trade.sellerEmail == currentUserEmail;
    final color = isBuy ? Colors.green : isSell ? Colors.red : Colors.white70;
    final label = isBuy ? 'شراء' : isSell ? 'بيع' : 'سوق';
    final time = '${trade.createdAt.hour.toString().padLeft(2, '0')}:${trade.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 8),
          Text('${trade.amount.toStringAsFixed(0)} ITC', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          Spacer(),
          Text('\$${trade.price.toStringAsFixed(4)}', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          SizedBox(width: 8),
          Text(time, style: TextStyle(color: AppColors.grey600, fontSize: 11)),
        ],
      ),
    );
  }
}
