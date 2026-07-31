import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/models/staking_model.dart';
import 'package:hamster_points/services/audio_service.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.stakingTitle, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<DemoProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(provider, loc),
                SizedBox(height: 20),
                _buildActiveStakings(provider, loc, langCode),
                SizedBox(height: 20),
                Text(
                  loc.stakingPlans,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                ...StakingPlan.getDefaultPlans().map((plan) =>
                  _buildPlanCard(plan, provider, loc, langCode),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(DemoProvider provider, AppLocalizations loc) {
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text('🔒', style: TextStyle(fontSize: 26)),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.stakingTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      loc.stakingDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                loc.stakingTotalStaked,
                '${provider.totalStaked.toInt()} ITC',
                Icons.lock,
                AppColors.gold,
              ),
              _buildStatItem(
                loc.stakingTotalProfit,
                '+${provider.totalStakingProfit.toInt()} ITC',
                Icons.trending_up,
                AppColors.success,
              ),
              _buildStatItem(
                loc.stakingActive,
                '${provider.userStakings.where((s) => !s.claimed && !s.isExpired).length}',
                Icons.speed,
                AppColors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStakings(DemoProvider provider, AppLocalizations loc, String langCode) {
    final activeStakings = provider.userStakings.where((s) => !s.claimed).toList();

    if (activeStakings.isEmpty) {
      return GlassContainer(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.lock_open, color: Colors.white24, size: 48),
              SizedBox(height: 12),
              Text(
                loc.stakingNoActive,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.stakingActiveStakings,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        ...activeStakings.map((staking) => _buildActiveStakingCard(staking, provider, loc, langCode)),
      ],
    );
  }

  Widget _buildActiveStakingCard(UserStaking staking, DemoProvider provider, AppLocalizations loc, String langCode) {
    final plan = StakingPlan.getPlan(staking.tier);
    final isExpired = staking.isExpired;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [AppColors.success.withValues(alpha: 0.2), AppColors.success.withValues(alpha: 0.1)]
              : [plan.color.withValues(alpha: 0.15), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired ? AppColors.success.withValues(alpha: 0.4) : plan.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(plan.emoji, style: TextStyle(fontSize: 36)),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.getName(langCode)} ${loc.vault}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${staking.lockedAmount.toInt()} ${loc.itcLocked}',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isExpired ? loc.stakingReady : '${staking.daysRemaining}d',
                      style: TextStyle(
                        color: isExpired ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: staking.progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                isExpired ? AppColors.success : plan.color,
              ),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${loc.stakingEarned}: +${staking.earnedSoFar.toInt()} ITC',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (isExpired)
                GradientButton(
                  onTap: () async {
                    try {
                      AudioService.playSuccess();
                      await provider.claimStaking(staking.id);
                    } catch (e) {}
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${loc.stakingClaimed} +${staking.totalProfit.toInt()} ITC'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  gradient: AppColors.successGradient,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    loc.stakingClaim,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                GradientButton(
                  onTap: () async {
                    AudioService.playButtonTap();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text(loc.stakingEarlyUnstake, style: TextStyle(color: Colors.white)),
                        content: Text(
                          '${loc.stakingEarlyUnstakeConfirm}\n\n⚠️ ${loc.stakingPenalty}\n\n💰 ${loc.stakingAmount}: ${staking.lockedAmount.toInt()} ITC\n📈 ${loc.stakingProfit}: +${staking.totalProfit.toInt()} ITC',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(loc.cancel, style: TextStyle(color: Colors.white54)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            child: Text(loc.stakingUnstake),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await provider.earlyUnstake(staking.id);
                      } catch (e) {}
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.stakingUnstaked),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                  gradient: LinearGradient(colors: [AppColors.error, AppColors.secondaryDark]),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    loc.stakingUnstake,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(StakingPlan plan, DemoProvider provider, AppLocalizations loc, String langCode) {
    final canStake = provider.canStake(plan);
    final balance = provider.user?.itcBalance ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            plan.color.withValues(alpha: 0.15),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [plan.color, plan.color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: plan.color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(plan.emoji, style: TextStyle(fontSize: 28)),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.getName(langCode)} ${loc.vault}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${plan.lockAmount.toInt()} ITC • ${plan.lockDays} ${loc.daysLabel}',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: plan.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${plan.totalProfit.toInt()} ITC',
                  style: TextStyle(
                    color: plan.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlanStat(loc.stakingDaily, '+${plan.dailyProfit.toStringAsFixed(1)}'),
              _buildPlanStat(loc.stakingROI, '${plan.roi.toStringAsFixed(0)}%'),
              _buildPlanStat(loc.stakingMin, '${plan.lockAmount.toInt()}'),
            ],
          ),
          SizedBox(height: 12),
          GradientButton(
            onTap: canStake
                ? () async {
                    AudioService.playButtonTap();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text(loc.stakingConfirm, style: TextStyle(color: Colors.white)),
                        content: Text(
                          '${loc.stakingConfirmDesc}\n\n${plan.emoji} ${plan.getName(langCode)} ${loc.vault}\n${loc.stakingAmount}: ${plan.lockAmount.toInt()} ITC\n${loc.stakingDuration}: ${plan.lockDays} ${loc.daysLabel}\n${loc.stakingProfit}: +${plan.totalProfit.toInt()} ITC\n\n⚠️ ${loc.stakingPenalty}',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(loc.cancel, style: TextStyle(color: Colors.white54)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: plan.color),
                            child: Text(loc.stakingLock),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      bool success = false;
                      try {
                        success = await provider.stake(plan);
                      } catch (e) {}
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? loc.stakingSuccess : loc.stakingFailed),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    }
                  }
                : null,
            gradient: canStake
                ? LinearGradient(colors: [plan.color, plan.color.withValues(alpha: 0.7)])
                : LinearGradient(colors: [AppColors.grey600, AppColors.grey500]),
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                canStake ? loc.stakingLock : '${loc.stakingNeed} ${((plan.lockAmount - balance).abs()).toInt()} ITC',
                style: TextStyle(
                  color: canStake ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
