import 'package:flutter/material.dart';

enum StakingTier { bronze, silver, gold, diamond, dragon }

class StakingPlan {
  final StakingTier tier;
  final String nameAr;
  final String nameEn;
  final String nameFr;
  final String emoji;
  final double lockAmount;
  final int lockDays;
  final double totalProfit;
  final Color color;

  StakingPlan({
    required this.tier,
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
    required this.emoji,
    required this.lockAmount,
    required this.lockDays,
    required this.totalProfit,
    required this.color,
  });

  String getName(String langCode) {
    switch (langCode) {
      case 'fr': return nameFr;
      case 'en': return nameEn;
      default: return nameAr;
    }
  }

  double get dailyProfit => totalProfit / lockDays;
  double get roi => (totalProfit / lockAmount) * 100;

  static List<StakingPlan>? _cachedPlans;

  static List<StakingPlan> getDefaultPlans() {
    _cachedPlans ??= [
      StakingPlan(
        tier: StakingTier.bronze,
        nameAr: 'برونزي',
        nameEn: 'Bronze',
        nameFr: 'Bronze',
        emoji: '🥉',
        lockAmount: 500,
        lockDays: 60,
        totalProfit: 50,    // 10% ROI
        color: Color(0xFFCD7F32),
      ),
      StakingPlan(
        tier: StakingTier.silver,
        nameAr: 'فضي',
        nameEn: 'Silver',
        nameFr: 'Argent',
        emoji: '🥈',
        lockAmount: 1500,
        lockDays: 60,
        totalProfit: 225,   // 15% ROI
        color: Color(0xFFC0C0C0),
      ),
      StakingPlan(
        tier: StakingTier.gold,
        nameAr: 'ذهبي',
        nameEn: 'Gold',
        nameFr: 'Or',
        emoji: '🥇',
        lockAmount: 5000,
        lockDays: 60,
        totalProfit: 1000,  // 20% ROI
        color: Color(0xFFFFD700),
      ),
      StakingPlan(
        tier: StakingTier.diamond,
        nameAr: 'ماسي',
        nameEn: 'Diamond',
        nameFr: 'Diamant',
        emoji: '💎',
        lockAmount: 15000,
        lockDays: 60,
        totalProfit: 3750,  // 25% ROI
        color: Color(0xFF00E5FF),
      ),
      StakingPlan(
        tier: StakingTier.dragon,
        nameAr: 'تنيني',
        nameEn: 'Dragon',
        nameFr: 'Dragon',
        emoji: '🐉',
        lockAmount: 50000,
        lockDays: 60,
        totalProfit: 15000, // 30% ROI
        color: Color(0xFF7C4DFF),
      ),
    ];
    return _cachedPlans!;
  }

  static StakingPlan getPlan(StakingTier tier) {
    return getDefaultPlans().firstWhere((p) => p.tier == tier);
  }
}

class UserStaking {
  final String id;
  final StakingTier tier;
  final double lockedAmount;
  final DateTime stakedAt;
  final DateTime expiresAt;
  final double totalProfit;
  final bool claimed;

  UserStaking({
    required this.id,
    required this.tier,
    required this.lockedAmount,
    required this.stakedAt,
    required this.expiresAt,
    required this.totalProfit,
    this.claimed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  double get earnedSoFar {
    if (isExpired) return totalProfit;
    final elapsed = DateTime.now().difference(stakedAt).inDays;
    final plan = StakingPlan.getPlan(tier);
    final daily = plan.dailyProfit;
    final earned = daily * elapsed;
    return earned.clamp(0.0, totalProfit);
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  int get daysElapsed {
    final elapsed = DateTime.now().difference(stakedAt).inDays;
    return elapsed.clamp(0, StakingPlan.getPlan(tier).lockDays);
  }

  int get daysRemaining {
    final plan = StakingPlan.getPlan(tier);
    final remaining = plan.lockDays - daysElapsed;
    return remaining.clamp(0, plan.lockDays);
  }

  double get progress {
    final plan = StakingPlan.getPlan(tier);
    if (plan.lockDays <= 0) return 1.0;
    return (daysElapsed / plan.lockDays).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tier': tier.name,
      'lockedAmount': lockedAmount,
      'stakedAt': stakedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'totalProfit': totalProfit,
      'claimed': claimed,
    };
  }

  factory UserStaking.fromMap(Map<String, dynamic> data) {
    return UserStaking(
      id: data['id'] ?? '',
      tier: StakingTier.values.firstWhere(
        (t) => t.name == data['tier'],
        orElse: () => StakingTier.bronze,
      ),
      lockedAmount: (data['lockedAmount'] ?? 0).toDouble(),
      stakedAt: DateTime.tryParse(data['stakedAt'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(data['expiresAt'] ?? '') ?? DateTime.now(),
      totalProfit: (data['totalProfit'] ?? 0).toDouble(),
      claimed: data['claimed'] ?? false,
    );
  }

  UserStaking copyWith({bool? claimed}) {
    return UserStaking(
      id: id,
      tier: tier,
      lockedAmount: lockedAmount,
      stakedAt: stakedAt,
      expiresAt: expiresAt,
      totalProfit: totalProfit,
      claimed: claimed ?? this.claimed,
    );
  }
}
