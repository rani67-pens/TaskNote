// File: lib/models/task.dart

class Task {
  final int? id;
  final String title;
  final String description;
  final String category;
  final DateTime deadline;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.category = 'Umum',
    required this.deadline,
    this.isCompleted = false,
    required this.createdAt,
  });

  // Fungsi copyWith untuk update data
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}