enum CryptoType { itc }

class WithdrawalRequest {
  final String id;
  final String userEmail;
  final String userName;
  final double amount;
  final String walletAddress;
  final String status;
  final DateTime createdAt;

  WithdrawalRequest({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.amount,
    required this.walletAddress,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userEmail': userEmail,
    'userName': userName,
    'amount': amount,
    'walletAddress': walletAddress,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WithdrawalRequest.fromMap(Map<String, dynamic> data) => WithdrawalRequest(
    id: data['id'] ?? '',
    userEmail: data['userEmail'] ?? '',
    userName: data['userName'] ?? '',
    amount: (data['amount'] ?? 0).toDouble(),
    walletAddress: data['walletAddress'] ?? '',
    status: data['status'] ?? 'pending',
    createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class DepositRequest {
  final String id;
  final String userEmail;
  final String userName;
  final double amount;
  final String txHash;
  final String status;
  final DateTime createdAt;

  DepositRequest({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.amount,
    required this.txHash,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userEmail': userEmail,
    'userName': userName,
    'amount': amount,
    'txHash': txHash,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DepositRequest.fromMap(Map<String, dynamic> data) => DepositRequest(
    id: data['id'] ?? '',
    userEmail: data['userEmail'] ?? '',
    userName: data['userName'] ?? '',
    amount: (data['amount'] ?? 0).toDouble(),
    txHash: data['txHash'] ?? '',
    status: data['status'] ?? 'pending',
    createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
  );
}
