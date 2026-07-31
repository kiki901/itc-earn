import 'package:flutter/material.dart';
import 'strings_ar.dart';
import 'strings_en.dart';
import 'strings_fr.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _strings;

  AppLocalizations(this.locale) {
    switch (locale.languageCode) {
      case 'fr':
        _strings = frStrings;
        break;
      case 'en':
        _strings = enStrings;
        break;
      default:
        _strings = arStrings;
    }
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get(String key) => _strings[key] ?? key;

  // ─── Navigation ───
  String get home => get('home');
  String get tasks => get('tasks');
  String get market => get('market');
  String get farm => get('farm');
  String get wallet => get('wallet');
  String get referral => get('referral');
  String get profile => get('profile');
  String get admin => get('admin');

  // ─── Auth ───
  String get login => get('login');
  String get signup => get('signup');
  String get logout => get('logout');
  String get name => get('name');
  String get enterName => get('enterName');
  String get email => get('email');
  String get enterEmail => get('enterEmail');
  String get invalidEmail => get('invalidEmail');
  String get password => get('password');
  String get enterPassword => get('enterPassword');
  String get passwordHint => get('passwordHint');
  String get confirmPassword => get('confirmPassword');
  String get passwordMismatch => get('passwordMismatch');
  String get noAccount => get('noAccount');
  String get hasAccount => get('hasAccount');
  String get createAccount => get('createAccount');
  String get privacyPolicy => get('privacyPolicy');
  String get termsOfService => get('termsOfService');

  // ─── Home ───
  String get welcome => get('welcome');
  String get welcomeDesc => get('welcomeDesc');
  String get quickActions => get('quickActions');
  String get visitSites => get('visitSites');
  String get animalStore => get('animalStore');
  String get myFarm => get('myFarm');
  String get today => get('today');
  String get week => get('week');
  String get total => get('total');

  // ─── Tasks ───
  String get all => get('all');
  String get ads => get('ads');
  String get surveys => get('surveys');
  String get download => get('download');
  String get noTasks => get('noTasks');
  String get completed => get('completed');
  String get startTask => get('startTask');
  String get taskDetails => get('taskDetails');
  String get reward => get('reward');
  String get taskDesc => get('taskDesc');
  String get noDescription => get('noDescription');
  String get steps => get('steps');
  String get step1 => get('step1');
  String get step2 => get('step2');
  String get step3 => get('step3');
  String get step4 => get('step4');
  String get step5 => get('step5');
  String get taskLink => get('taskLink');
  String get linkCopied => get('linkCopied');
  String get openInBrowser => get('openInBrowser');
  String get uploadScreenshot => get('uploadScreenshot');
  String get screenshotSelected => get('screenshotSelected');
  String get tapToChange => get('tapToChange');
  String get tapToSelect => get('tapToSelect');
  String get submitForReview => get('submitForReview');
  String get taskSubmitted => get('taskSubmitted');
  String get taskReviewMsg => get('taskReviewMsg');
  String get backToTasks => get('backToTasks');

  // ─── Sites ───
  String get noSites => get('noSites');
  String get seconds => get('seconds');
  String get visited => get('visited');
  String get visitSite => get('visitSite');
  String get wrongNumber => get('wrongNumber');
  String get visitSteps => get('visitSteps');
  String get visitStep1 => get('visitStep1');
  String get visitStep2 => get('visitStep2');
  String get visitStep3 => get('visitStep3');
  String get visitStep4 => get('visitStep4');
  String get siteLink => get('siteLink');
  String get countdown => get('countdown');
  String get remainingSeconds => get('remainingSeconds');
  String get openBrowserStartTimer => get('openBrowserStartTimer');
  String get captchaTitle => get('captchaTitle');
  String get captchaHint => get('captchaHint');
  String get enterNumber => get('enterNumber');
  String get verify => get('verify');
  String get success => get('success');
  String get backToSites => get('backToSites');

  // ─── Market ───
  String get marketTitle => get('marketTitle');
  String get marketDesc => get('marketDesc');
  String get buyWithITC => get('buyWithITC');
  String get confirmPurchase => get('confirmPurchase');
  String get cancel => get('cancel');
  String get buy => get('buy');
  String get purchased => get('purchased');
  String get insufficientBalance => get('insufficientBalance');
  String get buyWithCrypto => get('buyWithCrypto');

  // ─── Wallet ───
  String get walletTitle => get('walletTitle');
  String get itcWallet => get('itcWallet');
  String get itcInfo => get('itcInfo');
  String get currentBalance => get('currentBalance');
  String get availableTasks => get('availableTasks');
  String get collectFromTasks => get('collectFromTasks');
  String get store => get('store');
  String get buyAnimalsITC => get('buyAnimalsITC');
  String get transactionHistory => get('transactionHistory');
  String get noTransactions => get('noTransactions');

  // ─── Crypto ───
  String get itcWalletTitle => get('itcWalletTitle');
  String get balance => get('balance');
  String get deposit => get('deposit');
  String get withdraw => get('withdraw');
  String get depositITC => get('depositITC');
  String get depositViaITC => get('depositViaITC');
  String get depositAddress => get('depositAddress');
  String get amountITC => get('amountITC');
  String get txHash => get('txHash');
  String get enterTxHash => get('enterTxHash');
  String get sendRequest => get('sendRequest');
  String get depositPending => get('depositPending');
  String get withdrawITC => get('withdrawITC');
  String get availableBalance => get('availableBalance');
  String get walletAddress => get('walletAddress');
  String get enterWalletAddress => get('enterWalletAddress');
  String get withdrawPending => get('withdrawPending');

  // ─── Farm ───
  String get emptyFarm => get('emptyFarm');
  String get goToStore => get('goToStore');
  String get animals => get('animals');
  String get dailyProfitLabel => get('dailyProfitLabel');
  String get rareAnimalsShop => get('rareAnimalsShop');
  String get lifetimeLabel => get('lifetimeLabel');
  String get forever => get('forever');
  String get lifetimeAnimal => get('lifetimeAnimal');
  String get owned => get('owned');
  String get buyFor => get('buyFor');
  String get confirmBuyRare => get('confirmBuyRare');
  String get expired => get('expired');
  String get quantity => get('quantity');
  String get dailyProfitWith => get('dailyProfitWith');

  // ─── Referral ───
  String get referralsTitle => get('referralsTitle');
  String get active => get('active');
  String get yourReferralCode => get('yourReferralCode');
  String get copyCode => get('copyCode');
  String get shareCode => get('shareCode');
  String get referralRewards => get('referralRewards');
  String get perFriend => get('perFriend');
  String get enterReferralCode => get('enterReferralCode');
  String get enterReferralHint => get('enterReferralHint');
  String get codeField => get('codeField');
  String get apply => get('apply');
  String get codeCopied => get('codeCopied');
  String get joinHamsterPoints => get('joinHamsterPoints');
  String get useMyCode => get('useMyCode');
  String get getBonus => get('getBonus');
  String get shareSubject => get('shareSubject');
  String get enterCodeFirst => get('enterCodeFirst');
  String get cantUseOwnCode => get('cantUseOwnCode');
  String get alreadyUsedCode => get('alreadyUsedCode');
  String get codeApplied => get('codeApplied');
  String get invalidCode => get('invalidCode');

  // ─── Profile ───
  String get profileTitle => get('profileTitle');
  String get referralCode => get('referralCode');
  String get earned => get('earned');
  String get referrals => get('referrals');
  String get legal => get('legal');
  String get deleteAccount => get('deleteAccount');
  String get deleteConfirm => get('deleteConfirm');
  String get deleteWarning => get('deleteWarning');
  String get deleted => get('deleted');
  String get delete => get('delete');

  // ─── Admin ───
  String get dashboard => get('dashboard');
  String get users => get('users');
  String get reviews => get('reviews');
  String get sites => get('sites');
  String get totalUsers => get('totalUsers');
  String get totalIssued => get('totalIssued');
  String get yourBalance => get('yourBalance');
  String get addITC => get('addITC');
  String get deductITC => get('deductITC');
  String get addTask => get('addTask');
  String get addSite => get('addSite');
  String get noUsers => get('noUsers');
  String get noReviews => get('noReviews');
  String get approved => get('approved');
  String get rejected => get('rejected');
  String get pending => get('pending');
  String get approve => get('approve');
  String get reject => get('reject');
  String get taskTitle => get('taskTitle');
  String get siteTitle => get('siteTitle');
  String get type => get('type');
  String get title => get('title');
  String get description => get('description');
  String get link => get('link');
  String get waitTime => get('waitTime');
  String get add => get('add');
  String get edit => get('edit');
  String get save => get('save');
  String get siteName => get('siteName');
  String get url => get('url');
  String get time => get('time');
  String get deleteConfirmUser => get('deleteConfirmUser');
  String get manageStore => get('manageStore');
  String get addAnimal => get('addAnimal');
  String get noAnimals => get('noAnimals');
  String get inactive => get('inactive');
  String get priceDaily => get('priceDaily');
  String get emoji => get('emoji');
  String get dailyITC => get('dailyITC');
  String get depositRequests => get('depositRequests');
  String get withdrawRequests => get('withdrawRequests');
  String get noDepositRequests => get('noDepositRequests');
  String get noWithdrawRequests => get('noWithdrawRequests');
  String get walletAddr => get('walletAddr');

  // ─── Daily Login ───
  String get dailyLogin => get('dailyLogin');
  String get available => get('available');
  String get consecutiveDays => get('consecutiveDays');
  String get claimedToday => get('claimedToday');
  String get claimReward => get('claimReward');
  String get alreadyClaimed => get('alreadyClaimed');
  String get gotReward => get('gotReward');

  // ─── Onboarding ───
  String get onboardingTitle1 => get('onboardingTitle1');
  String get onboardingDesc1 => get('onboardingDesc1');
  String get onboardingTitle2 => get('onboardingTitle2');
  String get onboardingDesc2 => get('onboardingDesc2');
  String get onboardingTitle3 => get('onboardingTitle3');
  String get onboardingDesc3 => get('onboardingDesc3');
  String get skip => get('skip');
  String get next => get('next');
  String get finish => get('finish');

  // ─── Splash ───
  String get splashTagline => get('splashTagline');

  // ─── Common ───
  String get loading => get('loading');
  String get error => get('error');
  String get errorLoadingData => get('errorLoadingData');
  String get noEmail => get('noEmail');
  String get ok => get('ok');
  String get yes => get('yes');
  String get no => get('no');
  String get close => get('close');
  String get itc => 'ITC';

  // ─── Animal Names ───
  String get chicken => get('chicken');
  String get cow => get('cow');
  String get dog => get('dog');
  String get horse => get('horse');
  String get elephant => get('elephant');
  String get dragon => get('dragon');
  String get lion => get('lion');
  String get phoenix => get('phoenix');
  String get unicorn => get('unicorn');

  // Password Reset
  String get forgotPassword => get('forgotPassword');
  String get resetPassword => get('resetPassword');
  String get resetPasswordHint => get('resetPasswordHint');
  String get newPassword => get('newPassword');
  String get confirmNewPassword => get('confirmNewPassword');
  String get resetPasswordSuccess => get('resetPasswordSuccess');
  String get reset => get('reset');
  String get emailNotRegistered => get('emailNotRegistered');
  String get passwordTooShort => get('passwordTooShort');
  String get enterValidEmail => get('enterValidEmail');
  String get verificationCode => get('verificationCode');
  String get emailNotFound => get('emailNotFound');
  String get send => get('send');

  // Gift Box
  String get giftBox => get('giftBox');
  String get giftBoxDesc => get('giftBoxDesc');
  String get giftBoxAvailable => get('giftBoxAvailable');
  String get giftBoxCooldown => get('giftBoxCooldown');
  String get giftBoxOpen => get('giftBoxOpen');
  String get giftBoxCongrats => get('giftBoxCongrats');
  String get giftBoxReward => get('giftBoxReward');
  String get giftBoxGift => get('giftBoxGift');
  String get giftBoxNext => get('giftBoxNext');
  String get giftBoxHours => get('giftBoxHours');
  String get giftBoxMinutes => get('giftBoxMinutes');
  String get giftBoxSeconds => get('giftBoxSeconds');

  // Lucky Wheel
  String get luckyWheel => get('luckyWheel');
  String get spinNow => get('spinNow');
  String get spinning => get('spinning');
  String get wheelAvailable => get('wheelAvailable');
  String get wheelCooldown => get('wheelCooldown');
  String get wheelCongrats => get('wheelCongrats');
  String get youGot => get('youGot');
  String get nextWheel => get('nextWheel');

  // ─── Task Categories ───
  String get taskCategorySocial => get('taskCategorySocial');
  String get taskCategoryVisit => get('taskCategoryVisit');

  // ─── Market extras ───
  String get dailyProfit => get('dailyProfit');
  String get needMoreItc => get('needMoreItc');
  String get additionalItc => get('additionalItc');
  String get buyAnimalConfirm => get('buyAnimalConfirm');
  String get forPrice => get('forPrice');
  String get dailyReward => get('dailyReward');
  String get purchaseSuccess => get('purchaseSuccess');
  String get operationFailed => get('operationFailed');
  String get costLabel => get('costLabel');
  String get balanceLabel => get('balanceLabel');

  // ─── Lucky Wheel (additional) ───
  String get wheelAvailableInHours => get('wheelAvailableInHours');
  String get hours => get('hours');
  String get minutes => get('minutes');
  String get congratulations => get('congratulations');
  String get freeChicken => get('freeChicken');
  String get doubleProfit => get('doubleProfit');
  String get freeSpin => get('freeSpin');
  String get wheelAvailableNow => get('wheelAvailableNow');
  String get spin => get('spin');
  String get wheelTitle => get('wheelTitle');
  String get buySpinAgain => get('buySpinAgain');
  String get confirmBuySpin => get('confirmBuySpin');
  String get insufficientBalanceForSpin => get('insufficientBalanceForSpin');
  String get adBannerPlaceholder => get('adBannerPlaceholder');
  String get adBannerComingSoon => get('adBannerComingSoon');

  // Staking
  String get stakingTitle => get('stakingTitle');
  String get stakingDesc => get('stakingDesc');
  String get stakingPlans => get('stakingPlans');
  String get stakingActive => get('stakingActive');
  String get stakingTotalStaked => get('stakingTotalStaked');
  String get stakingTotalProfit => get('stakingTotalProfit');
  String get stakingNoActive => get('stakingNoActive');
  String get stakingActiveStakings => get('stakingActiveStakings');
  String get stakingReady => get('stakingReady');
  String get stakingEarned => get('stakingEarned');
  String get stakingClaim => get('stakingClaim');
  String get stakingClaimed => get('stakingClaimed');
  String get stakingEarlyUnstake => get('stakingEarlyUnstake');
  String get stakingEarlyUnstakeConfirm => get('stakingEarlyUnstakeConfirm');
  String get stakingPenalty => get('stakingPenalty');
  String get stakingUnstake => get('stakingUnstake');
  String get stakingUnstaked => get('stakingUnstaked');
  String get stakingConfirm => get('stakingConfirm');
  String get stakingConfirmDesc => get('stakingConfirmDesc');
  String get stakingAmount => get('stakingAmount');
  String get stakingDuration => get('stakingDuration');
  String get stakingProfit => get('stakingProfit');
  String get stakingLock => get('stakingLock');
  String get stakingSuccess => get('stakingSuccess');
  String get stakingFailed => get('stakingFailed');
  String get stakingNeed => get('stakingNeed');
  String get stakingDaily => get('stakingDaily');
  String get stakingROI => get('stakingROI');
  String get stakingMin => get('stakingMin');
  String get buySell => get('buySell');

  // ─── Exchange ───
  String get exchangeTitle => get('exchangeTitle');
  String get buyITC => get('buyITC');
  String get sellITC => get('sellITC');
  String get depositUSD => get('depositUSD');
  String get currentPrice => get('currentPrice');
  String get orderBook => get('orderBook');
  String get tradeHistory => get('tradeHistory');
  String get marketStats => get('marketStats');
  String get portfolio => get('portfolio');
  String get availableBalanceUSD => get('availableBalanceUSD');
  String get totalCost => get('totalCost');
  String get totalRevenue => get('totalRevenue');
  String get tradeSuccess => get('tradeSuccess');
  String get depositPendingApproval => get('depositPendingApproval');
  String get withdrawPendingApproval => get('withdrawPendingApproval');
  String get paymentMethod => get('paymentMethod');
  String get setBasePrice => get('setBasePrice');
  String get exchangePendingDeposits => get('exchangePendingDeposits');
  String get exchangePendingWithdrawals => get('exchangePendingWithdrawals');
  String get deleteUserWarning => get('deleteUserWarning');
  String get deleteAnimalWarning => get('deleteAnimalWarning');

  // ─── Buy/Sell Screen ───
  String get buySellTitle => get('buySellTitle');
  String get enterValidAmount => get('enterValidAmount');
  String get requestSentSuccess => get('requestSentSuccess');
  String get marketValue => get('marketValue');
  String get marketPrice => get('marketPrice');
  String get amountInUsd => get('amountInUsd');
  String get sellFee => get('sellFee');
  String get youWillReceive => get('youWillReceive');
  String get netAmountBelowMin => get('netAmountBelowMin');
  String get sendVia => get('sendVia');
  String get receiveVia => get('receiveVia');
  String get sendToAddress => get('sendToAddress');
  String get sendItcTo => get('sendItcTo');
  String get copied => get('copied');
  String get walletAddressHint => get('walletAddressHint');
  String get txHashHint => get('txHashHint');
  String get submitBuyRequest => get('submitBuyRequest');
  String get submitSellRequest => get('submitSellRequest');
  String get yourRequests => get('yourRequests');
  String get pendingStatus => get('pendingStatus');
  String get approvedStatus => get('approvedStatus');
  String get rejectedStatus => get('rejectedStatus');
  String get minWithdrawalMsg => get('minWithdrawalMsg');
  String get howMuchBuy => get('howMuchBuy');
  String get howMuchSell => get('howMuchSell');
  String get buyLabel => get('buyLabel');
  String get sellLabel => get('sellLabel');
  String get buySellItc => get('buySellItc');

  // ─── Farm Screen ───
  String get maintenance => get('maintenance');
  String get boostInstant => get('boostInstant');
  String get maintenanceConfirm => get('maintenanceConfirm');
  String get maintenanceConfirmSuffix => get('maintenanceConfirmSuffix');
  String get pay => get('pay');
  String get maintenanceDone => get('maintenanceDone');

  // ─── Admin Buy/Sell Tab ───
  String get noPendingRequests => get('noPendingRequests');
  String get adminUser => get('adminUser');
  String get adminEmail => get('adminEmail');
  String get transactionId => get('transactionId');
  String get userWallet => get('userWallet');
  String get rejectAction => get('rejectAction');
  String get insufficientUserBalance => get('insufficientUserBalance');

  // ─── Staking extras ───
  String get vault => get('vault');
  String get itcLocked => get('itcLocked');
  String get daysLabel => get('daysLabel');
  String get languageLabel => get('languageLabel');
  String get appName => get('appName');

  // ─── Helpers (time ago, time until) ───
  String timeAgoYears(int years) => get('timeAgoYears').replaceAll('{count}', '$years');
  String timeAgoMonths(int months) => get('timeAgoMonths').replaceAll('{count}', '$months');
  String timeAgoDays(int days) => get('timeAgoDays').replaceAll('{count}', '$days');
  String timeAgoHours(int hours) => get('timeAgoHours').replaceAll('{count}', '$hours');
  String timeAgoMinutes(int minutes) => get('timeAgoMinutes').replaceAll('{count}', '$minutes');
  String get timeAgoNow => get('timeAgoNow');
  String timeUntilHoursMinutes(int hours, int minutes) => get('timeUntilHoursMinutes').replaceAll('{hours}', '$hours').replaceAll('{minutes}', '$minutes');
  String timeUntilMinutesOnly(int minutes) => get('timeUntilMinutesOnly').replaceAll('{minutes}', '$minutes');
  String get confirm => get('confirm');

  // ─── Privacy Policy ───
  String get privacyTitle => get('privacyTitle');
  String get privacyUpdated => get('privacyUpdated');
  String get privacySection1Title => get('privacySection1Title');
  String get privacySection1Content => get('privacySection1Content');
  String get privacySection2Title => get('privacySection2Title');
  String get privacySection2Content => get('privacySection2Content');
  String get privacySection3Title => get('privacySection3Title');
  String get privacySection3Content => get('privacySection3Content');
  String get privacySection4Title => get('privacySection4Title');
  String get privacySection4Content => get('privacySection4Content');
  String get privacySection5Title => get('privacySection5Title');
  String get privacySection5Content => get('privacySection5Content');
  String get privacySection6Title => get('privacySection6Title');
  String get privacySection6Content => get('privacySection6Content');
  String get privacySection7Title => get('privacySection7Title');
  String get privacySection7Content => get('privacySection7Content');
  String get privacySection8Title => get('privacySection8Title');
  String get privacySection8Content => get('privacySection8Content');
  String get privacySection9Title => get('privacySection9Title');
  String get privacySection9Content => get('privacySection9Content');

  // ─── Terms of Service ───
  String get termsTitle => get('termsTitle');
  String get termsUpdated => get('termsUpdated');
  String get termsSection1Title => get('termsSection1Title');
  String get termsSection1Content => get('termsSection1Content');
  String get termsSection2Title => get('termsSection2Title');
  String get termsSection2Content => get('termsSection2Content');
  String get termsSection3Title => get('termsSection3Title');
  String get termsSection3Content => get('termsSection3Content');
  String get termsSection4Title => get('termsSection4Title');
  String get termsSection4Content => get('termsSection4Content');
  String get termsSection5Title => get('termsSection5Title');
  String get termsSection5Content => get('termsSection5Content');
  String get termsSection6Title => get('termsSection6Title');
  String get termsSection6Content => get('termsSection6Content');
  String get termsSection7Title => get('termsSection7Title');
  String get termsSection7Content => get('termsSection7Content');
  String get termsSection8Title => get('termsSection8Title');
  String get termsSection8Content => get('termsSection8Content');
  String get termsSection9Title => get('termsSection9Title');
  String get termsSection9Content => get('termsSection9Content');
  String get termsSection10Title => get('termsSection10Title');
  String get termsSection10Content => get('termsSection10Content');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
