import 'package:flutter/material.dart';
import 'package:hamster_points/models/exchange_model.dart';
import 'package:hamster_points/theme/app_theme.dart';

class MarketStatsWidget extends StatelessWidget {
  final MarketState market;

  const MarketStatsWidget({required this.market});

  @override
  Widget build(BuildContext context) {
    final isPositive = market.changePercent >= 0;

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
              Icon(Icons.bar_chart, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text('Market Stats', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStat('24h High', '\$${market.high24h.toStringAsFixed(4)}', Colors.green)),
              SizedBox(width: 8),
              Expanded(child: _buildStat('24h Low', '\$${market.low24h.toStringAsFixed(4)}', Colors.red)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildStat('Volume', '\$${_formatVolume(market.volume24h)}', AppColors.primary)),
              SizedBox(width: 8),
              Expanded(child: _buildStat(
                'Change',
                '${isPositive ? "+" : ""}${market.changePercent.toStringAsFixed(2)}%',
                isPositive ? Colors.green : Colors.red,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.grey600, fontSize: 11)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000) return '${(volume / 1000000).toStringAsFixed(1)}M';
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}K';
    return volume.toStringAsFixed(2);
  }
}
