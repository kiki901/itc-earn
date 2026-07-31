import 'package:flutter/material.dart';
import 'package:hamster_points/models/exchange_model.dart';
import 'package:hamster_points/theme/app_theme.dart';

class OrderBookWidget extends StatelessWidget {
  final List<ExchangeOrder> buyOrders;
  final List<ExchangeOrder> sellOrders;
  final double currentPrice;

  const OrderBookWidget({
    required this.buyOrders,
    required this.sellOrders,
    required this.currentPrice,
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
              Icon(Icons.book, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text('Order Book', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          _buildHeader('Price (USD)', 'Amount (ITC)'),
          SizedBox(height: 4),
          if (sellOrders.isEmpty)
            _buildEmptyRow('لا توجد أوامر بيع', Colors.red)
          else
            ...sellOrders.take(5).map((o) => _buildOrderRow(o, Colors.red)),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '\$${currentPrice.toStringAsFixed(4)}',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          if (buyOrders.isEmpty)
            _buildEmptyRow('لا توجد أوامر شراء', Colors.green)
          else
            ...buyOrders.take(5).map((o) => _buildOrderRow(o, Colors.green)),
        ],
      ),
    );
  }

  Widget _buildHeader(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: TextStyle(color: AppColors.grey600, fontSize: 11)),
        Text(right, style: TextStyle(color: AppColors.grey600, fontSize: 11)),
      ],
    );
  }

  Widget _buildOrderRow(ExchangeOrder order, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${order.price.toStringAsFixed(4)}',
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            order.amount.toStringAsFixed(0),
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRow(String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(text, style: TextStyle(color: color.withValues(alpha: 0.5), fontSize: 12)),
      ),
    );
  }
}
