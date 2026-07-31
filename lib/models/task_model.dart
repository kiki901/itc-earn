enum TaskType { download, survey, ad, social, visit }

class TaskModel {
  final String id;
  final TaskType type;
  final String title;
  final String description;
  final int reward;
  final String? url;
  final String icon;
  final bool active;
  final List<String> completedBy;
  final int maxCompletions;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.reward,
    this.url,
    required this.icon,
    this.active = true,
    this.completedBy = const [],
    this.maxCompletions = 1000,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'reward': reward,
      'url': url,
      'icon': icon,
      'active': active,
      'completedBy': completedBy,
      'maxCompletions': maxCompletions,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> data) {
    return TaskModel(
      id: data['id'] ?? '',
      type: _parseTaskType(data['type'] ?? 'download'),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      reward: data['reward'] ?? 0,
      url: data['url'],
      icon: data['icon'] ?? 'task',
      active: data['active'] ?? true,
      completedBy: List<String>.from(data['completedBy'] ?? []),
      maxCompletions: data['maxCompletions'] ?? 1000,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool isCompletedBy(String userId) => completedBy.contains(userId);

  bool get isFull => completedBy.length >= maxCompletions;

  static TaskType _parseTaskType(String type) {
    switch (type) {
      case 'download':
        return TaskType.download;
      case 'survey':
        return TaskType.survey;
      case 'ad':
        return TaskType.ad;
      case 'social':
        return TaskType.social;
      case 'visit':
        return TaskType.visit;
      default:
        return TaskType.download;
    }
  }

  String get typeName {
    switch (type) {
      case TaskType.download:
        return 'تحميل';
      case TaskType.survey:
        return 'استطلاع';
      case TaskType.ad:
        return 'إعلان';
      case TaskType.social:
        return 'اجتماعي';
      case TaskType.visit:
        return 'زيارة';
    }
  }

  String get emoji {
    switch (type) {
      case TaskType.download:
        return '📱';
      case TaskType.survey:
        return '📝';
      case TaskType.ad:
        return '📺';
      case TaskType.social:
        return '👥';
      case TaskType.visit:
        return '🌐';
    }
  }
}
