enum TransactionType { earn, spend, deposit, referral, purchase, taskReward }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final double balance;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.balance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'description': description,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'] ?? '',
      type: _parseTransactionType(data['type'] ?? 'earn'),
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'earn':
        return TransactionType.earn;
      case 'spend':
        return TransactionType.spend;
      case 'deposit':
        return TransactionType.deposit;
      case 'referral':
        return TransactionType.referral;
      case 'purchase':
        return TransactionType.purchase;
      case 'taskReward':
        return TransactionType.taskReward;
      default:
        return TransactionType.earn;
    }
  }

  String get typeEmoji {
    switch (type) {
      case TransactionType.earn:
        return '💰';
      case TransactionType.spend:
        return '💸';
      case TransactionType.deposit:
        return '💵';
      case TransactionType.referral:
        return '👥';
      case TransactionType.purchase:
        return '🛒';
      case TransactionType.taskReward:
        return '✅';
    }
  }

  String get typeName {
    switch (type) {
      case TransactionType.earn:
        return 'Earn';
      case TransactionType.spend:
        return 'Spend';
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.referral:
        return 'Referral';
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.taskReward:
        return 'Task';
    }
  }

  bool get isPositive => type == TransactionType.earn || type == TransactionType.deposit || type == TransactionType.referral || type == TransactionType.taskReward;

  String get formattedAmount => isPositive ? '+$amount' : '-$amount';
}
