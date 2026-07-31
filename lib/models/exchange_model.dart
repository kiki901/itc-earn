enum OrderType { buy, sell }
enum OrderStatus { pending, filled, cancelled }

class ExchangeOrder {
  final String id;
  final String userEmail;
  final String userName;
  final OrderType type;
  final double amount;
  final double price;
  final OrderStatus status;
  final DateTime createdAt;

  ExchangeOrder({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.type,
    required this.amount,
    required this.price,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  double get total => amount * price;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userEmail': userEmail,
    'userName': userName,
    'type': type.name,
    'amount': amount,
    'price': price,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ExchangeOrder.fromMap(Map<String, dynamic> data) => ExchangeOrder(
    id: data['id'] ?? '',
    userEmail: data['userEmail'] ?? '',
    userName: data['userName'] ?? '',
    type: OrderType.values.firstWhere((e) => e.name == data['type'], orElse: () => OrderType.buy),
    amount: (data['amount'] ?? 0).toDouble(),
    price: (data['price'] ?? 0).toDouble(),
    status: OrderStatus.values.firstWhere((e) => e.name == data['status'], orElse: () => OrderStatus.pending),
    createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
  );

  ExchangeOrder copyWith({OrderStatus? status}) => ExchangeOrder(
    id: id,
    userEmail: userEmail,
    userName: userName,
    type: type,
    amount: amount,
    price: price,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}

class ExchangeTrade {
  final String id;
  final String buyerEmail;
  final String sellerEmail;
  final double amount;
  final double price;
  final DateTime createdAt;

  ExchangeTrade({
    required this.id,
    required this.buyerEmail,
    required this.sellerEmail,
    required this.amount,
    required this.price,
    required this.createdAt,
  });

  double get total => amount * price;

  Map<String, dynamic> toMap() => {
    'id': id,
    'buyerEmail': buyerEmail,
    'sellerEmail': sellerEmail,
    'amount': amount,
    'price': price,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ExchangeTrade.fromMap(Map<String, dynamic> data) => ExchangeTrade(
    id: data['id'] ?? '',
    buyerEmail: data['buyerEmail'] ?? '',
    sellerEmail: data['sellerEmail'] ?? '',
    amount: (data['amount'] ?? 0).toDouble(),
    price: (data['price'] ?? 0).toDouble(),
    createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class MarketState {
  double currentPrice;
  double basePrice;
  List<double> priceHistory;
  double high24h;
  double low24h;
  double volume24h;
  double change24h;

  MarketState({
    this.currentPrice = 0.02,
    this.basePrice = 0.02,
    List<double>? priceHistory,
    this.high24h = 0.02,
    this.low24h = 0.02,
    this.volume24h = 0,
    this.change24h = 0,
  }) : priceHistory = priceHistory ?? [0.02];

  double get changePercent => basePrice > 0 ? ((currentPrice - basePrice) / basePrice) * 100 : 0;

  Map<String, dynamic> toMap() => {
    'currentPrice': currentPrice,
    'basePrice': basePrice,
    'priceHistory': priceHistory,
    'high24h': high24h,
    'low24h': low24h,
    'volume24h': volume24h,
    'change24h': change24h,
  };

  factory MarketState.fromMap(Map<String, dynamic> data) => MarketState(
    currentPrice: (data['currentPrice'] ?? 0.02).toDouble(),
    basePrice: (data['basePrice'] ?? 0.02).toDouble(),
    priceHistory: List<double>.from((data['priceHistory'] ?? [0.02]).map((e) => (e as num).toDouble())),
    high24h: (data['high24h'] ?? 0.02).toDouble(),
    low24h: (data['low24h'] ?? 0.02).toDouble(),
    volume24h: (data['volume24h'] ?? 0).toDouble(),
    change24h: (data['change24h'] ?? 0).toDouble(),
  );
}

class UserExchangeBalance {
  final double usdBalance;

  UserExchangeBalance({this.usdBalance = 0});

  Map<String, dynamic> toMap() => {'usdBalance': usdBalance};

  factory UserExchangeBalance.fromMap(Map<String, dynamic> data) =>
      UserExchangeBalance(usdBalance: (data['usdBalance'] ?? 0).toDouble());
}
