import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskStatus { 
  @HiveField(0) toDo, 
  @HiveField(1) inProgress, 
  @HiveField(2) done 
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late DateTime dueDate;

  @HiveField(4)
  late TaskStatus status;

  @HiveField(5)
  String? blockedById;

  @HiveField(6)
  late int sortOrder;

  // Added getter to mimic IsarLink behavior for current UI
  Task? get blockedByTask {
    if (blockedById == null) return null;
    try {
      final box = Hive.box<Task>('tasks');
      return box.get(blockedById);
    } catch (e) {
      return null;
    }
  }
}
