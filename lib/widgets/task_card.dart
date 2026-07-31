import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String type;
  final int reward;
  final int completedCount;
  final int maxCompletions;
  final bool isCompleted;
  final VoidCallback? onPressed;

  const TaskCard({
    Key? key,
    required this.emoji,
    required this.title,
    required this.type,
    required this.reward,
    required this.completedCount,
    required this.maxCompletions,
    this.isCompleted = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(emoji, style: TextStyle(fontSize: 24)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.monetization_on, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  '$reward ITC',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.people, size: 16, color: AppColors.grey600),
                SizedBox(width: 4),
                Text(
                  '$completedCount/$maxCompletions',
                  style: TextStyle(color: AppColors.grey600),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleted ? null : onPressed,
                child: Text(isCompleted ? '${AppLocalizations.of(context).completed} ✓' : AppLocalizations.of(context).startTask),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? AppColors.grey300 : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
