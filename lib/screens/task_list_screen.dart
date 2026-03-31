import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/search_bar.dart';
import 'task_form_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onTaskDone() {
    HapticFeedback.heavyImpact();
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasksAsync = ref.watch(filteredTasksProvider);
    final allTasksAsync = ref.watch(taskListProvider);
    final filterStatus = ref.watch(taskFilterProvider).statusFilter;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _Header(
                  currentStatus: filterStatus,
                  onStatusChanged: (status) {
                    ref.read(taskFilterProvider.notifier).setStatusFilter(status);
                  },
                ),
    
                // Project progress summary widget
                allTasksAsync.when(
                  data: (tasks) => _ProgressHeader(tasks: tasks).animate().fadeIn().scale(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                
                // Task List
                Expanded(
                  child: filteredTasksAsync.when(
                    data: (tasks) {
                      final searchQuery = ref.watch(taskFilterProvider).searchQuery;
                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.clipboardList, size: 80, color: Colors.indigo.shade600.withOpacity(0.2)),
                              const SizedBox(height: 24),
                              Text(
                                'Your task list is empty',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to get started',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn();
                      }
    
                      // Main task list supporting drag-and-drop reordering
                      return ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: tasks.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final items = [...tasks];
                          final movedItem = items.removeAt(oldIndex);
                          items.insert(newIndex, movedItem);
                          // Save persisted order
                          ref.read(databaseServiceProvider).updateTaskOrder(items);
                        },
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Hero(
                            key: ValueKey(task.id),
                            tag: 'task-${task.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: TaskCard(
                                task: task,
                                searchQuery: searchQuery,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 600),
                                      pageBuilder: (context, animation, secondaryAnimation) => TaskFormScreen(task: task),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(opacity: animation, child: child);
                                      },
                                    ),
                                  ).then((_) {
                                    // Check if task status recently changed to done
                                    if (task.status == TaskStatus.done) {
                                        _onTaskDone();
                                    }
                                  });
                                },
                                onDelete: () {
                                  ref.read(databaseServiceProvider).deleteTask(task.id);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => _TaskShimmer(),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti overlay
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskFormScreen(),
            ),
          );
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _TaskShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.05),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final List<Task> tasks;
  const _ProgressHeader({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final total = tasks.length;
    final progress = total == 0 ? 0.0 : done / total;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: Colors.indigo.shade600,
                  strokeWidth: 4,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project Progress', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$done of $total tasks completed', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TaskStatus? currentStatus;
  final ValueChanged<TaskStatus?> onStatusChanged;

  const _Header({required this.currentStatus, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workspaces',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              CircleAvatar(
                backgroundColor: Colors.indigo.shade600.withOpacity(0.2),
                child: Icon(LucideIcons.user, color: Colors.indigo.shade100, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FlodoSearchBar(),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: currentStatus == null,
                  onSelected: () => onStatusChanged(null),
                ),
                _FilterChip(
                  label: 'To-Do',
                  isSelected: currentStatus == TaskStatus.toDo,
                  onSelected: () => onStatusChanged(TaskStatus.toDo),
                ),
                _FilterChip(
                  label: 'In Progress',
                  isSelected: currentStatus == TaskStatus.inProgress,
                  onSelected: () => onStatusChanged(TaskStatus.inProgress),
                ),
                _FilterChip(
                  label: 'Done',
                  isSelected: currentStatus == TaskStatus.done,
                  onSelected: () => onStatusChanged(TaskStatus.done),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? Colors.indigo.shade600 : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
