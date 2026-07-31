class UserModel {
  final String uid;
  final String name;
  final String? email;
  final String? photoUrl;
  final double itcBalance;
  final double totalEarned;
  final String referralCode;
  final String? referredBy;
  final int totalReferrals;
  final int activeReferrals;
  final double referralEarnings;
  final DailyLoginData dailyLogin;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<String> completedTasks;
  final List<String> visitedSites;

  UserModel({
    required this.uid,
    required this.name,
    this.email,
    this.photoUrl,
    this.itcBalance = 0.0,
    this.totalEarned = 0.0,
    required this.referralCode,
    this.referredBy,
    this.totalReferrals = 0,
    this.activeReferrals = 0,
    this.referralEarnings = 0.0,
    required this.dailyLogin,
    required this.createdAt,
    required this.lastActive,
    this.completedTasks = const [],
    this.visitedSites = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'itcBalance': itcBalance,
      'totalEarned': totalEarned,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'totalReferrals': totalReferrals,
      'activeReferrals': activeReferrals,
      'referralEarnings': referralEarnings,
      'dailyLogin': dailyLogin.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'completedTasks': completedTasks,
      'visitedSites': visitedSites,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'مستخدم',
      email: data['email'],
      photoUrl: data['photoUrl'],
      itcBalance: (data['itcBalance'] ?? 0).toDouble(),
      totalEarned: (data['totalEarned'] ?? 0).toDouble(),
      referralCode: data['referralCode'] ?? '',
      referredBy: data['referredBy'],
      totalReferrals: data['totalReferrals'] ?? 0,
      activeReferrals: data['activeReferrals'] ?? 0,
      referralEarnings: (data['referralEarnings'] ?? 0).toDouble(),
      dailyLogin: DailyLoginData.fromMap(data['dailyLogin'] ?? {}),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      lastActive: DateTime.tryParse(data['lastActive'] ?? '') ?? DateTime.now(),
      completedTasks: List<String>.from(data['completedTasks'] ?? []),
      visitedSites: List<String>.from(data['visitedSites'] ?? []),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    double? itcBalance,
    double? totalEarned,
    String? referralCode,
    String? referredBy,
    int? totalReferrals,
    int? activeReferrals,
    double? referralEarnings,
    DailyLoginData? dailyLogin,
    DateTime? lastActive,
    List<String>? completedTasks,
    List<String>? visitedSites,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      itcBalance: itcBalance ?? this.itcBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      activeReferrals: activeReferrals ?? this.activeReferrals,
      referralEarnings: referralEarnings ?? this.referralEarnings,
      dailyLogin: dailyLogin ?? this.dailyLogin,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
      completedTasks: completedTasks ?? this.completedTasks,
      visitedSites: visitedSites ?? this.visitedSites,
    );
  }

  static String generateReferralCode(String uid) {
    final short = uid.length > 6 ? uid.substring(0, 6) : uid;
    return 'HP$short'.toUpperCase();
  }
}

class DailyLoginData {
  final DateTime? lastLogin;
  final int streak;
  final bool claimedToday;

  DailyLoginData({
    this.lastLogin,
    this.streak = 0,
    this.claimedToday = false,
  });

  factory DailyLoginData.fromMap(Map<String, dynamic> data) {
    return DailyLoginData(
      lastLogin: DateTime.tryParse(data['lastLogin'] ?? ''),
      streak: data['streak'] ?? 0,
      claimedToday: data['claimedToday'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastLogin': lastLogin?.toIso8601String(),
      'streak': streak,
      'claimedToday': claimedToday,
    };
  }

  DailyLoginData copyWith({
    DateTime? lastLogin,
    int? streak,
    bool? claimedToday,
  }) {
    return DailyLoginData(
      lastLogin: lastLogin ?? this.lastLogin,
      streak: streak ?? this.streak,
      claimedToday: claimedToday ?? this.claimedToday,
    );
  }

  int get nextReward => ((streak + 1) * 10).clamp(10, 100);

  bool get canClaimToday => !claimedToday;

  bool get streakBroken {
    if (lastLogin == null) return false;
    final now = DateTime.now();
    final lastDate = DateTime(lastLogin!.year, lastLogin!.month, lastLogin!.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(lastDate).inDays;
    return diff > 1;
  }
}
