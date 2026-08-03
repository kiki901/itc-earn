import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'https://stakingitc.space/api/api.php';
  static const String _keyToken = 'api_token';
  static const String _keyUserEmail = 'api_user_email';

  SharedPreferences? _prefs;
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString(_keyToken);
  }

  String? get savedEmail => _prefs?.getString(_keyUserEmail);

  Future<void> _saveToken(String token) async {
    _token = token;
    await _prefs?.setString(_keyToken, token);
  }

  Future<void> _clearToken() async {
    _token = null;
    await _prefs?.remove(_keyToken);
  }

  Future<void> _saveEmail(String email) async {
    await _prefs?.setString(_keyUserEmail, email);
  }

  Future<void> _clearEmail() async {
    await _prefs?.remove(_keyUserEmail);
  }

  Future<Map<String, dynamic>> post(String action, [Map<String, String>? params]) async {
    try {
      final allParams = <String, String>{
        'action': action,
      };
      if (params != null) {
        allParams.addAll(params);
      }
      if (_token != null) {
        allParams['token'] = _token!;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        body: allParams,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 401) {
        await _clearToken();
        return {'success': false, 'message': 'Session expired. Please login again.'};
      } else {
        return {'success': false, 'message': 'Server error (${response.statusCode})'};
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        return {'success': false, 'message': 'Network error. Please check your connection.'};
      }
      return {'success': false, 'message': 'An error occurred: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final result = await post('register', {
      'name': name,
      'email': email,
      'password': password,
    });
    if (result['success'] == true && result['token'] != null) {
      await _saveToken(result['token']);
      await _saveEmail(email);
    }
    return result;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await post('login', {
      'email': email,
      'password': password,
    });
    if (result['success'] == true && result['token'] != null) {
      await _saveToken(result['token']);
      await _saveEmail(email);
    }
    return result;
  }

  Future<void> logout() async {
    await _clearToken();
    await _clearEmail();
  }

  Future<bool> userExists(String email) async {
    final result = await post('user_exists', {
      'email': email,
    });
    return result['exists'] == true;
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    return await post('reset_password', {
      'email': email,
      'new_password': newPassword,
    });
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await post('get_profile');
  }

  Future<Map<String, dynamic>> getUserData() async {
    return await post('get_user_data');
  }

  Future<List<dynamic>> getTasks() async {
    final result = await post('get_tasks');
    if (result['success'] == true && result['tasks'] != null) {
      return result['tasks'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getSites() async {
    final result = await post('get_sites');
    if (result['success'] == true && result['sites'] != null) {
      return result['sites'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getAnimals() async {
    final result = await post('get_animals');
    if (result['success'] == true && result['animals'] != null) {
      return result['animals'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> claimDailyLogin() async {
    return await post('claim_daily_login');
  }

  Future<Map<String, dynamic>> claimGiftBox() async {
    return await post('claim_gift_box');
  }

  Future<Map<String, dynamic>> spinWheel(String prizeType, double prizeValue) async {
    return await post('spin_wheel', {
      'prize_type': prizeType,
      'prize_value': prizeValue.toString(),
    });
  }

  Future<Map<String, dynamic>> paidSpin() async {
    return await post('paid_spin');
  }

  Future<Map<String, dynamic>> buyAnimal(String animalId) async {
    return await post('buy_animal', {
      'animal_id': animalId,
    });
  }

  Future<Map<String, dynamic>> collectAnimal(String instanceId) async {
    return await post('collect_animal', {
      'instance_id': instanceId,
    });
  }

  Future<Map<String, dynamic>> stake(String tier) async {
    return await post('stake', {
      'tier': tier,
    });
  }

  Future<Map<String, dynamic>> claimStaking(String stakingId) async {
    return await post('claim_staking', {
      'staking_id': stakingId,
    });
  }

  Future<Map<String, dynamic>> earlyUnstake(String stakingId) async {
    return await post('early_unstake', {
      'staking_id': stakingId,
    });
  }

  Future<Map<String, dynamic>> applyReferral(String code) async {
    return await post('apply_referral', {
      'code': code,
    });
  }

  Future<Map<String, dynamic>> submitTaskReview(String taskId, String siteUrl) async {
    return await post('submit_task_review', {
      'task_id': taskId,
      'site_url': siteUrl,
    });
  }

  Future<Map<String, dynamic>> submitBuySell(String type, double amountItc, double? amountUsd) async {
    final params = <String, String>{
      'type': type,
      'amount_itc': amountItc.toString(),
    };
    if (amountUsd != null) {
      params['amount_usd'] = amountUsd.toString();
    }
    return await post('submit_buy_sell', params);
  }

  Future<Map<String, dynamic>> requestWithdrawal(double amount, String walletAddress) async {
    return await post('request_withdrawal', {
      'amount': amount.toString(),
      'wallet_address': walletAddress,
    });
  }

  Future<Map<String, dynamic>> requestDeposit(double amount, String txHash) async {
    return await post('request_deposit', {
      'amount': amount.toString(),
      'tx_hash': txHash,
    });
  }

  Future<Map<String, dynamic>> markSiteVisited(String siteId) async {
    return await post('mark_site_visited', {
      'site_id': siteId,
    });
  }

  Future<List<dynamic>> getAllUsers() async {
    final result = await post('get_all_users');
    if (result['success'] == true && result['users'] != null) {
      return result['users'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getPendingReviews() async {
    final result = await post('get_pending_reviews');
    if (result['success'] == true && result['reviews'] != null) {
      return result['reviews'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getMarketRequests() async {
    final result = await post('get_market_requests');
    if (result['success'] == true && result['requests'] != null) {
      return result['requests'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getWithdrawals() async {
    final result = await post('get_withdrawals');
    if (result['success'] == true && result['withdrawals'] != null) {
      return result['withdrawals'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> getDeposits() async {
    final result = await post('get_deposits');
    if (result['success'] == true && result['deposits'] != null) {
      return result['deposits'] as List<dynamic>;
    }
    return [];
  }

  Future<Map<String, dynamic>> adminCreditUser(String email, double amount) async {
    return await post('admin_credit_user', {
      'email': email,
      'amount': amount.toString(),
    });
  }

  Future<Map<String, dynamic>> adminDebitUser(String email, double amount) async {
    return await post('admin_debit_user', {
      'email': email,
      'amount': amount.toString(),
    });
  }

  Future<Map<String, dynamic>> adminAddTask(Map<String, dynamic> task) async {
    final params = <String, String>{};
    task.forEach((key, value) {
      params[key] = value.toString();
    });
    return await post('admin_add_task', params);
  }

  Future<Map<String, dynamic>> adminRemoveTask(String taskId) async {
    return await post('admin_remove_task', {
      'task_id': taskId,
    });
  }

  Future<Map<String, dynamic>> adminToggleTask(String taskId) async {
    return await post('admin_toggle_task', {
      'task_id': taskId,
    });
  }

  Future<Map<String, dynamic>> adminUpdateTask(String taskId, Map<String, dynamic> updates) async {
    final params = <String, String>{
      'task_id': taskId,
    };
    updates.forEach((key, value) {
      params[key] = value.toString();
    });
    return await post('admin_update_task', params);
  }

  Future<Map<String, dynamic>> adminAddSite(Map<String, dynamic> site) async {
    final params = <String, String>{};
    site.forEach((key, value) {
      params[key] = value.toString();
    });
    return await post('admin_add_site', params);
  }

  Future<Map<String, dynamic>> adminRemoveSite(String siteId) async {
    return await post('admin_remove_site', {
      'site_id': siteId,
    });
  }

  Future<Map<String, dynamic>> adminToggleSite(String siteId) async {
    return await post('admin_toggle_site', {
      'site_id': siteId,
    });
  }

  Future<Map<String, dynamic>> adminAddAnimal(Map<String, dynamic> animal) async {
    final params = <String, String>{};
    animal.forEach((key, value) {
      params[key] = value.toString();
    });
    return await post('admin_add_animal', params);
  }

  Future<Map<String, dynamic>> adminRemoveAnimal(String animalId) async {
    return await post('admin_remove_animal', {
      'animal_id': animalId,
    });
  }

  Future<Map<String, dynamic>> adminToggleAnimal(String animalId) async {
    return await post('admin_toggle_animal', {
      'animal_id': animalId,
    });
  }

  Future<Map<String, dynamic>> adminUpdateAnimal(String animalId, Map<String, dynamic> updates) async {
    final params = <String, String>{
      'animal_id': animalId,
    };
    updates.forEach((key, value) {
      params[key] = value.toString();
    });
    return await post('admin_update_animal', params);
  }

  Future<Map<String, dynamic>> adminDeleteUser(String email) async {
    return await post('admin_delete_user', {
      'email': email,
    });
  }

  Future<Map<String, dynamic>> adminApproveTaskReview(String reviewId) async {
    return await post('admin_approve_task_review', {
      'review_id': reviewId,
    });
  }

  Future<Map<String, dynamic>> adminRejectTaskReview(String reviewId) async {
    return await post('admin_reject_task_review', {
      'review_id': reviewId,
    });
  }

  Future<Map<String, dynamic>> adminApproveBuySell(String requestId) async {
    return await post('admin_approve_buy_sell', {
      'request_id': requestId,
    });
  }

  Future<Map<String, dynamic>> adminRejectBuySell(String requestId) async {
    return await post('admin_reject_buy_sell', {
      'request_id': requestId,
    });
  }

  Future<Map<String, dynamic>> adminApproveWithdrawal(String requestId) async {
    return await post('admin_approve_withdrawal', {
      'request_id': requestId,
    });
  }

  Future<Map<String, dynamic>> adminRejectWithdrawal(String requestId) async {
    return await post('admin_reject_withdrawal', {
      'request_id': requestId,
    });
  }

  Future<Map<String, dynamic>> adminApproveDeposit(String requestId) async {
    return await post('admin_approve_deposit', {
      'request_id': requestId,
    });
  }

  Future<Map<String, dynamic>> adminRejectDeposit(String requestId) async {
    return await post('admin_reject_deposit', {
      'request_id': requestId,
    });
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final result = await post('delete_account');
    if (result['success'] == true) {
      await logout();
    }
    return result;
  }

  Future<Map<String, dynamic>> seed() async {
    return await post('seed');
  }
}
