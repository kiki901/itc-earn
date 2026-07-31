import 'package:flutter/material.dart';
import 'package:hamster_points/l10n/app_localizations.dart';
import 'package:hamster_points/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, dynamic>> _pages(BuildContext context) => [
    {
      'title': AppLocalizations.of(context).onboardingTitle1,
      'description': AppLocalizations.of(context).onboardingDesc1,
      'icon': Icons.star,
      'color': AppColors.primary,
    },
    {
      'title': AppLocalizations.of(context).onboardingTitle2,
      'description': AppLocalizations.of(context).onboardingDesc2,
      'icon': Icons.pets,
      'color': AppColors.secondary,
    },
    {
      'title': AppLocalizations.of(context).onboardingTitle3,
      'description': AppLocalizations.of(context).onboardingDesc3,
      'icon': Icons.account_balance_wallet,
      'color': AppColors.accent,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages(context).length,
                itemBuilder: (context, index) {
                  final page = _pages(context)[index];
                  return _buildPage(page);
                },
              ),
            ),
            _buildPageIndicator(context),
            _buildButtons(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Container(
      color: page['color'],
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              page['icon'],
              size: 60,
              color: page['color'],
            ),
          ),
          SizedBox(height: 32),
          Text(
            page['title'],
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            page['description'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages(context).length, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.primary : AppColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                AppLocalizations.of(context).skip,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey600,
                ),
              ),
            )
          else
            SizedBox(width: 24),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _pages(context).length - 1) {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushReplacementNamed(context, '/auth');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentPage < _pages(context).length - 1 ? AppLocalizations.of(context).next : AppLocalizations.of(context).finish,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
