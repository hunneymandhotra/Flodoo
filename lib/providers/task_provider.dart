import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final taskListProvider = StreamProvider<List<Task>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.watchAllTasks().map((tasks) {
    tasks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return tasks;
  });
});

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final allTasksAsync = ref.watch(taskListProvider);
  final filters = ref.watch(taskFilterProvider);

  return allTasksAsync.whenData((tasks) {
    return tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(filters.searchQuery.toLowerCase());
      final matchesStatus = filters.statusFilter == null || task.status == filters.statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  });
});

class TaskFilters {
  final String searchQuery;
  final TaskStatus? statusFilter;

  TaskFilters({this.searchQuery = '', this.statusFilter});

  TaskFilters copyWith({String? searchQuery, TaskStatus? statusFilter}) {
    return TaskFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

final taskFilterProvider = StateNotifierProvider<TaskFilterNotifier, TaskFilters>((ref) {
  return TaskFilterNotifier();
});

class TaskFilterNotifier extends StateNotifier<TaskFilters> {
  TaskFilterNotifier() : super(TaskFilters());
  Timer? _debounce;

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(searchQuery: query);
    });
  }

  void setStatusFilter(TaskStatus? status) {
    state = state.copyWith(statusFilter: status);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
