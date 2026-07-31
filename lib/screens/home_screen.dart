import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hamster_points/providers/demo_provider.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';
import 'package:hamster_points/widgets/daily_login_widget.dart';
import 'package:hamster_points/widgets/points_display.dart';
import 'package:hamster_points/widgets/gift_box_widget.dart';
import 'package:hamster_points/screens/visit_sites_screen.dart';
import 'package:hamster_points/screens/tasks_screen.dart';
import 'package:hamster_points/screens/market_screen.dart';
import 'package:hamster_points/screens/my_farm_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final List<String> pageTitles = [
      loc.home,
      loc.visitSites,
      loc.tasks,
      loc.market,
      loc.farm,
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(pageTitles[_currentIndex]),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<DemoProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            final provider = Provider.of<DemoProvider>(context, listen: false);
            await provider.reloadAll();
          },
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomePage(),
              _buildTabWithPadding(VisitSitesScreen()),
              _buildTabWithPadding(TasksScreen()),
              _buildTabWithPadding(MarketScreen()),
              _buildTabWithPadding(MyFarmScreen()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: Colors.white54,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: loc.home),
            BottomNavigationBarItem(icon: Icon(Icons.language), label: loc.visitSites),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: loc.tasks),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: loc.market),
            BottomNavigationBarItem(icon: Icon(Icons.pets), label: loc.farm),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Consumer<DemoProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        if (user == null) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 4,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdBanner(),
              SizedBox(height: 4),
              _buildHeader(user.name),
              SizedBox(height: 16),
              PointsDisplay(points: user.itcBalance),
              SizedBox(height: 24),
              DailyLoginWidget(
                streak: user.dailyLogin.streak,
                claimedToday: user.dailyLogin.claimedToday,
                onClaim: () => _claimDailyLogin(provider),
              ),
              SizedBox(height: 12),
              GiftBoxWidget(),
              SizedBox(height: 12),
              _buildAdBanner2(),
              SizedBox(height: 16),
              _buildQuickStats(provider),
              SizedBox(height: 16),
              _buildQuickActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabWithPadding(Widget child) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
      ),
      child: child,
    );
  }

  Widget _buildHeader(String name) {
    final loc = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${loc.welcome} $name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              loc.welcomeDesc,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdBanner() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.3),
            AppColors.gold.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign, color: AppColors.gold, size: 28),
                SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).adBannerPlaceholder,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).adBannerComingSoon,
                  style: TextStyle(
                    color: AppColors.gold.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner2() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.3),
            AppColors.purple.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryDark,
                      AppColors.surface,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign, color: AppColors.gold, size: 28),
                SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).adBannerPlaceholder,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).adBannerComingSoon,
                  style: TextStyle(
                    color: AppColors.gold.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DemoProvider provider) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            loc.today,
            '+${provider.dailyEarnings}',
            Icons.today,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            loc.week,
            '+${provider.weeklyEarnings}',
            Icons.calendar_view_week,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            loc.total,
            provider.user?.totalEarned.toStringAsFixed(2) ?? '0',
            Icons.account_balance_wallet,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final loc = AppLocalizations.of(context);
    return GlassContainer(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.quickActions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    loc.visitSites,
                    () => setState(() => _currentIndex = 1),
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    loc.tasks,
                    () => setState(() => _currentIndex = 2),
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    loc.animalStore,
                    () => setState(() => _currentIndex = 3),
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    loc.myFarm,
                    () => setState(() => _currentIndex = 4),
                    Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    loc.referral,
                    () => Navigator.pushNamed(context, '/referral'),
                    Colors.teal,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    loc.buySell,
                    () => Navigator.pushNamed(context, '/buy_sell'),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    loc.luckyWheel,
                    () => Navigator.pushNamed(context, '/wheel'),
                    Color(0xFFFFD700),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionCard(
                    loc.stakingTitle,
                    () => Navigator.pushNamed(context, '/staking'),
                    AppColors.gold,
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildActionCard(String title, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _claimDailyLogin(DemoProvider provider) async {
    try {
      final reward = await provider.claimDailyLogin();
      if (!mounted) return;
      final loc = AppLocalizations.of(context);

      if (reward > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.gotReward} $reward ITC'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.alreadyClaimed),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
