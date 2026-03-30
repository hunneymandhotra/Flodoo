import 'package:flutter_test/flutter_test.dart';
import 'package:flodo/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task should be able to store values accurately', () {
      final now = DateTime.now();
      final task = Task()
        ..id = 'task-uuid-123'
        ..title = 'Finish Assignment'
        ..description = 'Complete the Flodo Flutter hiring task.'
        ..dueDate = now
        ..status = TaskStatus.inProgress
        ..sortOrder = 0;

      expect(task.id, 'task-uuid-123');
      expect(task.title, 'Finish Assignment');
      expect(task.description, 'Complete the Flodo Flutter hiring task.');
      expect(task.dueDate, now);
      expect(task.status, TaskStatus.inProgress);
      expect(task.sortOrder, 0);
    });

    test('TaskStatus enum should have correct number of states', () {
      expect(TaskStatus.values.length, 3);
      expect(TaskStatus.values, [TaskStatus.toDo, TaskStatus.inProgress, TaskStatus.done]);
    });
  });
}
