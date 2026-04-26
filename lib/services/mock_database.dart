import '../models/task.dart';

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  final List<Task> _tasks = [
    Task(
      id: 1,
      title: 'Belajar Flutter',
      description: 'Membuat aplikasi TaskNote dengan notifikasi',
      // ✅ SUDAH DI-UPDATE
      category: 'Tugas Kuliah',
      deadline: DateTime.now().add(const Duration(days: 2)),
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    Task(
      id: 2,
      title: 'Belanja Bulanan',
      description: 'Beli kebutuhan pokok',
      category: 'Belanja',
      deadline: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
  ];

  int _nextId = 3;

  Task createTask(Task task) {
    final newTask = task.copyWith(id: _nextId++);
    _tasks.add(newTask);
    return newTask;
  }

  List<Task> getTasks() {
    return List.from(_tasks);
  }

  bool updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      return true;
    }
    return false;
  }

  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
  }
}