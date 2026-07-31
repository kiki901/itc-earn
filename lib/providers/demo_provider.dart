import 'package:flutter/material.dart';
import 'package:hamster_points/services/demo_service.dart';
import 'package:hamster_points/models/user_model.dart';
import 'package:hamster_points/models/transaction_model.dart';
import 'package:hamster_points/models/animal_model.dart';
import 'package:hamster_points/models/staking_model.dart';
import 'package:hamster_points/utils/constants.dart';

class DemoProvider with ChangeNotifier {
  final DemoService _demoService = DemoService();
  bool _disposed = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _demoService.isAuthenticated;
  bool get isAdmin => _demoService.isAdmin;
  UserModel? get user => _demoService.currentUser;
  List<TransactionModel> get transactions => _demoService.transactions;
  List<UserAnimal> get userAnimals => _demoService.userAnimals;
  List<AnimalModel> get availableAnimals => _demoService.getAvailableAnimals();
  UserAnimal? getUserAnimalByType(AnimalType type) {
    final matches = _demoService.userAnimals.where((a) => a.animalType == type);
    return matches.isNotEmpty ? matches.first : null;
  }
  List<Map<String, dynamic>> get allUsers => _demoService.allUsers;
  List<Map<String, dynamic>> get allTasks => _demoService.allTasks;
  List<Map<String, dynamic>> get allSites => _demoService.allSites;
  List<Map<String, dynamic>> get allAnimals => _demoService.allAnimals;
  int get totalUsers => _demoService.totalUsers;
  double get totalItcInCirculation => _demoService.totalItcInCirculation;
  double get adminUsdBalance => _demoService.adminUsdBalance;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    _isLoading = true;
    _safeNotify();
    try {
      await _demoService.initialize();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    _safeNotify();
    try {
      final error = await _demoService.register(name, email, password);
      return error;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _safeNotify();
    try {
      final error = await _demoService.login(email, password);
      return error;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> userExists(String email) async {
    return await _demoService.userExists(email);
  }

  Future<String?> resetPassword(String email, String newPassword) async {
    return await _demoService.resetPassword(email, newPassword);
  }

  Future<void> logout() async {
    await _demoService.logout();
    _safeNotify();
  }

  Future<bool> applyReferralCode(String code) async {
    final result = await _demoService.applyReferralCode(code);
    _safeNotify();
    return result;
  }

  bool isTaskCompleted(String taskId) => _demoService.currentUser?.completedTasks.contains(taskId) ?? false;
  bool isSiteVisited(String siteId) => _demoService.currentUser?.visitedSites.contains(siteId) ?? false;

  Future<void> markSiteVisited(String siteId) async {
    await _demoService.markSiteVisited(siteId);
    _safeNotify();
  }

  Future<double> claimDailyLogin() async {
    final reward = await _demoService.claimDailyLogin();
    _safeNotify();
    return reward;
  }

  Future<bool> buyAnimal(AnimalModel animal) async {
    _isLoading = true;
    _safeNotify();
    try {
      final success = await _demoService.buyAnimal(animal);
      return success;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<double> collectAnimalProfit(UserAnimal userAnimal, AnimalModel animalInfo) async {
    final amount = await _demoService.collectAnimalProfit(userAnimal, animalInfo);
    _safeNotify();
    return amount;
  }


  Future<void> addItc(double amount, String description) async {
    await _demoService.addItc(amount, description);
    _safeNotify();
  }

  Future<void> adminAddItcToUser(String email, double amount) async {
    await _demoService.adminAddItcToUser(email, amount);
    _safeNotify();
  }

  Future<void> adminRemoveItcFromUser(String email, double amount) async {
    await _demoService.adminRemoveItcFromUser(email, amount);
    _safeNotify();
  }

  Future<void> adminAddTask(Map<String, dynamic> task) async {
    await _demoService.adminAddTask(task);
    _safeNotify();
  }

  Future<void> adminRemoveTask(String taskId) async {
    await _demoService.adminRemoveTask(taskId);
    _safeNotify();
  }

  Future<void> adminToggleTask(String taskId) async {
    await _demoService.adminToggleTask(taskId);
    _safeNotify();
  }

  Future<void> adminUpdateTask(String taskId, Map<String, dynamic> updates) async {
    await _demoService.adminUpdateTask(taskId, updates);
    _safeNotify();
  }

  Future<void> adminAddSite(Map<String, dynamic> site) async {
    await _demoService.adminAddSite(site);
    _safeNotify();
  }

  Future<void> adminRemoveSite(String siteId) async {
    await _demoService.adminRemoveSite(siteId);
    _safeNotify();
  }

  Future<void> adminToggleSite(String siteId) async {
    await _demoService.adminToggleSite(siteId);
    _safeNotify();
  }

  Future<void> adminAddAnimal(Map<String, dynamic> animal) async {
    await _demoService.adminAddAnimal(animal);
    _safeNotify();
  }

  Future<void> adminUpdateAnimal(String animalId, Map<String, dynamic> updates) async {
    await _demoService.adminUpdateAnimal(animalId, updates);
    _safeNotify();
  }

  Future<void> adminRemoveAnimal(String animalId) async {
    await _demoService.adminRemoveAnimal(animalId);
    _safeNotify();
  }

  Future<void> adminToggleAnimal(String animalId) async {
    await _demoService.adminToggleAnimal(animalId);
    _safeNotify();
  }

  Future<void> adminDeleteUser(String email) async {
    await _demoService.adminDeleteUser(email);
    _safeNotify();
  }

  Future<void> deleteAccount() async {
    await _demoService.deleteAccount();
    _safeNotify();
  }

  Future<void> submitTaskForReview(String taskId, String screenshotPath, String code) async {
    await _demoService.submitTaskForReview(taskId, screenshotPath, code);
    _safeNotify();
  }

  List<Map<String, dynamic>> get pendingTaskReviews => _demoService.pendingTaskReviews;

  Future<void> adminApproveTaskReview(String reviewId) async {
    await _demoService.adminApproveTaskReview(reviewId);
    _safeNotify();
  }

  Future<void> adminRejectTaskReview(String reviewId) async {
    await _demoService.adminRejectTaskReview(reviewId);
    _safeNotify();
  }

  // ─── Buy/Sell ITC ───

  List<Map<String, dynamic>> get allBuySellRequests => _demoService.allBuySellRequests;
  List<Map<String, dynamic>> get userBuySellRequests => _demoService.userBuySellRequests;

  Future<void> submitBuySellRequest(Map<String, dynamic> request) async {
    await _demoService.submitBuySellRequest(request);
    _safeNotify();
  }

  Future<void> approveBuySellRequest(String requestId) async {
    await _demoService.approveBuySellRequest(requestId);
    await _demoService.initialize();
    _safeNotify();
  }

  Future<void> rejectBuySellRequest(String requestId) async {
    await _demoService.rejectBuySellRequest(requestId);
    _safeNotify();
  }

  Future<void> reloadAll() async {
    await _demoService.initialize();
    _safeNotify();
  }

  AnimalModel? getAnimalInfo(AnimalType type) {
    try {
      return availableAnimals.firstWhere((a) => a.type == type);
    } catch (_) {
      return null;
    }
  }

  bool canCollect(UserAnimal userAnimal) {
    final info = getAnimalInfo(userAnimal.animalType);
    if (info == null) return false;
    return userAnimal.canCollect(info.collectionInterval);
  }

  int collectibleAmount(UserAnimal userAnimal) {
    final info = getAnimalInfo(userAnimal.animalType);
    if (info == null) return 0;
    return userAnimal.collectibleAmount(info.dailyProfit, info.collectionInterval);
  }

  Duration timeUntilNextCollection(UserAnimal userAnimal) {
    final info = getAnimalInfo(userAnimal.animalType);
    if (info == null) return Duration(hours: 12);
    return userAnimal.timeUntilNextCollection(info.collectionInterval);
  }

  int get totalDailyProfit {
    int total = 0;
    for (final ua in userAnimals) {
      if (ua.isExpired) continue;
      final info = getAnimalInfo(ua.animalType);
      if (info != null) {
        total += info.dailyProfit * ua.quantity;
      }
    }
    return total;
  }

  double get dailyEarnings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return transactions
        .where((tx) => tx.isPositive && tx.createdAt.isAfter(today))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get weeklyEarnings {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return transactions
        .where((tx) => tx.isPositive && tx.createdAt.isAfter(weekAgo))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // ─── ITC Withdrawal/Deposit ───
  List<Map<String, dynamic>> get withdrawalRequests => _demoService.withdrawalRequests;
  List<Map<String, dynamic>> get depositRequests => _demoService.depositRequests;

  Future<void> requestWithdrawal(double amount, String walletAddress) async {
    await _demoService.requestWithdrawal(amount, walletAddress);
    _safeNotify();
  }

  Future<void> requestDeposit(double amount, String txHash) async {
    await _demoService.requestDeposit(amount, txHash);
    _safeNotify();
  }

  Future<void> approveDeposit(String depositId) async {
    await _demoService.approveDeposit(depositId);
    _safeNotify();
  }

  Future<void> rejectDeposit(String depositId) async {
    await _demoService.rejectDeposit(depositId);
    _safeNotify();
  }

  Future<void> approveWithdrawal(String withdrawalId) async {
    await _demoService.approveWithdrawal(withdrawalId);
    _safeNotify();
  }

  Future<void> rejectWithdrawal(String withdrawalId) async {
    await _demoService.rejectWithdrawal(withdrawalId);
    _safeNotify();
  }

  // ─── Gift Box ───
  bool get isGiftBoxAvailable => _demoService.isGiftBoxAvailable;
  Duration get timeUntilNextGiftBox => _demoService.timeUntilNextGiftBox;

  Future<double> claimGiftBox() async {
    final reward = await _demoService.claimGiftBox();
    _safeNotify();
    return reward;
  }

  // ─── Lucky Wheel ───
  bool get isWheelAvailable => _demoService.isWheelAvailable;
  Duration get timeUntilNextWheel => _demoService.timeUntilNextWheel;
  bool get canBuySpin => (_demoService.currentUser?.itcBalance ?? 0) >= AppConstants.wheelPaidSpinCost;

  Future<void> spinWheel(String prizeType, double prizeValue) async {
    await _demoService.spinWheel(prizeType, prizeValue);
    _safeNotify();
  }

  Future<Map<String, dynamic>?> buySpinWheel() async {
    final result = await _demoService.paidSpinWheel();
    _safeNotify();
    return result;
  }

  // ─── Staking / Farming Boost ───
  List<UserStaking> get userStakings => _demoService.userStakings;
  double get totalStaked => _demoService.totalStaked;
  double get totalStakingProfit => _demoService.totalStakingProfit;

  bool canStake(StakingPlan plan) => _demoService.canStake(plan);

  Future<bool> stake(StakingPlan plan) async {
    final result = await _demoService.stake(plan);
    _safeNotify();
    return result;
  }

  Future<double> claimStaking(String stakingId) async {
    final result = await _demoService.claimStaking(stakingId);
    _safeNotify();
    return result;
  }

  Future<double> earlyUnstake(String stakingId) async {
    final result = await _demoService.earlyUnstake(stakingId);
    _safeNotify();
    return result;
  }
}
