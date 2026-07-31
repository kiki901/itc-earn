enum AnimalType { chicken, cow, dog, horse, elephant, dragon, lion, phoenix, unicorn }

class AnimalModel {
  final String id;
  final AnimalType type;
  final String name;
  final int price;
  final int dailyProfit;
  final String emoji;
  final int lifespan;
  final int collectionInterval;
  final bool available;

  AnimalModel({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.dailyProfit,
    required this.emoji,
    this.lifespan = 90,
    this.collectionInterval = 12,
    this.available = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'price': price,
      'dailyProfit': dailyProfit,
      'emoji': emoji,
      'lifespan': lifespan,
      'collectionInterval': collectionInterval,
      'available': available,
    };
  }

  factory AnimalModel.fromMap(Map<String, dynamic> data) {
    return AnimalModel(
      id: data['id'] ?? '',
      type: _parseAnimalType(data['type'] ?? 'chicken'),
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      dailyProfit: data['dailyProfit'] ?? 0,
      emoji: data['emoji'] ?? '🐔',
      lifespan: data['lifespan'] ?? 90,
      collectionInterval: data['collectionInterval'] ?? 12,
      available: data['available'] ?? true,
    );
  }

  static AnimalType _parseAnimalType(String type) {
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

  static List<AnimalModel> getDefaultAnimals() {
    return [
      AnimalModel(id: 'chicken', type: AnimalType.chicken, name: 'دجاجة', price: 1000, dailyProfit: 20, emoji: '🐔', lifespan: 90),
      AnimalModel(id: 'cow', type: AnimalType.cow, name: 'بقرة', price: 5000, dailyProfit: 100, emoji: '🐄', lifespan: 90),
      AnimalModel(id: 'dog', type: AnimalType.dog, name: 'كلب', price: 20000, dailyProfit: 400, emoji: '🐕', lifespan: 90),
      AnimalModel(id: 'horse', type: AnimalType.horse, name: 'حصان', price: 50000, dailyProfit: 1000, emoji: '🐎', lifespan: 90),
      AnimalModel(id: 'elephant', type: AnimalType.elephant, name: 'فيل', price: 100000, dailyProfit: 2000, emoji: '🐘', lifespan: 90),
      AnimalModel(id: 'dragon', type: AnimalType.dragon, name: 'تنين', price: 200000, dailyProfit: 4000, emoji: '🐉', lifespan: 90),
      AnimalModel(id: 'lion', type: AnimalType.lion, name: 'أسد نادر', price: 500000, dailyProfit: 12000, emoji: '🦁', lifespan: 0),
      AnimalModel(id: 'phoenix', type: AnimalType.phoenix, name: 'طائر النار', price: 500000, dailyProfit: 15000, emoji: '🔥', lifespan: 0),
      AnimalModel(id: 'unicorn', type: AnimalType.unicorn, name: 'أحادي القرن', price: 500000, dailyProfit: 18000, emoji: '🦄', lifespan: 0),
    ];
  }

  int get profitPerHour => (dailyProfit / 24).ceil();
  int get profitPerCollection => (dailyProfit * collectionInterval / 24).ceil();
}

class UserAnimal {
  final String instanceId;
  final AnimalType animalType;
  final DateTime purchasedAt;
  final DateTime lastCollectedAt;
  final int quantity;
  final DateTime expiresAt;
  final String purchaseMethod;

  UserAnimal({
    required this.instanceId,
    required this.animalType,
    required this.purchasedAt,
    required this.lastCollectedAt,
    this.quantity = 1,
    required this.expiresAt,
    this.purchaseMethod = 'points',
  });

  Map<String, dynamic> toMap() {
    return {
      'instanceId': instanceId,
      'animalType': animalType.name,
      'purchasedAt': purchasedAt.toIso8601String(),
      'lastCollectedAt': lastCollectedAt.toIso8601String(),
      'quantity': quantity,
      'expiresAt': expiresAt.toIso8601String(),
      'purchaseMethod': purchaseMethod,
    };
  }

  factory UserAnimal.fromMap(Map<String, dynamic> data) {
    return UserAnimal(
      instanceId: data['instanceId'] ?? '',
      animalType: _parseAnimalType(data['animalType'] ?? 'chicken'),
      purchasedAt: DateTime.tryParse(data['purchasedAt'] ?? '') ?? DateTime.now(),
      lastCollectedAt: DateTime.tryParse(data['lastCollectedAt'] ?? '') ?? DateTime.now(),
      quantity: data['quantity'] ?? 1,
      expiresAt: DateTime.tryParse(data['expiresAt'] ?? '') ?? DateTime.now().add(Duration(days: 30)),
      purchaseMethod: data['purchaseMethod'] ?? 'points',
    );
  }

  static AnimalType _parseAnimalType(String type) {
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

  bool get isExpired {
    if (expiresAt.year > 2100) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  bool canCollect(int collectionIntervalHours) {
    final now = DateTime.now();
    final timeSinceLastCollection = now.difference(lastCollectedAt);
    return timeSinceLastCollection.inHours >= collectionIntervalHours;
  }

  int collectibleAmount(int dailyProfit, int collectionIntervalHours) {
    if (!canCollect(collectionIntervalHours)) return 0;
    final hoursSinceLast = DateTime.now().difference(lastCollectedAt).inHours;
    final collections = (hoursSinceLast / collectionIntervalHours).floor();
    return (dailyProfit * collectionIntervalHours / 24 * collections * quantity).ceil();
  }

  Duration timeUntilNextCollection(int collectionIntervalHours) {
    final nextCollection = lastCollectedAt.add(Duration(hours: collectionIntervalHours));
    final now = DateTime.now();
    if (now.isAfter(nextCollection)) return Duration.zero;
    return nextCollection.difference(now);
  }

  UserAnimal copyWith({
    DateTime? lastCollectedAt,
    int? quantity,
    DateTime? expiresAt,
  }) {
    return UserAnimal(
      instanceId: instanceId,
      animalType: animalType,
      purchasedAt: purchasedAt,
      lastCollectedAt: lastCollectedAt ?? this.lastCollectedAt,
      quantity: quantity ?? this.quantity,
      expiresAt: expiresAt ?? this.expiresAt,
      purchaseMethod: purchaseMethod,
    );
  }
}
