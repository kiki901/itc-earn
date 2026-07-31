import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/utils/constants.dart';
import 'package:flutter/material.dart';

class DailyLoginWidget extends StatelessWidget {
  final int streak;
  final bool claimedToday;
  final VoidCallback onClaim;

  const DailyLoginWidget({
    Key? key,
    required this.streak,
    required this.claimedToday,
    required this.onClaim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).dailyLogin,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (!claimedToday)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context).available,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),

            // عرض الأيام
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isCompleted = day <= streak;
                final isToday = day == streak + 1 && !claimedToday;
                final rewards = AppConstants.dailyLoginRewards;
                final reward = rewards[index];

                return _buildDayCircle(day, reward, isCompleted, isToday);
              }),
            ),

            SizedBox(height: 16),

            // معلومات الإحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).consecutiveDays,
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$streak / 7',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // زر المطالبة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: claimedToday ? null : onClaim,
                icon: Icon(
                  claimedToday ? Icons.check_circle : Icons.card_giftcard,
                  color: Colors.white,
                ),
                label: Text(
                  claimedToday ? AppLocalizations.of(context).claimedToday : AppLocalizations.of(context).claimReward,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: claimedToday ? AppColors.grey300 : AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCircle(int day, int reward, bool isCompleted, bool isToday) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isToday
                    ? AppColors.primary
                    : AppColors.grey100,
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$day',
                    style: TextStyle(
                      color: isToday ? Colors.white : AppColors.grey600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$reward',
          style: TextStyle(
            fontSize: 10,
            color: isCompleted ? Colors.green : AppColors.grey600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
