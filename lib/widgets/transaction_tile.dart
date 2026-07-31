import 'package:hamster_points/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final String emoji;
  final String typeName;
  final String description;
  final String amount;
  final bool isPositive;

  const TransactionTile({
    Key? key,
    required this.emoji,
    required this.typeName,
    required this.description,
    required this.amount,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          description,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          typeName,
          style: TextStyle(fontSize: 12, color: AppColors.grey600),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
