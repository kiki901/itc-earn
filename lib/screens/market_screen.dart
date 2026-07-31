import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/models/animal_model.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class MarketScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DemoProvider>(
        builder: (context, provider, child) {
          final animals = provider.availableAnimals.where((a) => a.lifespan > 0).toList();
          final currentPoints = provider.user?.itcBalance ?? 0;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).marketTitle,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).marketDesc,
                      style: TextStyle(color: AppColors.grey600, fontSize: 12),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/rare_animals'),
                        icon: Icon(Icons.stars, color: Colors.white),
                        label: Text(AppLocalizations.of(context).rareAnimalsShop, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: animals.length,
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    return _buildAnimalCard(context, animal, currentPoints, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimalCard(BuildContext context, AnimalModel animal, double currentPoints, DemoProvider provider) {
    final canBuyPoints = currentPoints >= animal.price;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(animal.emoji, style: TextStyle(fontSize: 32))),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(animal.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stars, size: 14, color: Colors.green),
                          Text('${animal.dailyProfit} ITC/${AppLocalizations.of(context).dailyProfit}', style: TextStyle(color: Colors.green, fontSize: 12)),
                          SizedBox(width: 12),
                          Icon(Icons.timer, size: 14, color: AppColors.grey600),
                          Text('${animal.collectionInterval}h', style: TextStyle(color: AppColors.grey600, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canBuyPoints ? () => _buyWithPoints(context, animal, provider) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canBuyPoints ? AppColors.primary : AppColors.grey300,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: canBuyPoints
                    ? Text('${AppLocalizations.of(context).buyWithITC} ${animal.price} ITC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                    : Text('${AppLocalizations.of(context).needMoreItc} ${(animal.price - currentPoints).toStringAsFixed(2)} ITC ${AppLocalizations.of(context).additionalItc}', style: TextStyle(fontSize: 13)),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _buyWithPoints(BuildContext context, AnimalModel animal, DemoProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).confirmPurchase),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppLocalizations.of(context).buyAnimalConfirm} ${animal.name} ${AppLocalizations.of(context).forPrice} ${animal.price} ITC?'),
            SizedBox(height: 8),
            Text('${AppLocalizations.of(context).dailyReward}: ${animal.dailyProfit} ITC', style: TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context).cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context).buy),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await provider.buyAnimal(animal);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? '${AppLocalizations.of(context).purchaseSuccess} ${animal.name}' : AppLocalizations.of(context).insufficientBalance),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
