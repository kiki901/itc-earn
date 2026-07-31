import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hamster_points/models/user_model.dart';
import 'package:hamster_points/models/transaction_model.dart';
import 'package:hamster_points/models/animal_model.dart';
import 'package:hamster_points/models/staking_model.dart';
import 'package:hamster_points/models/crypto_model.dart';
import 'package:hamster_points/utils/constants.dart';

class DemoService {
  static final DemoService _instance = DemoService._internal();
  factory DemoService() => _instance;
  DemoService._internal();

  // SharedPreferences keys
  static const String _keyAllUsers = 'all_users';
  static const String _keyCurrentUserEmail = 'current_user_email';
  static const String _keyAdminTasks = 'admin_tasks';
  static const String _keyAdminSites = 'admin_sites';
  static const String _keyAdminAnimals = 'admin_animals';
  static const String _keyPendingReviews = 'pending_task_reviews';
  static const String _keyWithdrawals = 'withdrawal_requests';
  static const String _keyDeposits = 'deposit_requests';
  static const String _keyPrefixTx = 'tx_';
  static const String _keyPrefixAnimals = 'animals_';
  static const String _keyPrefixStakings = 'stakings_';
  static const String _keyPrefixGiftBox = 'giftbox_last_claimed_';
  static const String _keyPrefixWheel = 'daily_prize_last_';
  static const String _keyBuySellRequests = 'buy_sell_requests';
  static const String _keyAdminUsdBalance = 'admin_usd_balance';

  SharedPreferences? _prefs;
  UserModel? _currentUser;
  bool _isBusy = false;
  double _adminUsdBalance = 0.0;
  List<TransactionModel> _transactions = [];
  List<UserAnimal> _userAnimals = [];
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _allTasks = [];
  List<Map<String, dynamic>> _allSites = [];
  List<Map<String, dynamic>> _allAnimals = [];
  List<Map<String, dynamic>> _pendingTaskReviews = [];
  List<Map<String, dynamic>> _withdrawalRequests = [];
  List<Map<String, dynamic>> _depositRequests = [];

  static String _hashPassword(String password) {
    final bytes = utf8.encode('nexora_salt_$password');
    final digest = sha256.convert(bytes);
    return 'h:${digest.toString()}';
  }

  static bool _verifyPassword(String password, String stored) {
    if (!stored.startsWith('h:')) return password == stored;
    return _hashPassword(password) == stored;
  }
  List<Map<String, dynamic>> _buySellRequests = [];
  List<UserStaking> _userStakings = [];

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get transactions => _transactions;
  List<UserAnimal> get userAnimals => _userAnimals;
  bool get isAdmin => _currentUser?.email?.toLowerCase() == _adminEmail.toLowerCase();
  List<Map<String, dynamic>> get allUsers => _allUsers;
  List<Map<String, dynamic>> get allTasks => _allTasks;
  List<Map<String, dynamic>> get pendingTaskReviews => _pendingTaskReviews;
  List<Map<String, dynamic>> get allSites => _allSites;
  List<Map<String, dynamic>> get allAnimals => _allAnimals;
  List<Map<String, dynamic>> get withdrawalRequests => _withdrawalRequests;
  List<Map<String, dynamic>> get depositRequests => _depositRequests;
  List<UserStaking> get userStakings => _userStakings;

  // ─── Gift Box ───

  bool get isGiftBoxAvailable {
    if (_currentUser == null) return false;
    final lastClaimed = _prefs?.getString('$_keyPrefixGiftBox${_currentUser!.uid}');
    if (lastClaimed == null) return true;
    final lastTime = DateTime.tryParse(lastClaimed);
    if (lastTime == null) return true;
    return DateTime.now().difference(lastTime).inHours >= AppConstants.giftBoxCooldownHours;
  }

  Duration get timeUntilNextGiftBox {
    if (_currentUser == null) return Duration(hours: AppConstants.giftBoxCooldownHours);
    final lastClaimed = _prefs?.getString('$_keyPrefixGiftBox${_currentUser!.uid}');
    if (lastClaimed == null) return Duration.zero;
    final lastTime = DateTime.tryParse(lastClaimed);
    if (lastTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(lastTime);
    final remaining = Duration(hours: AppConstants.giftBoxCooldownHours) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<double> claimGiftBox() async {
    if (_currentUser == null || !isGiftBoxAvailable || _isBusy) return 0;
    _isBusy = true;

    try {
      final random = Random.secure();
      final double reward = (random.nextInt(AppConstants.giftBoxMaxReward) + AppConstants.giftBoxMinReward).toDouble();

      _currentUser = _currentUser!.copyWith(
        itcBalance: _currentUser!.itcBalance + reward,
        totalEarned: _currentUser!.totalEarned + reward,
      );

      await _prefs?.setString('$_keyPrefixGiftBox${_currentUser!.uid}', DateTime.now().toIso8601String());

      _addTransaction('earn', reward, 'صندوق مجاني');
      await _saveCurrentUser();
      await _saveUserTransactions();
      return reward;
    } finally {
      _isBusy = false;
    }
  }

  // ─── Lucky Wheel ───

  bool get isWheelAvailable {
    if (_currentUser == null) return false;
    final lastSpin = _prefs?.getString('$_keyPrefixWheel${_currentUser!.uid}');
    if (lastSpin == null) return true;
    final lastTime = DateTime.tryParse(lastSpin);
    if (lastTime == null) return true;
    return DateTime.now().difference(lastTime).inHours >= 24;
  }

  Duration get timeUntilNextWheel {
    if (_currentUser == null) return Duration(hours: 24);
    final lastSpin = _prefs?.getString('$_keyPrefixWheel${_currentUser!.uid}');
    if (lastSpin == null) return Duration.zero;
    final lastTime = DateTime.tryParse(lastSpin);
    if (lastTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(lastTime);
    final remaining = Duration(hours: 24) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> spinWheel(String prizeType, double prizeValue) async {
    if (_currentUser == null || _isBusy) return;
    _isBusy = true;

    try {

    switch (prizeType) {
      case 'itc':
        await _prefs?.setString('$_keyPrefixWheel${_currentUser!.uid}', DateTime.now().toIso8601String());
        _currentUser = _currentUser!.copyWith(
          itcBalance: _currentUser!.itcBalance + prizeValue,
          totalEarned: _currentUser!.totalEarned + prizeValue,
        );
        _addTransaction('earn', prizeValue, 'جائزة يومية - ${prizeValue.toInt()} ITC');
        break;
      case 'topprize':
        await _prefs?.setString('$_keyPrefixWheel${_currentUser!.uid}', DateTime.now().toIso8601String());
        _currentUser = _currentUser!.copyWith(
          itcBalance: _currentUser!.itcBalance + prizeValue,
          totalEarned: _currentUser!.totalEarned + prizeValue,
        );
        _addTransaction('earn', prizeValue, 'جائزة يومية - مكافأة كبرى ${prizeValue.toInt()} ITC');
        break;
      case 'boost':
        await _prefs?.setString('$_keyPrefixWheel${_currentUser!.uid}', DateTime.now().toIso8601String());
        _currentUser = _currentUser!.copyWith(
          itcBalance: _currentUser!.itcBalance + prizeValue,
          totalEarned: _currentUser!.totalEarned + prizeValue,
        );
        _addTransaction('earn', prizeValue, 'جائزة يومية - مكافأة بوست');
        break;
      case 'freeroll':
        _addTransaction('earn', 0, 'جائزة يومية - دورة مجانية إضافية');
        break;
    }

    await _saveCurrentUser();
    await _saveUserTransactions();
    } finally {
      _isBusy = false;
    }
  }

  // ─── Staking / Farming Boost ───

  double get totalStaked {
    double total = 0;
    for (final s in _userStakings) {
      if (!s.claimed) total += s.lockedAmount;
    }
    return total;
  }

  double get totalStakingProfit {
    double total = 0;
    for (final s in _userStakings) {
      if (!s.claimed) total += s.earnedSoFar;
    }
    return total;
  }

  bool canStake(StakingPlan plan) {
    if (_currentUser == null) return false;
    if (_currentUser!.itcBalance < plan.lockAmount) return false;
    final activeCount = _userStakings.where((s) => !s.claimed && !s.isExpired).length;
    if (activeCount >= 5) return false;
    return true;
  }

  Future<bool> stake(StakingPlan plan) async {
    if (_currentUser == null || !canStake(plan) || _isBusy) return false;
    _isBusy = true;

    try {

    _currentUser = _currentUser!.copyWith(
      itcBalance: _currentUser!.itcBalance - plan.lockAmount,
    );

    final staking = UserStaking(
      id: 'stake_${DateTime.now().millisecondsSinceEpoch}',
      tier: plan.tier,
      lockedAmount: plan.lockAmount,
      stakedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: plan.lockDays)),
      totalProfit: plan.totalProfit,
    );

    _userStakings.add(staking);
    _addTransaction('spend', plan.lockAmount, 'إيداع في خزنة ${plan.nameAr}');

    await _saveUserStakings();
    await _saveCurrentUser();
    await _saveUserTransactions();
    return true;
    } finally {
      _isBusy = false;
    }
  }

  Future<double> claimStaking(String stakingId) async {
    if (_currentUser == null || _isBusy) return 0;
    _isBusy = true;

    try {
      final index = _userStakings.indexWhere((s) => s.id == stakingId);
      if (index == -1) return 0;

      final staking = _userStakings[index];
      if (staking.claimed) return 0;
      if (!staking.isExpired) return 0;

      final profit = staking.totalProfit;
      _userStakings[index] = staking.copyWith(claimed: true);

      _currentUser = _currentUser!.copyWith(
        itcBalance: _currentUser!.itcBalance + staking.lockedAmount + profit,
        totalEarned: _currentUser!.totalEarned + profit,
      );

      _addTransaction('earn', profit, 'أرباح خزنة ${StakingPlan.getPlan(staking.tier).nameAr}');
      _addTransaction('earn', staking.lockedAmount, 'إرجاع رأس مال الخزنة');

      await _saveUserStakings();
      await _saveCurrentUser();
      await _saveUserTransactions();
      return profit;
    } finally {
      _isBusy = false;
    }
  }

  Future<double> earlyUnstake(String stakingId) async {
    if (_currentUser == null || _isBusy) return 0;
    _isBusy = true;

    try {
      final index = _userStakings.indexWhere((s) => s.id == stakingId);
      if (index == -1) return 0;

      final staking = _userStakings[index];
      if (staking.claimed) return 0;
      if (staking.isExpired) return 0;

      final penalty = staking.totalProfit; // lose ALL profits on early unstake
      final returnedAmount = staking.lockedAmount; // get back only the locked amount

      _userStakings[index] = staking.copyWith(claimed: true);

      _currentUser = _currentUser!.copyWith(
        itcBalance: _currentUser!.itcBalance + returnedAmount,
      );

      _addTransaction('earn', returnedAmount, 'إرجاع رأس مال الخزنة (سحب مبكر)');
      if (penalty > 0) {
        _addTransaction('spend', penalty, 'غرامة سحب مبكر');
      }

      await _saveUserStakings();
      await _saveCurrentUser();
      await _saveUserTransactions();
      return returnedAmount;
    } finally {
      _isBusy = false;
    }
  }

  void _loadUserStakings() {
    if (_currentUser == null) return;
    final raw = _prefs?.getString('$_keyPrefixStakings${_currentUser!.uid}') ?? '[]';
    try {
      final decoded = json.decode(raw);
      _userStakings = (decoded as List).map((e) => UserStaking.fromMap(e)).toList();
    } catch (_) {
      _userStakings = [];
    }
  }

  Future<void> _saveUserStakings() async {
    if (_currentUser == null) return;
    final data = _userStakings.map((s) => s.toMap()).toList();
    await _prefs?.setString('$_keyPrefixStakings${_currentUser!.uid}', json.encode(data));
  }

  Future<Map<String, dynamic>?> paidSpinWheel() async {
    if (_currentUser == null || _isBusy) return null;
    if (_currentUser!.itcBalance < AppConstants.wheelPaidSpinCost) return null;
    _isBusy = true;

    try {

    _currentUser = _currentUser!.copyWith(
      itcBalance: _currentUser!.itcBalance - AppConstants.wheelPaidSpinCost,
    );
    _addTransaction('spend', AppConstants.wheelPaidSpinCost.toDouble(), 'شراء جولة إضافية');

    final random = Random.secure();
    final List<Map<String, dynamic>> prizes = [
      {'type': 'itc', 'value': 2.0},
      {'type': 'itc', 'value': 3.0},
      {'type': 'itc', 'value': 5.0},
      {'type': 'freeroll', 'value': 0.0},
      {'type': 'itc', 'value': 4.0},
      {'type': 'topprize', 'value': 5.0},
    ];
    final prize = prizes[random.nextInt(prizes.length)];

    switch (prize['type']) {
      case 'itc':
      case 'topprize':
        final double value = prize['value'] as double;
        _currentUser = _currentUser!.copyWith(
          itcBalance: _currentUser!.itcBalance + value,
          totalEarned: _currentUser!.totalEarned + value,
        );
        _addTransaction('earn', value, 'جائزة يومية (مدفوعة) - ${value.toInt()} ITC');
        break;
      case 'freeroll':
        _addTransaction('earn', 0, 'جائزة يومية (مدفوعة) - دورة مجانية إضافية');
        break;
    }

    await _saveCurrentUser();
    await _saveUserTransactions();
    await _saveUserAnimals();
    return prize;
    } finally {
      _isBusy = false;
    }
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAllUsers();
    _loadPendingReviews();
    _loadTasks();
    _loadSites();
    _loadAnimals();
    _loadWithdrawals();
    _loadDeposits();
    _loadBuySellRequests();
    _adminUsdBalance = _prefs?.getDouble(_keyAdminUsdBalance) ?? 0.0;
    _seedDefaultAccounts();
    await _loadCurrentUser();
  }

  void _seedDefaultAccounts() {
    final emails = _allUsers.map((u) => u['email']).toList();

    if (!emails.contains('mitidjadido@gmail.com')) {
      final admin = UserModel(
        uid: 'admin_001',
        name: 'المدير',
        email: 'mitidjadido@gmail.com',
        itcBalance: 10000000000,
        totalEarned: 10000000000,
        referralCode: 'HPADMIN',
        dailyLogin: DailyLoginData(streak: 7, claimedToday: false),
        createdAt: DateTime.now().subtract(Duration(days: 90)),
        lastActive: DateTime.now(),
      );
      final adminMap = admin.toMap();
      adminMap['password'] = _hashPassword('chimaxAS\$40');
      _allUsers.add(adminMap);
    }

    _prefs?.setString(_keyAllUsers, json.encode(_allUsers));
  }

  DailyLoginData _computeDailyLoginState(DailyLoginData dailyLogin) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    bool resetClaimed = false;
    int currentStreak = dailyLogin.streak;

    if (dailyLogin.lastLogin != null) {
      final lastDate = DateTime(dailyLogin.lastLogin!.year, dailyLogin.lastLogin!.month, dailyLogin.lastLogin!.day);
      final daysDiff = todayDate.difference(lastDate).inDays;

      if (daysDiff > 1) {
        currentStreak = 0;
        resetClaimed = true;
      } else if (daysDiff >= 1) {
        resetClaimed = true;
      }
    } else {
      resetClaimed = true;
    }

    return DailyLoginData(
      lastLogin: dailyLogin.lastLogin,
      streak: currentStreak,
      claimedToday: resetClaimed ? false : dailyLogin.claimedToday,
    );
  }

  Future<void> _loadCurrentUser() async {
    final email = _prefs?.getString(_keyCurrentUserEmail);
    if (email != null) {
      final users = _getAllUsersList();
      final match = users.where((u) => u['email'] == email).toList();
      if (match.isNotEmpty) {
        final userData = match.first;
        final dailyLogin = DailyLoginData.fromMap(userData['dailyLogin'] ?? {});
        final updatedDailyLogin = _computeDailyLoginState(dailyLogin);

        _currentUser = UserModel(
          uid: userData['uid'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'],
          itcBalance: (userData['itcBalance'] ?? 0).toDouble(),
          totalEarned: (userData['totalEarned'] ?? 0).toDouble(),
          referralCode: userData['referralCode'] ?? '',
          dailyLogin: updatedDailyLogin,
          createdAt: DateTime.tryParse(userData['createdAt'] ?? '') ?? DateTime.now(),
          lastActive: DateTime.now(),
        );
        _loadUserTransactions();
        _loadUserAnimals();
        _loadUserStakings();
        await _saveCurrentUser();
      }
    }
  }

  List<Map<String, dynamic>> _getAllUsersList() {
    final raw = _prefs?.getString(_keyAllUsers) ?? '[]';
    try {
      final decoded = json.decode(raw);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (_) {
      return [];
    }
  }

  void _loadAllUsers() {
    _allUsers = _getAllUsersList();
  }

  List<Map<String, dynamic>> _getDefaultTasks() {
    return [
      {'id': '1', 'type': 'ad', 'title': 'شاهد إعلاناً مكافئاً', 'description': 'شاهد إعلاناً مدته 30 ثانية', 'reward': 1, 'emoji': '📺', 'url': 'https://example.com/ad1', 'time': 15, 'active': true},
      {'id': '2', 'type': 'survey', 'title': 'أجب على استطلاع سريع', 'description': '3 أسئلة بسيطة', 'reward': 1, 'emoji': '📝', 'url': 'https://example.com/survey1', 'time': 20, 'active': true},
      {'id': '3', 'type': 'download', 'title': 'حمّل تطبيق مكافآت', 'description': 'حمّل التطبيق وافتحه', 'reward': 2, 'emoji': '📱', 'url': 'https://example.com/app1', 'time': 25, 'active': true},
      {'id': '4', 'type': 'social', 'title': 'تابع حساب تويتر', 'description': 'تابع الحساب الرسمي', 'reward': 1, 'emoji': '👥', 'url': 'https://example.com/social1', 'time': 15, 'active': true},
      {'id': '5', 'type': 'ad', 'title': 'شاهد فيديو تعليمي', 'description': 'فيديو قصير عن التكنولوجيا', 'reward': 1, 'emoji': '📺', 'url': 'https://example.com/video1', 'time': 15, 'active': true},
    ];
  }

  List<Map<String, dynamic>> _getDefaultSites() {
    return [
      {'id': '1', 'title': 'موقع تعليمي', 'url': 'https://example1.com', 'reward': 0.5, 'time': 15, 'active': true},
      {'id': '2', 'title': 'مدونة تقنية', 'url': 'https://example2.com', 'reward': 1, 'time': 20, 'active': true},
      {'id': '3', 'title': 'منصة تعليمية', 'url': 'https://example3.com', 'reward': 1, 'time': 25, 'active': true},
      {'id': '4', 'title': 'أخبار التقنية', 'url': 'https://example4.com', 'reward': 1, 'time': 15, 'active': true},
      {'id': '5', 'title': 'موقع عروض', 'url': 'https://example5.com', 'reward': 0.5, 'time': 30, 'active': true},
    ];
  }

  void _loadUserTransactions() {
    if (_currentUser == null) return;
    final raw = _prefs?.getString('tx_${_currentUser!.uid}') ?? '[]';
    try {
      final decoded = json.decode(raw);
      _transactions = (decoded as List).map((e) => TransactionModel.fromMap(e)).toList();
    } catch (_) {
      _transactions = [];
    }
  }

  void _loadUserAnimals() {
    if (_currentUser == null) return;
    final raw = _prefs?.getString('animals_${_currentUser!.uid}') ?? '[]';
    try {
      final decoded = json.decode(raw);
      _userAnimals = (decoded as List).map((e) => UserAnimal.fromMap(e)).toList();
    } catch (_) {
      _userAnimals = [];
    }
  }

  Future<void> _saveAllUsers() async {
    try {
      final usersData = _allUsers.map((u) => Map<String, dynamic>.from(u)).toList();
      await _prefs?.setString(_keyAllUsers, json.encode(usersData));
    } catch (e) {
      debugPrint('Error saving all users: $e');
    }
  }

  Future<void> _saveCurrentUser() async {
    if (_currentUser == null) return;
    try {
      await _prefs?.setString(_keyCurrentUserEmail, _currentUser!.email ?? '');

      final users = _getAllUsersList();
      final index = users.indexWhere((u) => u['email'] == _currentUser!.email);
      final userData = _currentUser!.toMap();
      if (index != -1) {
        final existingPassword = users[index]['password'];
        userData['password'] = existingPassword;
        users[index] = userData;
      } else {
        final existingInMemory = _allUsers.firstWhere(
          (u) => u['email'] == _currentUser!.email,
          orElse: () => {},
        );
        userData['password'] = existingInMemory['password'] ?? '';
        users.add(userData);
      }
      _allUsers = users;
      await _prefs?.setString(_keyAllUsers, json.encode(users));
    } catch (e) {
      debugPrint('Error saving current user: $e');
    }
  }

  Future<void> _saveUserTransactions() async {
    if (_currentUser == null) return;
    try {
      final txData = _transactions.map((tx) => tx.toMap()).toList();
      await _prefs?.setString('tx_${_currentUser!.uid}', json.encode(txData));
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  Future<void> _saveUserAnimals() async {
    if (_currentUser == null) return;
    try {
      final animalsData = _userAnimals.map((a) => a.toMap()).toList();
      await _prefs?.setString('animals_${_currentUser!.uid}', json.encode(animalsData));
    } catch (e) {
      debugPrint('Error saving user animals: $e');
    }
  }

  Future<void> _saveTasks() async {
    _prefs ??= await SharedPreferences.getInstance();
    final data = json.encode(_allTasks);
    await _prefs!.setString(_keyAdminTasks, data);
  }

  Future<void> _saveSites() async {
    _prefs ??= await SharedPreferences.getInstance();
    final data = json.encode(_allSites);
    await _prefs!.setString(_keyAdminSites, data);
  }

  Future<void> _savePendingReviews() async {
    _prefs ??= await SharedPreferences.getInstance();
    final data = json.encode(_pendingTaskReviews);
    await _prefs!.setString(_keyPendingReviews, data);
  }

  void _loadPendingReviews() {
    if (_prefs == null) return;
    final raw = _prefs!.getString(_keyPendingReviews);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        _pendingTaskReviews = (decoded as List).map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (_) {
        _pendingTaskReviews = [];
      }
    }
  }

  void _loadTasks() {
    if (_prefs == null) return;
    final raw = _prefs!.getString(_keyAdminTasks);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          _allTasks = List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e)));
        } else {
          _allTasks = _getDefaultTasks();
        }
      } catch (_) {
        _allTasks = _getDefaultTasks();
      }
    } else {
      _allTasks = _getDefaultTasks();
    }
  }

  void _loadSites() {
    if (_prefs == null) return;
    final raw = _prefs!.getString(_keyAdminSites);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          _allSites = List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e)));
        } else {
          _allSites = _getDefaultSites();
        }
      } catch (_) {
        _allSites = _getDefaultSites();
      }
    } else {
      _allSites = _getDefaultSites();
    }
  }

  bool get isAuthenticated => _currentUser != null;

  static const String _adminEmail = 'mitidjadido@gmail.com';

  Future<String?> register(String name, String email, String password) async {
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      return 'التسجيل متاح فقط بحسابات Gmail';
    }
    final users = _getAllUsersList();
    if (users.any((u) => u['email'] == email)) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    }

    final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final code = UserModel.generateReferralCode(uid);

    final newUser = UserModel(
      uid: uid,
      name: name,
      email: email,
      itcBalance: AppConstants.registrationBonus.toDouble(),
      totalEarned: AppConstants.registrationBonus.toDouble(),
      referralCode: code,
      dailyLogin: DailyLoginData(
        lastLogin: DateTime.now().subtract(Duration(days: 1)),
        streak: 0,
        claimedToday: false,
      ),
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    _currentUser = newUser;
    _transactions = [];
    _userAnimals = [];
    _loadTasks();
    _loadSites();

    _addTransaction('earn', AppConstants.registrationBonus.toDouble(), 'مكافأة التسجيل');
    final newUserMap = newUser.toMap();
    newUserMap['password'] = _hashPassword(password);
    _allUsers.add(newUserMap);
    await _saveCurrentUser();
    await _saveUserTransactions();
    await _saveUserAnimals();
    await _saveAllUsers();
    return null;
  }

  Future<String?> login(String email, String password) async {
    final users = _getAllUsersList();
    final match = users.where((u) => u['email'].toLowerCase() == email.toLowerCase()).toList();
    if (match.isEmpty) return 'الحساب غير موجود';

    final storedPassword = match.first['password'] ?? '';
    if (!_verifyPassword(password, storedPassword)) return 'كلمة المرور خاطئة';

    final userData = match.first;
    final dailyLogin = DailyLoginData.fromMap(userData['dailyLogin'] ?? {});
    final updatedDailyLogin = _computeDailyLoginState(dailyLogin);

    _currentUser = UserModel(
      uid: userData['uid'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'],
      itcBalance: (userData['itcBalance'] ?? 0).toDouble(),
      totalEarned: (userData['totalEarned'] ?? 0).toDouble(),
      referralCode: userData['referralCode'] ?? '',
      referredBy: userData['referredBy'],
      totalReferrals: userData['totalReferrals'] ?? 0,
      activeReferrals: userData['activeReferrals'] ?? 0,
      referralEarnings: (userData['referralEarnings'] ?? 0).toDouble(),
      dailyLogin: updatedDailyLogin,
      createdAt: DateTime.tryParse(userData['createdAt'] ?? '') ?? DateTime.now(),
      lastActive: DateTime.now(),
    );

    _loadUserTransactions();
    _loadUserAnimals();
    _loadUserStakings();
    _loadTasks();
    _loadSites();
    await _prefs?.setString(_keyCurrentUserEmail, email);
    await _saveCurrentUser();
    return null;
  }

  Future<bool> userExists(String email) async {
    final users = _getAllUsersList();
    return users.any((u) => u['email'] == email);
  }

  Future<String?> resetPassword(String email, String newPassword) async {
    if (_currentUser == null || _currentUser!.email != email) return 'غير مصرح';
    if (newPassword.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    final users = _getAllUsersList();
    final index = users.indexWhere((u) => u['email'] == email);
    if (index == -1) return 'البريد الإلكتروني غير مسجل';
    users[index]['password'] = _hashPassword(newPassword);
    _allUsers = users;
    await _prefs?.setString(_keyAllUsers, json.encode(users));
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    _transactions = [];
    _userAnimals = [];
    _userStakings = [];
    await _prefs?.remove(_keyCurrentUserEmail);
  }

  Future<bool> applyReferralCode(String code) async {
    if (_currentUser == null || _isBusy) return false;
    if (_currentUser!.referredBy != null) return false;
    if (code.toUpperCase() == _currentUser!.referralCode.toUpperCase()) return false;

    final referrerIndex = _allUsers.indexWhere(
      (u) => (u['referralCode'] ?? '').toString().toUpperCase() == code.toUpperCase(),
    );
    if (referrerIndex == -1) return false;

    _isBusy = true;
    try {
      _currentUser = _currentUser!.copyWith(
        referredBy: code,
      );

      _allUsers[referrerIndex]['totalReferrals'] = ((_allUsers[referrerIndex]['totalReferrals'] ?? 0) as int) + 1;
      _allUsers[referrerIndex]['activeReferrals'] = ((_allUsers[referrerIndex]['activeReferrals'] ?? 0) as int) + 1;
      _allUsers[referrerIndex]['itcBalance'] = ((_allUsers[referrerIndex]['itcBalance'] ?? 0).toDouble()) + AppConstants.referralSignupBonus;
      _allUsers[referrerIndex]['totalEarned'] = ((_allUsers[referrerIndex]['totalEarned'] ?? 0).toDouble()) + AppConstants.referralSignupBonus;

      _currentUser = _currentUser!.copyWith(
        itcBalance: _currentUser!.itcBalance + AppConstants.referralSignupBonus,
        totalEarned: _currentUser!.totalEarned + AppConstants.referralSignupBonus,
      );

      _addTransaction('earn', AppConstants.referralSignupBonus.toDouble(), 'مكافأة إدخال كود الإحالة');
      await _saveCurrentUser();
      await _saveUserTransactions();
      await _saveAllUsers();
      return true;
    } finally {
      _isBusy = false;
    }
  }

  Future<double> claimDailyLogin() async {
    if (_currentUser == null || _currentUser!.dailyLogin.claimedToday || _isBusy) return 0;
    _isBusy = true;

    try {

    int newStreak = _currentUser!.dailyLogin.streak + 1;

    if (newStreak > 7) newStreak = 1;

    final rewards = AppConstants.dailyLoginRewards;
    final double reward = rewards[newStreak - 1].toDouble();

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    bool shouldResetStreak = false;
    if (_currentUser!.dailyLogin.lastLogin != null) {
      final lastDate = DateTime(
        _currentUser!.dailyLogin.lastLogin!.year,
        _currentUser!.dailyLogin.lastLogin!.month,
        _currentUser!.dailyLogin.lastLogin!.day,
      );
      final daysDiff = todayDate.difference(lastDate).inDays;
      if (daysDiff > 1) {
        shouldResetStreak = true;
      }
    }

    if (shouldResetStreak) {
      newStreak = 1;
    }

    _currentUser = _currentUser!.copyWith(
      itcBalance: _currentUser!.itcBalance + reward,
      totalEarned: _currentUser!.totalEarned + reward,
      dailyLogin: DailyLoginData(
        lastLogin: now,
        streak: newStreak,
        claimedToday: true,
      ),
    );

    _addTransaction('earn', reward, 'مكافأة تسجيل الدخول - اليوم $newStreak');
    await _saveCurrentUser();
    await _saveUserTransactions();
    return reward;
    } finally {
      _isBusy = false;
    }
  }

  Future<bool> buyAnimal(AnimalModel animal) async {
    if (_currentUser == null || _currentUser!.itcBalance < animal.price || _isBusy) return false;
    final isActive = _allAnimals.any((a) => a['type'] == animal.type.name && a['active'] == true);
    if (!isActive) return false;
    _isBusy = true;

    try {

    _currentUser = _currentUser!.copyWith(
      itcBalance: _currentUser!.itcBalance - animal.price,
    );

    _addTransaction('spend', animal.price.toDouble(), 'شراء ${animal.name}');

    final expiresAt = animal.lifespan == 0
        ? DateTime(9999, 12, 31)
        : DateTime.now().add(Duration(days: animal.lifespan));

    final newAnimal = UserAnimal(
      instanceId: 'animal_${DateTime.now().millisecondsSinceEpoch}',
      animalType: animal.type,
      purchasedAt: DateTime.now(),
      lastCollectedAt: DateTime.now(),
      quantity: 1,
      expiresAt: expiresAt,
    );

    _userAnimals.add(newAnimal);
    await _saveCurrentUser();
    await _saveUserTransactions();
    await _saveUserAnimals();
    return true;
    } finally {
      _isBusy = false;
    }
  }

  Future<double> collectAnimalProfit(UserAnimal userAnimal, AnimalModel animalInfo) async {
    if (_currentUser == null || _isBusy) return 0;
    if (userAnimal.isExpired) return 0;
    if (!userAnimal.canCollect(animalInfo.collectionInterval)) return 0;
    _isBusy = true;

    try {

    final amount = userAnimal.collectibleAmount(animalInfo.dailyProfit, animalInfo.collectionInterval);
    if (amount <= 0) { _isBusy = false; return 0; }

    final index = _userAnimals.indexWhere((a) => a.instanceId == userAnimal.instanceId);
    if (index != -1) {
      _userAnimals[index] = _userAnimals[index].copyWith(
        lastCollectedAt: DateTime.now(),
      );
    }

    _currentUser = _currentUser!.copyWith(
      itcBalance: _currentUser!.itcBalance + amount,
      totalEarned: _currentUser!.totalEarned + amount,
    );

    _addTransaction('earn', amount.toDouble(), 'جمع ITC من ${animalInfo.name}');
    await _saveCurrentUser();
    await _saveUserTransactions();
    await _saveUserAnimals();
    return amount.toDouble();
    } finally {
      _isBusy = false;
    }
  }

  // ─── Animal Maintenance ───


  Future<void> addItc(double amount, String description) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      itcBalance: _currentUser!.itcBalance + amount,
      totalEarned: _currentUser!.totalEarned + amount,
    );

    _addTransaction('earn', amount, description);
    await _saveCurrentUser();
    await _saveUserTransactions();
  }

  void _addTransaction(String type, double amount, String description) {
    _transactions.insert(0, TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: _parseTransactionType(type),
      amount: amount.abs(),
      description: description,
      balance: _currentUser?.itcBalance ?? 0.0,
      createdAt: DateTime.now(),
    ));
  }

  TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'earn': return TransactionType.earn;
      case 'spend': return TransactionType.spend;
      case 'deposit': return TransactionType.deposit;
      case 'referral': return TransactionType.referral;
      default: return TransactionType.earn;
    }
  }

  Future<void> adminAddItcToUser(String userEmail, double amount) async {
    if (!isAdmin) return;
    final index = _allUsers.indexWhere((u) => u['email'] == userEmail);
    if (index == -1) return;
    _allUsers[index]['itcBalance'] = ((_allUsers[index]['itcBalance'] ?? 0).toDouble()) + amount;
    _allUsers[index]['totalEarned'] = ((_allUsers[index]['totalEarned'] ?? 0).toDouble()) + amount;
    await _saveAllUsers();

    if (_currentUser?.email == userEmail) {
      _currentUser = _currentUser!.copyWith(
        itcBalance: _currentUser!.itcBalance + amount,
        totalEarned: _currentUser!.totalEarned + amount,
      );
      _addTransaction('earn', amount, 'إضافة من الإدارة');
      await _saveCurrentUser();
      await _saveUserTransactions();
    }
  }

  Future<void> adminRemoveItcFromUser(String userEmail, double amount) async {
    if (!isAdmin) return;
    final index = _allUsers.indexWhere((u) => u['email'] == userEmail);
    if (index == -1) return;
    final current = (_allUsers[index]['itcBalance'] ?? 0).toDouble();
    _allUsers[index]['itcBalance'] = (current - amount).clamp(0.0, 999999999.0);
    await _saveAllUsers();

    if (_currentUser?.email == userEmail) {
      final newBalance = (_currentUser!.itcBalance - amount).clamp(0.0, 999999999.0).toDouble();
      _currentUser = _currentUser!.copyWith(itcBalance: newBalance);
      _addTransaction('spend', amount, 'خصم من الإدارة');
      await _saveCurrentUser();
      await _saveUserTransactions();
    }
  }

  Future<void> adminAddTask(Map<String, dynamic> task) async {
    if (!isAdmin) return;
    task['id'] = 'task_${DateTime.now().millisecondsSinceEpoch}';
    task['active'] = true;
    _allTasks.add(task);
    await _saveTasks();
  }

  Future<void> adminRemoveTask(String taskId) async {
    if (!isAdmin) return;
    _allTasks.removeWhere((t) => t['id'] == taskId);
    await _saveTasks();
  }

  Future<void> adminToggleTask(String taskId) async {
    if (!isAdmin) return;
    final index = _allTasks.indexWhere((t) => t['id'] == taskId);
    if (index != -1) {
      _allTasks[index]['active'] = !(_allTasks[index]['active'] ?? true);
      await _saveTasks();
    }
  }

  Future<void> adminUpdateTask(String taskId, Map<String, dynamic> updates) async {
    if (!isAdmin) return;
    final index = _allTasks.indexWhere((t) => t['id'] == taskId);
    if (index != -1) {
      _allTasks[index].addAll(updates);
      await _saveTasks();
    }
  }

  Future<void> markTaskCompleted(String taskId) async {
    if (_currentUser == null) return;
    final updated = List<String>.from(_currentUser!.completedTasks);
    if (!updated.contains(taskId)) {
      updated.add(taskId);
      _currentUser = _currentUser!.copyWith(completedTasks: updated);
      await _saveCurrentUser();
    }
  }

  Future<void> markSiteVisited(String siteId) async {
    if (_currentUser == null) return;
    final updated = List<String>.from(_currentUser!.visitedSites);
    if (!updated.contains(siteId)) {
      updated.add(siteId);
      _currentUser = _currentUser!.copyWith(visitedSites: updated);
      await _saveCurrentUser();
    }
  }

  Future<void> submitTaskForReview(String taskId, String screenshotPath, String siteUrl) async {
    if (_currentUser == null) return;
    final alreadySubmitted = _pendingTaskReviews.any(
      (r) => r['taskId'] == taskId && r['userEmail'] == _currentUser!.email && r['status'] == 'pending',
    );
    if (alreadySubmitted) return;
    final task = _allTasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
    _pendingTaskReviews.add({
      'id': 'review_${DateTime.now().millisecondsSinceEpoch}',
      'taskId': taskId,
      'taskTitle': task['title'] ?? '',
      'userEmail': _currentUser!.email ?? '',
      'userName': _currentUser!.name,
      'screenshotPath': screenshotPath,
      'siteUrl': siteUrl,
      'reward': task['reward'] ?? 0,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _savePendingReviews();
    await markTaskCompleted(taskId);
  }

  Future<void> adminApproveTaskReview(String reviewId) async {
    if (!isAdmin) return;
    final index = _pendingTaskReviews.indexWhere((r) => r['id'] == reviewId);
    if (index == -1) return;
    final review = _pendingTaskReviews[index];
    _pendingTaskReviews[index]['status'] = 'approved';

    final userEmail = review['userEmail'];
    final double reward = ((review['reward'] ?? 0)).toDouble();

    // Always update the user in _allUsers
    final userIndex = _allUsers.indexWhere((u) => u['email'] == userEmail);
    if (userIndex != -1) {
      _allUsers[userIndex]['itcBalance'] = ((_allUsers[userIndex]['itcBalance'] ?? 0).toDouble()) + reward;
      _allUsers[userIndex]['totalEarned'] = ((_allUsers[userIndex]['totalEarned'] ?? 0).toDouble()) + reward;
      await _saveAllUsers();
    }

    // Sync _currentUser if it matches
    if (_currentUser?.email == userEmail) {
      _currentUser = _currentUser!.copyWith(
        itcBalance: _currentUser!.itcBalance + reward,
        totalEarned: _currentUser!.totalEarned + reward,
      );
      _transactions.insert(0, TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        amount: reward,
        description: 'إكمال مهمة: ${review['taskTitle']}',
        type: TransactionType.taskReward,
        createdAt: DateTime.now(),
        balance: _currentUser!.itcBalance,
      ));
      await _saveCurrentUser();
      await _saveUserTransactions();
    }

    await _savePendingReviews();
  }

  Future<void> adminRejectTaskReview(String reviewId) async {
    if (!isAdmin) return;
    final index = _pendingTaskReviews.indexWhere((r) => r['id'] == reviewId);
    if (index == -1) return;
    _pendingTaskReviews[index]['status'] = 'rejected';
    await _savePendingReviews();
  }

  Future<void> adminAddSite(Map<String, dynamic> site) async {
    if (!isAdmin) return;
    site['id'] = 'site_${DateTime.now().millisecondsSinceEpoch}';
    site['active'] = true;
    _allSites.add(site);
    await _saveSites();
  }

  Future<void> adminRemoveSite(String siteId) async {
    if (!isAdmin) return;
    _allSites.removeWhere((s) => s['id'] == siteId);
    await _saveSites();
  }

  Future<void> adminToggleSite(String siteId) async {
    if (!isAdmin) return;
    final index = _allSites.indexWhere((s) => s['id'] == siteId);
    if (index != -1) {
      _allSites[index]['active'] = !(_allSites[index]['active'] ?? true);
      await _saveSites();
    }
  }

  // ─── Animal Management ───

  List<Map<String, dynamic>> _getDefaultAnimals() {
    return [
      {'id': 'chicken', 'type': 'chicken', 'name': 'دجاجة', 'price': 1000, 'dailyProfit': 20, 'emoji': '🐔', 'active': true},
      {'id': 'cow', 'type': 'cow', 'name': 'بقرة', 'price': 5000, 'dailyProfit': 100, 'emoji': '🐄', 'active': true},
      {'id': 'dog', 'type': 'dog', 'name': 'كلب', 'price': 20000, 'dailyProfit': 400, 'emoji': '🐕', 'active': true},
      {'id': 'horse', 'type': 'horse', 'name': 'حصان', 'price': 50000, 'dailyProfit': 1000, 'emoji': '🐎', 'active': true},
      {'id': 'elephant', 'type': 'elephant', 'name': 'فيل', 'price': 100000, 'dailyProfit': 2000, 'emoji': '🐘', 'active': true},
      {'id': 'dragon', 'type': 'dragon', 'name': 'تنين', 'price': 200000, 'dailyProfit': 4000, 'emoji': '🐉', 'active': true},
      {'id': 'lion', 'type': 'lion', 'name': 'أسد نادر', 'price': 500000, 'dailyProfit': 12000, 'emoji': '🦁', 'active': true, 'lifespan': 0},
      {'id': 'phoenix', 'type': 'phoenix', 'name': 'طائر النار', 'price': 500000, 'dailyProfit': 15000, 'emoji': '🔥', 'active': true, 'lifespan': 0},
      {'id': 'unicorn', 'type': 'unicorn', 'name': 'أحادي القرن', 'price': 500000, 'dailyProfit': 18000, 'emoji': '🦄', 'active': true, 'lifespan': 0},
    ];
  }

  void _loadAnimals() {
    if (_prefs == null) return;
    final raw = _prefs!.getString(_keyAdminAnimals);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          _allAnimals = List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e)));
          final defaultAnimals = _getDefaultAnimals();
          final oldChicken = _allAnimals.firstWhere((a) => a['id'] == 'chicken', orElse: () => {});
          if ((oldChicken['price'] ?? 0) < 1000) {
            _allAnimals = defaultAnimals;
            _saveAnimals();
          }
        } else {
          _allAnimals = _getDefaultAnimals();
        }
      } catch (_) {
        _allAnimals = _getDefaultAnimals();
      }
    } else {
      _allAnimals = _getDefaultAnimals();
    }
  }

  Future<void> _saveAnimals() async {
    _prefs ??= await SharedPreferences.getInstance();
    final data = json.encode(_allAnimals);
    await _prefs!.setString(_keyAdminAnimals, data);
  }

  Future<void> adminAddAnimal(Map<String, dynamic> animal) async {
    if (!isAdmin) return;
    animal['id'] = 'animal_${DateTime.now().millisecondsSinceEpoch}';
    animal['active'] = true;
    _allAnimals.add(animal);
    await _saveAnimals();
  }

  Future<void> adminUpdateAnimal(String animalId, Map<String, dynamic> updates) async {
    if (!isAdmin) return;
    final index = _allAnimals.indexWhere((a) => a['id'] == animalId);
    if (index != -1) {
      _allAnimals[index].addAll(updates);
      await _saveAnimals();
    }
  }

  Future<void> adminRemoveAnimal(String animalId) async {
    if (!isAdmin) return;
    _allAnimals.removeWhere((a) => a['id'] == animalId);
    await _saveAnimals();
  }

  Future<void> adminToggleAnimal(String animalId) async {
    if (!isAdmin) return;
    final index = _allAnimals.indexWhere((a) => a['id'] == animalId);
    if (index != -1) {
      _allAnimals[index]['active'] = !(_allAnimals[index]['active'] ?? true);
      await _saveAnimals();
    }
  }

  List<AnimalModel> getAvailableAnimals() {
    return _allAnimals.where((a) => a['active'] == true).map((a) => AnimalModel(
      id: a['id'] ?? '',
      type: _parseAnimalType(a['type'] ?? 'chicken'),
      name: a['name'] ?? '',
      price: a['price'] ?? 50,
      dailyProfit: a['dailyProfit'] ?? 1,
      emoji: a['emoji'] ?? '🐔',
      lifespan: a['lifespan'] ?? 90,
      collectionInterval: a['collectionInterval'] ?? 12,
    )).toList();
  }

  AnimalType _parseAnimalType(String type) {
    switch (type) {
      case 'chicken': return AnimalType.chicken;
      case 'cow': return AnimalType.cow;
      case 'dog': return AnimalType.dog;
      case 'horse': return AnimalType.horse;
      case 'elephant': return AnimalType.elephant;
      case 'dragon': return AnimalType.dragon;
      case 'lion': return AnimalType.lion;
      case 'phoenix': return AnimalType.phoenix;
      case 'unicorn': return AnimalType.unicorn;
      default: return AnimalType.chicken;
    }
  }

  Future<void> adminDeleteUser(String email) async {
    if (!isAdmin) return;
    _allUsers.removeWhere((u) => u['email'] == email);
    await _saveAllUsers();
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null || _isBusy) return;
    _isBusy = true;

    try {
      final email = _currentUser!.email;
      final uid = _currentUser!.uid;
      _allUsers.removeWhere((u) => u['email'] == email);
      _currentUser = null;
      _transactions = [];
      _userAnimals = [];
      _userStakings = [];
      await _prefs?.remove(_keyCurrentUserEmail);
      await _prefs?.remove(_keyPrefixTx + uid);
      await _prefs?.remove(_keyPrefixAnimals + uid);
      await _prefs?.remove(_keyPrefixStakings + uid);
      await _prefs?.remove(_keyPrefixGiftBox + uid);
      await _prefs?.remove(_keyPrefixWheel + uid);
      await _saveAllUsers();
    } finally {
      _isBusy = false;
    }
  }

  int get totalUsers => _allUsers.length;
  double get adminUsdBalance => _adminUsdBalance;
  double get totalItcInCirculation {
    double total = 0;
    for (final u in _allUsers) {
      total += (u['itcBalance'] ?? 0).toDouble();
    }
    return total;
  }

  // ─── ITC Withdrawal/Deposit Load/Save ───

  void _loadWithdrawals() {
    if (_prefs == null) return;
    final raw = _prefs!.getString(_keyWithdrawals);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          _withdrawalRequests = List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e)));
        }
      } catch (e) {
        debugPrint('Error loading withdrawals: $e');
      }
    }
  }

  Future<void> _saveWithdrawals() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_keyWithdrawals, json.encode(_withdrawalRequests));
  }

  void _loadDeposits() {
    if (_prefs == null) return;
    final raw = _prefs!.getString(_keyDeposits);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          _depositRequests = List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e)));
        }
      } catch (e) {
        debugPrint('Error loading deposits: $e');
      }
    }
  }

  Future<void> _saveDeposits() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_keyDeposits, json.encode(_depositRequests));
  }

  // ─── Buy/Sell ITC Requests ───

  void _loadBuySellRequests() {
    if (_prefs == null) return;
    final raw = _prefs!.getString(_keyBuySellRequests);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          _buySellRequests = List<Map<String, dynamic>>.from(decoded.map((e) => Map<String, dynamic>.from(e)));
        }
      } catch (e) {
        debugPrint('Error loading buy/sell requests: $e');
      }
    }
  }

  Future<void> _saveBuySellRequests() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_keyBuySellRequests, json.encode(_buySellRequests));
  }

  List<Map<String, dynamic>> get allBuySellRequests => _buySellRequests;

  List<Map<String, dynamic>> get userBuySellRequests {
    if (_currentUser == null) return [];
    return _buySellRequests.where((r) => r['userEmail'] == _currentUser!.email).toList();
  }

  Future<void> submitBuySellRequest(Map<String, dynamic> request) async {
    if (_currentUser == null) return;
    final type = request['type'];
    final amountItc = (request['amountItc'] ?? 0).toDouble();
    if (amountItc <= 0) return;

    if (type == 'buy') {
      final amountUsd = (request['amountUsd'] ?? 0).toDouble();
      if (amountUsd <= 0) return;
    } else if (type == 'sell') {
      if (_currentUser!.itcBalance < amountItc) return;
      if (amountItc < AppConstants.minWithdrawalItc) return;
    } else {
      return;
    }

    request['id'] = 'req_${DateTime.now().millisecondsSinceEpoch}';
    request['userEmail'] = _currentUser!.email;
    request['userName'] = _currentUser!.name;
    request['status'] = 'pending';
    request['createdAt'] = DateTime.now().toIso8601String();
    _buySellRequests.add(request);
    await _saveBuySellRequests();
  }

  Future<void> approveBuySellRequest(String requestId) async {
    if (!isAdmin) return;
    final index = _buySellRequests.indexWhere((r) => r['id'] == requestId);
    if (index == -1) return;
    final request = _buySellRequests[index];
    _buySellRequests[index]['status'] = 'approved';

    final userEmail = request['userEmail'];
    final type = request['type'];
    final amountItc = (request['amountItc'] ?? 0).toDouble();

    if (type == 'buy') {
      // User buys ITC: admin ITC ↓, admin USD ↑, user ITC ↑
      final userIndex = _allUsers.indexWhere((u) => u['email'] == userEmail);
      final adminIndex = _allUsers.indexWhere((u) => u['email'] == 'mitidjadido@gmail.com');
      final amountUsd = (request['amountUsd'] ?? 0).toDouble();

      if (userIndex != -1) {
        _allUsers[userIndex]['itcBalance'] = ((_allUsers[userIndex]['itcBalance'] ?? 0).toDouble()) + amountItc;
      }
      if (adminIndex != -1) {
        final adminBal = (_allUsers[adminIndex]['itcBalance'] ?? 0).toDouble();
        _allUsers[adminIndex]['itcBalance'] = (adminBal - amountItc).clamp(0.0, 999999999.0);
      }
      _adminUsdBalance += amountUsd;
      await _prefs?.setDouble(_keyAdminUsdBalance, _adminUsdBalance);
      await _saveAllUsers();

      if (_currentUser?.email == userEmail) {
        _currentUser = _currentUser!.copyWith(itcBalance: _currentUser!.itcBalance + amountItc);
        await _saveCurrentUser();
      }
      if (_currentUser?.email == 'mitidjadido@gmail.com' && _currentUser?.email != userEmail) {
        final adminBal = _currentUser!.itcBalance;
        _currentUser = _currentUser!.copyWith(itcBalance: (adminBal - amountItc).clamp(0.0, 999999999.0));
        await _saveCurrentUser();
      }
      _addTransaction('spend', amountItc, 'شراء ITC من المستخدم ($userEmail)');
    } else {
      // Sell: user sells X ITC → admin gets X ITC, user gets net USD (after 10% fee)
      final fee = (amountItc * AppConstants.sellFeePercent).toInt().toDouble();
      final netAmountItc = amountItc - fee;
      final netUsd = netAmountItc * AppConstants.itcPrice;
      final userIndex = _allUsers.indexWhere((u) => u['email'] == userEmail);
      final adminIndex = _allUsers.indexWhere((u) => u['email'] == 'mitidjadido@gmail.com');

      if (userIndex != -1) {
        final current = (_allUsers[userIndex]['itcBalance'] ?? 0).toDouble();
        _allUsers[userIndex]['itcBalance'] = (current - amountItc).clamp(0.0, 999999999.0);
      }
      if (adminIndex != -1) {
        final adminBal = (_allUsers[adminIndex]['itcBalance'] ?? 0).toDouble();
        _allUsers[adminIndex]['itcBalance'] = adminBal + amountItc;
      }
      _adminUsdBalance = (_adminUsdBalance - netUsd).clamp(0.0, 999999999.0);
      await _prefs?.setDouble(_keyAdminUsdBalance, _adminUsdBalance);
      await _saveAllUsers();

      if (_currentUser?.email == userEmail) {
        final newBalance = (_currentUser!.itcBalance - amountItc).clamp(0.0, 999999999.0).toDouble();
        _currentUser = _currentUser!.copyWith(itcBalance: newBalance);
        await _saveCurrentUser();
      }
      if (_currentUser?.email == 'mitidjadido@gmail.com' && _currentUser?.email != userEmail) {
        _currentUser = _currentUser!.copyWith(itcBalance: _currentUser!.itcBalance + amountItc);
        await _saveCurrentUser();
      }
      _addTransaction('earn', amountItc, 'بيع ITC من المستخدم ($userEmail) (${amountItc.toInt()} - ${fee.toInt()} رسوم = ${netAmountItc.toInt()} صافي)');
    }

    await _saveBuySellRequests();
  }

  Future<void> rejectBuySellRequest(String requestId) async {
    if (!isAdmin) return;
    final index = _buySellRequests.indexWhere((r) => r['id'] == requestId);
    if (index == -1) return;
    _buySellRequests[index]['status'] = 'rejected';
    await _saveBuySellRequests();
  }

  // ─── ITC Withdrawal/Deposit Operations ───

  Future<void> requestWithdrawal(double amount, String walletAddress) async {
    if (_currentUser == null || _isBusy) return;
    if (amount < AppConstants.minWithdrawalItc) return;
    if (_currentUser!.itcBalance < amount) return;
    _isBusy = true;

    try {

    final request = WithdrawalRequest(
      id: 'wd_${DateTime.now().millisecondsSinceEpoch}',
      userEmail: _currentUser!.email ?? '',
      userName: _currentUser!.name,
      amount: amount,
      walletAddress: walletAddress,
      createdAt: DateTime.now(),
    );

    _withdrawalRequests.add(request.toMap());

    _currentUser = _currentUser!.copyWith(
      itcBalance: _currentUser!.itcBalance - amount,
    );

    await _saveWithdrawals();
    await _saveCurrentUser();
    } finally {
      _isBusy = false;
    }
  }

  Future<void> requestDeposit(double amount, String txHash) async {
    if (_currentUser == null) return;
    if (amount <= 0) return;
    if (txHash.trim().isEmpty) return;

    final request = DepositRequest(
      id: 'dp_${DateTime.now().millisecondsSinceEpoch}',
      userEmail: _currentUser!.email ?? '',
      userName: _currentUser!.name,
      amount: amount,
      txHash: txHash,
      createdAt: DateTime.now(),
    );

    _depositRequests.add(request.toMap());
    await _saveDeposits();
  }

  Future<void> approveDeposit(String depositId) async {
    if (!isAdmin) return;
    final index = _depositRequests.indexWhere((d) => d['id'] == depositId);
    if (index == -1) return;
    _depositRequests[index]['status'] = 'approved';

    final amount = (_depositRequests[index]['amount'] ?? 0).toDouble();
    final userEmail = _depositRequests[index]['userEmail'];

    final userIndex = _allUsers.indexWhere((u) => u['email'] == userEmail);
    if (userIndex != -1) {
      _allUsers[userIndex]['itcBalance'] = ((_allUsers[userIndex]['itcBalance'] ?? 0).toDouble()) + amount;
      await _saveAllUsers();

      if (_currentUser?.email == userEmail) {
        _currentUser = _currentUser!.copyWith(
          itcBalance: _currentUser!.itcBalance + amount,
        );
        _addTransaction('deposit', amount, 'إيداع ITC معتمد');
        await _saveCurrentUser();
        await _saveUserTransactions();
      }
    }
    await _saveDeposits();
  }

  Future<void> rejectDeposit(String depositId) async {
    if (!isAdmin) return;
    final index = _depositRequests.indexWhere((d) => d['id'] == depositId);
    if (index == -1) return;
    _depositRequests[index]['status'] = 'rejected';
    await _saveDeposits();
  }

  Future<void> approveWithdrawal(String withdrawalId) async {
    if (!isAdmin) return;
    final index = _withdrawalRequests.indexWhere((w) => w['id'] == withdrawalId);
    if (index == -1) return;
    _withdrawalRequests[index]['status'] = 'approved';
    await _saveWithdrawals();
  }

  Future<void> rejectWithdrawal(String withdrawalId) async {
    if (!isAdmin) return;
    final index = _withdrawalRequests.indexWhere((w) => w['id'] == withdrawalId);
    if (index == -1) return;
    final wd = _withdrawalRequests[index];
    _withdrawalRequests[index]['status'] = 'rejected';

    final amount = (wd['amount'] ?? 0).toDouble();
    final userEmail = wd['userEmail'];

    final userIndex = _allUsers.indexWhere((u) => u['email'] == userEmail);
    if (userIndex != -1) {
      _allUsers[userIndex]['itcBalance'] = ((_allUsers[userIndex]['itcBalance'] ?? 0).toDouble()) + amount;
      await _saveAllUsers();

      if (_currentUser?.email == userEmail) {
        _currentUser = _currentUser!.copyWith(
          itcBalance: _currentUser!.itcBalance + amount,
        );
        _addTransaction('earn', amount, 'استرداد ITC - سحب مرفوض');
        await _saveCurrentUser();
        await _saveUserTransactions();
      }
    }
    await _saveWithdrawals();
  }
}
