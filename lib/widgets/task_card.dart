import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String searchQuery;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    // Blocking logic
    final blocker = task.blockedByTask;
    final isBlocked = blocker != null && blocker.status != TaskStatus.done;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Opacity(
          opacity: isBlocked ? 0.4 : 1.0,
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Row(
                children: [
                  Expanded(
                    child: searchQuery.isEmpty 
                      ? Text(
                          task.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: _getHighlightedSpans(task.title, searchQuery),
                          ),
                        ),
                  ),
                  _StatusChip(status: task.status),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 14, color: Colors.indigo.shade300),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo.shade300,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (blocker != null) ...[
                        const SizedBox(width: 16),
                        Icon(isBlocked ? LucideIcons.lock : LucideIcons.unlock, 
                          size: 14, 
                          color: isBlocked ? Colors.red.shade300 : Colors.green.shade300
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isBlocked ? 'Blocked by: ${blocker.title}' : 'Unblocked',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isBlocked ? Colors.red.shade300 : Colors.green.shade300,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _getHighlightedSpans(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];

    final spans = <TextSpan>[];
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    int start = 0;
    while (true) {
      final index = textLower.indexOf(queryLower, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(backgroundColor: Color(0xFF6366F1), color: Colors.white),
      ));

      start = index + query.length;
    }
    return spans;
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case TaskStatus.toDo:
        color = Colors.blue.shade400;
        label = 'To-Do';
        break;
      case TaskStatus.inProgress:
        color = Colors.orange.shade400;
        label = 'In Progress';
        break;
      case TaskStatus.done:
        color = Colors.green.shade400;
        label = 'Done';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
