import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/draft_service.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskStatus _status;
  String? _blockedById;
  
  bool _isLoading = false;
  final _draftService = DraftService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _status = widget.task?.status ?? TaskStatus.toDo;
    _blockedById = widget.task?.blockedById;

    if (widget.task == null) {
      _loadDraft();
    }
  }

  void _loadDraft() async {
    final draft = await _draftService.getDraft();
    if (draft != null) {
      setState(() {
        _titleController.text = draft['title'] ?? '';
        _descriptionController.text = draft['description'] ?? '';
      });
    }
  }

  void _saveDraft() {
    if (widget.task == null) {
      _draftService.saveDraft({
        'title': _titleController.text,
        'description': _descriptionController.text,
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Added artificial delay to fulfill the assignment requirement for loading states
    await Future.delayed(const Duration(seconds: 2));

    final allTasks = ref.read(taskListProvider).value ?? [];
    final task = widget.task ?? Task()
      ..id = widget.task?.id ?? const Uuid().v4()
      ..sortOrder = widget.task?.sortOrder ?? allTasks.length;
    
    task.title = _titleController.text;
    task.description = _descriptionController.text;
    task.dueDate = _dueDate;
    task.status = _status;

    await ref.read(databaseServiceProvider).saveTask(task, blockedById: _blockedById);

    // Clear draft on success
    if (widget.task == null) {
      await _draftService.clearDraft();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.task == null ? 'Task created successfully' : 'Task updated successfully'),
          backgroundColor: Colors.indigo.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskListProvider).value ?? [];
    // Filter out current task from blocked options
    final potentialBlockers = allTasks.where((t) => t.id != widget.task?.id).toList();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveDraft();
      },
      child: Hero(
        tag: widget.task != null ? 'task-${widget.task!.id}' : 'new-task',
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () {
                _saveDraft();
                Navigator.pop(context);
              },
            ),
          ),
          body: Stack(
            children: [
              Form(
                key: _formKey,
                onChanged: _saveDraft,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildFieldLabel('Title'),
                    TextFormField(
                      controller: _titleController,
                      validator: (v) => v!.isEmpty ? 'Title is required' : null,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(hintText: 'Enter task title'),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildFieldLabel('Description'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Enter task description'),
                    ),
                    const SizedBox(height: 24),
    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Due Date'),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setState(() => _dueDate = picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.calendar, size: 16, color: Colors.indigo.shade300),
                                      const SizedBox(width: 10),
                                      Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Status'),
                              SegmentedButton<TaskStatus>(
                                showSelectedIcon: false,
                                style: SegmentedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white.withOpacity(0.5),
                                  selectedForegroundColor: Colors.white,
                                  selectedBackgroundColor: Colors.indigo.shade600,
                                  side: BorderSide(color: Colors.white.withOpacity(0.05)),
                                ),
                                segments: const [
                                  ButtonSegment(value: TaskStatus.toDo, label: Text('TO-DO', style: TextStyle(fontSize: 10))),
                                  ButtonSegment(value: TaskStatus.inProgress, label: Text('WIP', style: TextStyle(fontSize: 10))),
                                  ButtonSegment(value: TaskStatus.done, label: Text('DONE', style: TextStyle(fontSize: 10))),
                                ],
                                selected: {_status},
                                onSelectionChanged: (v) => setState(() => _status = v.first),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
    
                    _buildFieldLabel('Blocked By (Optional)'),
                    DropdownButtonFormField<String?>(
                      value: _blockedById,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...potentialBlockers.map((t) {
                          return DropdownMenuItem(value: t.id, child: Text(t.title));
                        }),
                      ],
                      onChanged: (v) => setState(() => _blockedById = v),
                    ),
                    
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          ) 
                        : const Text('Save Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const ModalBarrier(dismissible: false, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
