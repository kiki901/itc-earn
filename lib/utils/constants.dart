class AppConstants {
  AppConstants._();

  static const String appName = 'ITC Earn';
  static const String appVersion = '1.0.0';

  // ─── Legal URLs (host these on your website) ───
  static const String privacyPolicyUrl = 'https://itcearn.com/privacy-policy.html';
  static const String termsOfServiceUrl = 'https://itcearn.com/terms-of-service.html';
  static const String supportEmail = 'support@itcearn.com';

  // ─── Registration & Referral ───
  static const double registrationBonus = 3.0; // ITC
  static const double referralSignupBonus = 5.0; // ITC per signup

  // ─── Gift Box ───
  static const int giftBoxCooldownHours = 4;
  static const double giftBoxMinReward = 1.0;
  static const int giftBoxMaxReward = 5;

  // ─── Lucky Wheel ───
  static const int wheelCooldownHours = 24;
  static const int wheelPaidSpinCost = 2; // ITC per paid spin

  // ─── Daily Login ───
  static const List<int> dailyLoginRewards = [1, 2, 3, 4, 5, 6, 7];

  // ─── Animal System ───
  static const int animalLifespanDays = 90;
  static const int collectionIntervalHours = 12;

  // ─── Economy ───
  static const double itcPrice = 0.020; // USD per ITC
  static const double sellFeePercent = 0.10; // 10% sell fee
  static const int minWithdrawalUsd = 20;
  static const int minWithdrawalItc = 1000; // 1000 ITC = $20

  // ─── Tasks ───
  static const Map<String, int> taskRewards = {
    'ad': 3,
    'survey': 5,
    'download': 8,
    'social': 4,
    'visit': 2,
  };

  // ─── Visit Sites ───
  static const int defaultVisitTimeSeconds = 30;
  static const double defaultSiteReward = 2.0;

  // ─── Wallet Addresses ───
  static const String itcDepositAddress = 'PLACEHOLDER_WALLET_ADDRESS';
}
