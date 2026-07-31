import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/models/animal_model.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class MyFarmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          final userAnimals = provider.userAnimals;

          if (userAnimals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: AppColors.grey300),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).emptyFarm,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).goToStore,
                    style: TextStyle(color: AppColors.grey600),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildFarmSummary(context, provider),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: userAnimals.length,
                  itemBuilder: (context, index) {
                    final userAnimal = userAnimals[index];
                    return _buildAnimalCard(context, userAnimal, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFarmSummary(BuildContext context, DemoProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            AppLocalizations.of(context).animals,
            '${provider.userAnimals.length}',
            Icons.pets,
          ),
          _buildSummaryItem(
            AppLocalizations.of(context).dailyProfitLabel,
            '${provider.totalDailyProfit}',
            Icons.stars,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildAnimalCard(BuildContext context, UserAnimal userAnimal, DemoProvider provider) {
    final animalInfo = provider.getAnimalInfo(userAnimal.animalType);
    if (animalInfo == null) return SizedBox.shrink();

    final canCollect = provider.canCollect(userAnimal);
    final collectible = provider.collectibleAmount(userAnimal);
    final isExpired = userAnimal.isExpired;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isExpired ? 0 : 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isExpired
                        ? AppColors.grey100
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      animalInfo.emoji,
                      style: TextStyle(
                        fontSize: 30,
                        color: isExpired ? Colors.grey : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            animalInfo.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isExpired) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(AppLocalizations.of(context).expired, style: TextStyle(fontSize: 12, color: Colors.red)),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context).quantity} ${userAnimal.quantity}',
                        style: TextStyle(color: AppColors.grey600),
                      ),
                      SizedBox(height: 4),
                      Text(
                         '${AppLocalizations.of(context).dailyProfitWith} ${animalInfo.dailyProfit * userAnimal.quantity} ITC',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canCollect && collectible > 0)
                  ElevatedButton.icon(
                    onPressed: () => _collectProfit(context, userAnimal, animalInfo, provider),
                    icon: Icon(Icons.get_app, size: 18),
                    label: Text('$collectible'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.timer, color: AppColors.grey600),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _collectProfit(
    BuildContext context,
    UserAnimal userAnimal,
    AnimalModel animalInfo,
    DemoProvider provider,
  ) async {
    try {
      final amount = await provider.collectAnimalProfit(userAnimal, animalInfo);

      if (!context.mounted) return;
      if (amount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
             content: Text('${AppLocalizations.of(context).gotReward} $amount ITC 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
