import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hamster_points/models/user_model.dart';
import 'package:hamster_points/models/transaction_model.dart';
import 'package:hamster_points/models/animal_model.dart';
import 'package:hamster_points/models/staking_model.dart';
import 'package:hamster_points/models/crypto_model.dart';
import 'package:hamster_points/utils/constants.dart';
import 'package:hamster_points/services/api_service.dart';

class DemoService {
  static final DemoService _instance = DemoService._internal();
  factory DemoService() => _instance;
  DemoService._internal();

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
  List<Map<String, dynamic>> _buySellRequests = [];
  List<UserStaking> _userStakings = [];

  DateTime? _lastGiftBoxClaim;
  DateTime? _lastWheelSpin;

  static const String _adminEmail = 'mitidjadido@gmail.com';

  static String _hashPassword(String password) {
    final bytes = utf8.encode('nexora_salt_$password');
    final digest = sha256.convert(bytes);
    return 'h:${digest.toString()}';
  }

  static bool _verifyPassword(String password, String stored) {
    if (!stored.startsWith('h:')) return password == stored;
    return _hashPassword(password) == stored;
  }

  // ─── Getters ───

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
  bool get isAuthenticated => _currentUser != null;
  int get totalUsers => _allUsers.length;
  double get adminUsdBalance => _adminUsdBalance;
  List<Map<String, dynamic>> get allBuySellRequests => _buySellRequests;
  List<Map<String, dynamic>> get userBuySellRequests {
    if (_currentUser == null) return [];
    return _buySellRequests.where((r) => r['userEmail'] == _currentUser!.email).toList();
  }

  double get totalItcInCirculation {
    double total = 0;
    for (final u in _allUsers) {
      total += (u['itcBalance'] ?? 0).toDouble();
    }
    return total;
  }

  // ─── API Response Parsers ───

  UserModel _parseUserFromApi(Map<String, dynamic> data) {
    final dailyLoginData = data['daily_login'] ?? data['dailyLogin'] ?? {};
    return UserModel(
      uid: data['uid'] ?? data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'],
      photoUrl: data['photo_url'] ?? data['photoUrl'],
      itcBalance: (data['itc_balance'] ?? data['itcBalance'] ?? 0).toDouble(),
      totalEarned: (data['total_earned'] ?? data['totalEarned'] ?? 0).toDouble(),
      referralCode: data['referral_code'] ?? data['referralCode'] ?? '',
      referredBy: data['referred_by'] ?? data['referredBy'],
      totalReferrals: data['total_referrals'] ?? data['totalReferrals'] ?? 0,
      activeReferrals: data['active_referrals'] ?? data['activeReferrals'] ?? 0,
      referralEarnings: (data['referral_earnings'] ?? data['referralEarnings'] ?? 0).toDouble(),
      dailyLogin: DailyLoginData(
        lastLogin: DateTime.tryParse(dailyLoginData['last_login'] ?? dailyLoginData['lastLogin'] ?? ''),
        streak: dailyLoginData['streak'] ?? 0,
        claimedToday: dailyLoginData['claimed_today'] ?? dailyLoginData['claimedToday'] ?? false,
      ),
      createdAt: DateTime.tryParse(data['created_at'] ?? data['createdAt'] ?? '') ?? DateTime.now(),
      lastActive: DateTime.tryParse(data['last_active'] ?? data['lastActive'] ?? '') ?? DateTime.now(),
      completedTasks: List<String>.from(data['completed_tasks'] ?? data['completedTasks'] ?? []),
      visitedSites: List<String>.from(data['visited_sites'] ?? data['visitedSites'] ?? []),
    );
  }

  List<UserAnimal> _parseAnimalsFromApi(List<dynamic> data) {
    return data.map((e) => UserAnimal(
      instanceId: e['instance_id'] ?? e['instanceId'] ?? '',
      animalType: _parseAnimalType(e['animal_type'] ?? e['animalType'] ?? 'chicken'),
      purchasedAt: DateTime.tryParse(e['purchased_at'] ?? e['purchasedAt'] ?? '') ?? DateTime.now(),
      lastCollectedAt: DateTime.tryParse(e['last_collected_at'] ?? e['lastCollectedAt'] ?? '') ?? DateTime.now(),
      quantity: e['quantity'] ?? 1,
      expiresAt: DateTime.tryParse(e['expires_at'] ?? e['expiresAt'] ?? '') ?? DateTime.now().add(Duration(days: 30)),
      purchaseMethod: e['purchase_method'] ?? e['purchaseMethod'] ?? 'points',
    )).toList();
  }

  List<UserStaking> _parseStakingsFromApi(List<dynamic> data) {
    return data.map((e) => UserStaking(
      id: e['staking_id'] ?? e['id'] ?? '',
      tier: StakingTier.values.firstWhere(
        (t) => t.name == (e['tier'] ?? ''),
        orElse: () => StakingTier.bronze,
      ),
      lockedAmount: (e['locked_amount'] ?? e['lockedAmount'] ?? 0).toDouble(),
      stakedAt: DateTime.tryParse(e['staked_at'] ?? e['stakedAt'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(e['expires_at'] ?? e['expiresAt'] ?? '') ?? DateTime.now(),
      totalProfit: (e['total_profit'] ?? e['totalProfit'] ?? 0).toDouble(),
      claimed: e['claimed'] ?? false,
    )).toList();
  }

  List<TransactionModel> _parseTransactionsFromApi(List<dynamic> data) {
    return data.map((e) => TransactionModel(
      id: e['tx_id'] ?? e['id'] ?? '',
      type: _parseTransactionType(e['tx_type'] ?? e['type'] ?? 'earn'),
      amount: (e['amount'] ?? 0).toDouble(),
      description: e['description'] ?? '',
      balance: (e['balance_snapshot'] ?? e['balance'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(e['created_at'] ?? e['createdAt'] ?? '') ?? DateTime.now(),
    )).toList();
  }

  void _parseCooldownsFromApi(Map<String, dynamic> data) {
    final dailyPrize = data['daily_prize'];
    if (dailyPrize != null && dailyPrize.toString().isNotEmpty) {
      _lastWheelSpin = DateTime.tryParse(dailyPrize.toString());
    }
    final giftbox = data['giftbox'];
    if (giftbox != null && giftbox.toString().isNotEmpty) {
      _lastGiftBoxClaim = DateTime.tryParse(giftbox.toString());
    }
  }

  // ─── Initialize ───

  Future<void> initialize() async {
    final api = ApiService();
    await api.initialize();

    final token = api.token;
    if (token != null) {
      try {
        final userData = await api.getUserData();
        if (userData['success'] == true) {
          if (userData['user'] != null) {
            _currentUser = _parseUserFromApi(userData['user']);
          }
          if (userData['animals'] != null) {
            _userAnimals = _parseAnimalsFromApi(userData['animals']);
          }
          if (userData['stakings'] != null) {
            _userStakings = _parseStakingsFromApi(userData['stakings']);
          }
          if (userData['transactions'] != null) {
            _transactions = _parseTransactionsFromApi(userData['transactions']);
          }
          if (userData['cooldowns'] != null) {
            _parseCooldownsFromApi(userData['cooldowns']);
          }
          if (userData['admin_usd_balance'] != null) {
            _adminUsdBalance = (userData['admin_usd_balance'] ?? 0).toDouble();
          }
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }

    await _loadTasksFromApi();
    await _loadSitesFromApi();
    await _loadAnimalsFromApi();

    if (isAdmin) {
      await _loadAdminData();
    }
  }

  Future<void> _loadTasksFromApi() async {
    try {
      final tasks = await ApiService().getTasks();
      _allTasks = tasks.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> _loadSitesFromApi() async {
    try {
      final sites = await ApiService().getSites();
      _allSites = sites.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading sites: $e');
    }
  }

  Future<void> _loadAnimalsFromApi() async {
    try {
      final animals = await ApiService().getAnimals();
      _allAnimals = animals.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading animals: $e');
    }
  }

  Future<void> _loadAdminData() async {
    try {
      final users = await ApiService().getAllUsers();
      _allUsers = users.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }

    try {
      final reviews = await ApiService().getPendingReviews();
      _pendingTaskReviews = reviews.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    }

    try {
      final market = await ApiService().getMarketRequests();
      _buySellRequests = market.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading market requests: $e');
    }

    try {
      final withdrawals = await ApiService().getWithdrawals();
      _withdrawalRequests = withdrawals.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading withdrawals: $e');
    }

    try {
      final deposits = await ApiService().getDeposits();
      _depositRequests = deposits.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error loading deposits: $e');
    }
  }

  // ─── Auth ───

  Future<String?> register(String name, String email, String password) async {
    if (_isBusy) return 'حدث خطأ';
    _isBusy = true;
    try {
      final result = await ApiService().register(name, email, password);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['animals'] != null) {
          _userAnimals = _parseAnimalsFromApi(result['animals']);
        }
        if (result['stakings'] != null) {
          _userStakings = _parseStakingsFromApi(result['stakings']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        if (result['cooldowns'] != null) {
          _parseCooldownsFromApi(result['cooldowns']);
        }
        return null;
      }
      return result['message'] ?? 'حدث خطأ';
    } catch (e) {
      return 'حدث خطأ';
    } finally {
      _isBusy = false;
    }
  }

  Future<String?> login(String email, String password) async {
    if (_isBusy) return 'حدث خطأ';
    _isBusy = true;
    try {
      final result = await ApiService().login(email, password);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['animals'] != null) {
          _userAnimals = _parseAnimalsFromApi(result['animals']);
        }
        if (result['stakings'] != null) {
          _userStakings = _parseStakingsFromApi(result['stakings']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        if (result['cooldowns'] != null) {
          _parseCooldownsFromApi(result['cooldowns']);
        }
        if (result['admin_usd_balance'] != null) {
          _adminUsdBalance = (result['admin_usd_balance'] ?? 0).toDouble();
        }
        if (isAdmin) {
          await _loadAdminData();
        }
        return null;
      }
      return result['message'] ?? 'حدث خطأ';
    } catch (e) {
      return 'حدث خطأ';
    } finally {
      _isBusy = false;
    }
  }

  Future<bool> userExists(String email) async {
    return await ApiService().userExists(email);
  }

  Future<String?> resetPassword(String email, String newPassword) async {
    if (_currentUser == null || _currentUser!.email != email) return 'غير مصرح';
    if (newPassword.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    final result = await ApiService().resetPassword(email, newPassword);
    if (result['success'] == true) {
      return null;
    }
    return result['message'] ?? 'حدث خطأ';
  }

  Future<void> logout() async {
    _currentUser = null;
    _transactions = [];
    _userAnimals = [];
    _userStakings = [];
    _allUsers = [];
    _pendingTaskReviews = [];
    _withdrawalRequests = [];
    _depositRequests = [];
    _buySellRequests = [];
    _lastGiftBoxClaim = null;
    _lastWheelSpin = null;
    _adminUsdBalance = 0.0;
    await ApiService().logout();
  }

  // ─── Gift Box ───

  bool get isGiftBoxAvailable {
    if (_currentUser == null) return false;
    if (_lastGiftBoxClaim == null) return true;
    return DateTime.now().difference(_lastGiftBoxClaim!).inHours >= AppConstants.giftBoxCooldownHours;
  }

  Duration get timeUntilNextGiftBox {
    if (_currentUser == null) return Duration(hours: AppConstants.giftBoxCooldownHours);
    if (_lastGiftBoxClaim == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastGiftBoxClaim!);
    final remaining = Duration(hours: AppConstants.giftBoxCooldownHours) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<double> claimGiftBox() async {
    if (_currentUser == null || _isBusy) return 0;
    _isBusy = true;

    try {
      final oldBalance = _currentUser!.itcBalance;
      final result = await ApiService().claimGiftBox();
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['cooldowns'] != null) {
          _parseCooldownsFromApi(result['cooldowns']);
        }
        _lastGiftBoxClaim = DateTime.now();
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        final reward = _currentUser!.itcBalance - oldBalance;
        return reward > 0 ? reward : 0;
      }
      return 0;
    } finally {
      _isBusy = false;
    }
  }

  // ─── Lucky Wheel ───

  bool get isWheelAvailable {
    if (_currentUser == null) return false;
    if (_lastWheelSpin == null) return true;
    return DateTime.now().difference(_lastWheelSpin!).inHours >= 24;
  }

  Duration get timeUntilNextWheel {
    if (_currentUser == null) return Duration(hours: 24);
    if (_lastWheelSpin == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastWheelSpin!);
    final remaining = Duration(hours: 24) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> spinWheel(String prizeType, double prizeValue) async {
    if (_currentUser == null || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().spinWheel(prizeType, prizeValue);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['cooldowns'] != null) {
          _parseCooldownsFromApi(result['cooldowns']);
        }
        _lastWheelSpin = DateTime.now();
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<Map<String, dynamic>?> paidSpinWheel() async {
    if (_currentUser == null || _isBusy) return null;
    if (_currentUser!.itcBalance < AppConstants.wheelPaidSpinCost) return null;
    _isBusy = true;

    try {
      final result = await ApiService().paidSpin();
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        if (result['prize'] != null) {
          return Map<String, dynamic>.from(result['prize']);
        }
        final random = Random.secure();
        final List<Map<String, dynamic>> prizes = [
          {'type': 'itc', 'value': 2.0},
          {'type': 'itc', 'value': 3.0},
          {'type': 'itc', 'value': 5.0},
          {'type': 'freeroll', 'value': 0.0},
          {'type': 'itc', 'value': 4.0},
          {'type': 'topprize', 'value': 5.0},
        ];
        return prizes[random.nextInt(prizes.length)];
      }
      return null;
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
      final result = await ApiService().stake(plan.tier.name);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['stakings'] != null) {
          _userStakings = _parseStakingsFromApi(result['stakings']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        return true;
      }
      return false;
    } finally {
      _isBusy = false;
    }
  }

  Future<double> claimStaking(String stakingId) async {
    if (_currentUser == null || _isBusy) return 0;
    _isBusy = true;

    try {
      final oldBalance = _currentUser!.itcBalance;
      final result = await ApiService().claimStaking(stakingId);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['stakings'] != null) {
          _userStakings = _parseStakingsFromApi(result['stakings']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        final profit = _currentUser!.itcBalance - oldBalance;
        return profit > 0 ? profit : 0;
      }
      return 0;
    } finally {
      _isBusy = false;
    }
  }

  Future<double> earlyUnstake(String stakingId) async {
    if (_currentUser == null || _isBusy) return 0;
    _isBusy = true;

    try {
      final oldBalance = _currentUser!.itcBalance;
      final result = await ApiService().earlyUnstake(stakingId);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['stakings'] != null) {
          _userStakings = _parseStakingsFromApi(result['stakings']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        final returned = _currentUser!.itcBalance - oldBalance;
        return returned > 0 ? returned : 0;
      }
      return 0;
    } finally {
      _isBusy = false;
    }
  }

  // ─── Daily Login ───

  Future<double> claimDailyLogin() async {
    if (_currentUser == null || _currentUser!.dailyLogin.claimedToday || _isBusy) return 0;
    _isBusy = true;

    try {
      final oldBalance = _currentUser!.itcBalance;
      final result = await ApiService().claimDailyLogin();
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        final reward = _currentUser!.itcBalance - oldBalance;
        return reward > 0 ? reward : 0;
      }
      return 0;
    } finally {
      _isBusy = false;
    }
  }

  // ─── Animal System ───

  Future<bool> buyAnimal(AnimalModel animal) async {
    if (_currentUser == null || _currentUser!.itcBalance < animal.price || _isBusy) return false;
    final isActive = _allAnimals.any((a) => a['type'] == animal.type.name && a['active'] == true);
    if (!isActive) return false;
    _isBusy = true;

    try {
      final result = await ApiService().buyAnimal(animal.type.name);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['animals'] != null) {
          _userAnimals = _parseAnimalsFromApi(result['animals']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        return true;
      }
      return false;
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
      final oldBalance = _currentUser!.itcBalance;
      final result = await ApiService().collectAnimal(userAnimal.instanceId);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['animals'] != null) {
          _userAnimals = _parseAnimalsFromApi(result['animals']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        final reward = _currentUser!.itcBalance - oldBalance;
        return reward > 0 ? reward : 0;
      }
      return 0;
    } finally {
      _isBusy = false;
    }
  }

  // ─── Animal Maintenance ───

  Future<void> addItc(double amount, String description) async {
    if (_currentUser == null || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminCreditUser(_currentUser!.email!, amount);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        } else {
          _currentUser = _currentUser!.copyWith(
            itcBalance: _currentUser!.itcBalance + amount,
            totalEarned: _currentUser!.totalEarned + amount,
          );
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        } else {
          _addTransaction('earn', amount, description);
        }
      }
    } finally {
      _isBusy = false;
    }
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
      case 'taskReward': return TransactionType.taskReward;
      default: return TransactionType.earn;
    }
  }

  // ─── Referral ───

  Future<bool> applyReferralCode(String code) async {
    if (_currentUser == null || _isBusy) return false;
    if (_currentUser!.referredBy != null) return false;
    if (code.toUpperCase() == _currentUser!.referralCode.toUpperCase()) return false;

    _isBusy = true;
    try {
      final result = await ApiService().applyReferral(code);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['transactions'] != null) {
          _transactions = _parseTransactionsFromApi(result['transactions']);
        }
        return true;
      }
      return false;
    } finally {
      _isBusy = false;
    }
  }

  // ─── Task / Site System ───

  Future<void> markTaskCompleted(String taskId) async {
    if (_currentUser == null) return;
    final updated = List<String>.from(_currentUser!.completedTasks);
    if (!updated.contains(taskId)) {
      updated.add(taskId);
      _currentUser = _currentUser!.copyWith(completedTasks: updated);
    }
  }

  Future<void> markSiteVisited(String siteId) async {
    if (_currentUser == null) return;
    final result = await ApiService().markSiteVisited(siteId);
    if (result['success'] == true) {
      if (result['user'] != null) {
        _currentUser = _parseUserFromApi(result['user']);
      } else {
        final updated = List<String>.from(_currentUser!.visitedSites);
        if (!updated.contains(siteId)) {
          updated.add(siteId);
          _currentUser = _currentUser!.copyWith(visitedSites: updated);
        }
      }
    }
  }

  Future<void> submitTaskForReview(String taskId, String screenshotPath, String siteUrl) async {
    if (_currentUser == null) return;
    final alreadySubmitted = _pendingTaskReviews.any(
      (r) => r['taskId'] == taskId && r['userEmail'] == _currentUser!.email && r['status'] == 'pending',
    );
    if (alreadySubmitted) return;

    final result = await ApiService().submitTaskReview(taskId, siteUrl);
    if (result['success'] == true) {
      final task = _allTasks.firstWhere((t) => t['id'] == taskId, orElse: () => {});
      _pendingTaskReviews.add({
        'id': result['review_id'] ?? 'review_${DateTime.now().millisecondsSinceEpoch}',
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
      await markTaskCompleted(taskId);
    }
  }

  // ─── Admin: ITC Management ───

  Future<void> adminAddItcToUser(String userEmail, double amount) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminCreditUser(userEmail, amount);
      if (result['success'] == true) {
        if (isAdmin) {
          await _loadAdminData();
        }
        if (_currentUser?.email == userEmail && result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
          if (result['transactions'] != null) {
            _transactions = _parseTransactionsFromApi(result['transactions']);
          }
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> adminRemoveItcFromUser(String userEmail, double amount) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminDebitUser(userEmail, amount);
      if (result['success'] == true) {
        if (isAdmin) {
          await _loadAdminData();
        }
        if (_currentUser?.email == userEmail && result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
          if (result['transactions'] != null) {
            _transactions = _parseTransactionsFromApi(result['transactions']);
          }
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  // ─── Admin: Task Management ───

  Future<void> adminAddTask(Map<String, dynamic> task) async {
    if (!isAdmin) return;
    await ApiService().adminAddTask(task);
    await _loadTasksFromApi();
  }

  Future<void> adminRemoveTask(String taskId) async {
    if (!isAdmin) return;
    await ApiService().adminRemoveTask(taskId);
    await _loadTasksFromApi();
  }

  Future<void> adminToggleTask(String taskId) async {
    if (!isAdmin) return;
    await ApiService().adminToggleTask(taskId);
    await _loadTasksFromApi();
  }

  Future<void> adminUpdateTask(String taskId, Map<String, dynamic> updates) async {
    if (!isAdmin) return;
    await ApiService().adminUpdateTask(taskId, updates);
    await _loadTasksFromApi();
  }

  // ─── Admin: Site Management ───

  Future<void> adminAddSite(Map<String, dynamic> site) async {
    if (!isAdmin) return;
    await ApiService().adminAddSite(site);
    await _loadSitesFromApi();
  }

  Future<void> adminRemoveSite(String siteId) async {
    if (!isAdmin) return;
    await ApiService().adminRemoveSite(siteId);
    await _loadSitesFromApi();
  }

  Future<void> adminToggleSite(String siteId) async {
    if (!isAdmin) return;
    await ApiService().adminToggleSite(siteId);
    await _loadSitesFromApi();
  }

  // ─── Admin: Animal Management ───

  Future<void> adminAddAnimal(Map<String, dynamic> animal) async {
    if (!isAdmin) return;
    await ApiService().adminAddAnimal(animal);
    await _loadAnimalsFromApi();
  }

  Future<void> adminUpdateAnimal(String animalId, Map<String, dynamic> updates) async {
    if (!isAdmin) return;
    await ApiService().adminUpdateAnimal(animalId, updates);
    await _loadAnimalsFromApi();
  }

  Future<void> adminRemoveAnimal(String animalId) async {
    if (!isAdmin) return;
    await ApiService().adminRemoveAnimal(animalId);
    await _loadAnimalsFromApi();
  }

  Future<void> adminToggleAnimal(String animalId) async {
    if (!isAdmin) return;
    await ApiService().adminToggleAnimal(animalId);
    await _loadAnimalsFromApi();
  }

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

  // ─── Admin: Review Management ───

  Future<void> adminApproveTaskReview(String reviewId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminApproveTaskReview(reviewId);
      if (result['success'] == true) {
        await _loadAdminData();
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> adminRejectTaskReview(String reviewId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminRejectTaskReview(reviewId);
      if (result['success'] == true) {
        await _loadAdminData();
      }
    } finally {
      _isBusy = false;
    }
  }

  // ─── Admin: User Management ───

  Future<void> adminDeleteUser(String email) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminDeleteUser(email);
      if (result['success'] == true) {
        await _loadAdminData();
      }
    } finally {
      _isBusy = false;
    }
  }

  // ─── Buy/Sell Requests ───

  Future<void> submitBuySellRequest(Map<String, dynamic> request) async {
    if (_currentUser == null || _isBusy) return;
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

    _isBusy = true;
    try {
      final amountUsd = request['amountUsd'] != null ? (request['amountUsd'] ?? 0).toDouble() : null;
      final result = await ApiService().submitBuySell(type, amountItc, amountUsd);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> approveBuySellRequest(String requestId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminApproveBuySell(requestId);
      if (result['success'] == true) {
        await _loadAdminData();
        if (result['user'] != null) {
          final userData = _parseUserFromApi(result['user']);
          if (_currentUser?.email == userData.email) {
            _currentUser = userData;
          }
        }
        if (result['admin_usd_balance'] != null) {
          _adminUsdBalance = (result['admin_usd_balance'] ?? 0).toDouble();
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> rejectBuySellRequest(String requestId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminRejectBuySell(requestId);
      if (result['success'] == true) {
        await _loadAdminData();
      }
    } finally {
      _isBusy = false;
    }
  }

  // ─── Withdrawal/Deposit Operations ───

  Future<void> requestWithdrawal(double amount, String walletAddress) async {
    if (_currentUser == null || _isBusy) return;
    if (amount < AppConstants.minWithdrawalItc) return;
    if (_currentUser!.itcBalance < amount) return;
    _isBusy = true;

    try {
      final result = await ApiService().requestWithdrawal(amount, walletAddress);
      if (result['success'] == true) {
        if (result['user'] != null) {
          _currentUser = _parseUserFromApi(result['user']);
        }
        if (result['withdrawals'] != null) {
          _withdrawalRequests = List<Map<String, dynamic>>.from(
            result['withdrawals'].map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> requestDeposit(double amount, String txHash) async {
    if (_currentUser == null || _isBusy) return;
    if (amount <= 0) return;
    if (txHash.trim().isEmpty) return;
    _isBusy = true;

    try {
      final result = await ApiService().requestDeposit(amount, txHash);
      if (result['success'] == true) {
        if (result['deposits'] != null) {
          _depositRequests = List<Map<String, dynamic>>.from(
            result['deposits'].map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> approveDeposit(String depositId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminApproveDeposit(depositId);
      if (result['success'] == true) {
        await _loadAdminData();
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> rejectDeposit(String depositId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminRejectDeposit(depositId);
      if (result['success'] == true) {
        await _loadAdminData();
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> approveWithdrawal(String withdrawalId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminApproveWithdrawal(withdrawalId);
      if (result['success'] == true) {
        await _loadAdminData();
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> rejectWithdrawal(String withdrawalId) async {
    if (!isAdmin || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().adminRejectWithdrawal(withdrawalId);
      if (result['success'] == true) {
        await _loadAdminData();
        if (result['user'] != null) {
          final userData = _parseUserFromApi(result['user']);
          if (_currentUser?.email == userData.email) {
            _currentUser = userData;
          }
        }
      }
    } finally {
      _isBusy = false;
    }
  }

  // ─── Account Management ───

  Future<void> deleteAccount() async {
    if (_currentUser == null || _isBusy) return;
    _isBusy = true;

    try {
      final result = await ApiService().deleteAccount();
      if (result['success'] == true) {
        _currentUser = null;
        _transactions = [];
        _userAnimals = [];
        _userStakings = [];
        _allUsers = [];
        _pendingTaskReviews = [];
        _withdrawalRequests = [];
        _depositRequests = [];
        _buySellRequests = [];
        _lastGiftBoxClaim = null;
        _lastWheelSpin = null;
        _adminUsdBalance = 0.0;
      }
    } finally {
      _isBusy = false;
    }
  }
}
