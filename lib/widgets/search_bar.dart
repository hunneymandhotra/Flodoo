import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/task_provider.dart';

class FlodoSearchBar extends ConsumerWidget {
  const FlodoSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(taskFilterProvider.notifier).setSearchQuery(value);
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(LucideIcons.search, color: Colors.white.withOpacity(0.5), size: 20),
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
