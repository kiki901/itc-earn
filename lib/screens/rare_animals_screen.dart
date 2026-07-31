import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/models/animal_model.dart';
import 'package:hamster_points/l10n/app_localizations.dart';

class RareAnimalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = Provider.of<DemoProvider>(context);
    final balance = provider.user?.itcBalance ?? 0;

    final rareAnimals = [
      AnimalModel(id: 'lion', type: AnimalType.lion, name: loc.lion, price: 500000, dailyProfit: 12000, emoji: '🦁', lifespan: 0),
      AnimalModel(id: 'phoenix', type: AnimalType.phoenix, name: loc.phoenix, price: 500000, dailyProfit: 15000, emoji: '🔥', lifespan: 0),
      AnimalModel(id: 'unicorn', type: AnimalType.unicorn, name: loc.unicorn, price: 500000, dailyProfit: 18000, emoji: '🦄', lifespan: 0),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.rareAnimalsShop, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.amber.shade800, Colors.orange.shade900]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.yourBalance, style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('${balance.toStringAsFixed(0)} ITC', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(loc.lifetimeLabel, style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(loc.forever, style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: rareAnimals.length,
              itemBuilder: (context, index) {
                final animal = rareAnimals[index];
                final canBuy = balance >= animal.price;
                final userAnimal = provider.getUserAnimalByType(animal.type);
                final owned = userAnimal != null;

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: canBuy
                            ? [Colors.amber.shade900, Colors.orange.shade800]
                            : [AppColors.surface, AppColors.surface],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.gold, width: 2),
                          ),
                          child: Center(
                            child: Text(animal.emoji, style: TextStyle(fontSize: 42)),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(animal.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4),
                        Text(loc.lifetimeAnimal, style: TextStyle(color: AppColors.gold, fontSize: 13)),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfo(loc.marketPrice, '${_formatNumber(animal.price)} ITC', Colors.white),
                            _buildInfo(loc.dailyProfitLabel, '${_formatNumber(animal.dailyProfit)} ITC/day', Colors.green),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (owned)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text('${loc.owned} (${userAnimal.quantity})', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: canBuy ? () => _buyRareAnimal(context, animal, provider) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canBuy ? Colors.amber : Colors.grey,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                canBuy ? '${loc.buyFor} ${_formatNumber(animal.price)} ITC' : '${loc.insufficientBalance} (${_formatNumber(balance)} ITC)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: canBuy ? Colors.black : Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 12)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatNumber(num number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(0)}K';
    return number.toString();
  }

  void _buyRareAnimal(BuildContext context, AnimalModel animal, DemoProvider provider) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${animal.emoji} ${animal.name}'),
        content: Text('${loc.confirmBuyRare} ${animal.name} ${loc.forPrice} ${_formatNumber(animal.price)} ITC?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.buy),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.buyAnimal(animal);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.buyAnimalConfirm} ${animal.name}! ${loc.lifetimeAnimal}'), backgroundColor: Colors.green),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.insufficientBalance), backgroundColor: Colors.red),
        );
      }
    }
  }
}
