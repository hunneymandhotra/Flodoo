import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class DatabaseService {
  late Box<Task> taskBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }

    taskBox = await Hive.openBox<Task>('tasks');
  }

  List<Task> getAllTasks() {
    return taskBox.values.toList();
  }

  Stream<List<Task>> watchAllTasks() async* {
    yield getAllTasks();
    yield* taskBox.watch().map((_) => getAllTasks());
  }

  Future<void> saveTask(Task task, {String? blockedById}) async {
    task.blockedById = blockedById;
    if (task.isInBox) {
      await task.save();
    } else {
      await taskBox.put(task.id, task);
    }
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  Future<void> updateTaskOrder(List<Task> tasks) async {
    for (int i = 0; i < tasks.length; i++) {
      tasks[i].sortOrder = i;
      await tasks[i].save();
    }
  }
}
