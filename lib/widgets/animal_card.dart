import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnimalCard extends StatelessWidget {
  final String emoji;
  final String name;
  final int price;
  final int dailyProfit;
  final int currentPoints;
  final VoidCallback? onPressed;

  const AnimalCard({
    Key? key,
    required this.emoji,
    required this.name,
    required this.price,
    required this.dailyProfit,
    required this.currentPoints,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canBuy = currentPoints >= price;
    final roiDays = dailyProfit > 0 ? (price / dailyProfit).ceil() : 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: canBuy ? 4 : 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: canBuy
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: 30)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 14, color: Colors.green),
                      Text(
                        '$dailyProfit ITC/${AppLocalizations.of(context).dailyProfit}',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.calendar_today, size: 14, color: AppColors.grey600),
                      Text(
                        roiDays > 0 ? '$roiDays ${AppLocalizations.of(context).daysLabel}' : '',
                        style: TextStyle(color: AppColors.grey600, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '$price',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canBuy ? AppColors.primary : AppColors.grey600,
                  ),
                ),
                ElevatedButton(
                  onPressed: canBuy ? onPressed : null,
                  child: Text(canBuy ? AppLocalizations.of(context).buy : AppLocalizations.of(context).insufficientBalance),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canBuy ? AppColors.primary : AppColors.grey300,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
