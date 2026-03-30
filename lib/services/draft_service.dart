import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static const _draftKey = 'task_draft';

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(draft));
  }

  Future<Map<String, dynamic>?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString(_draftKey);
    if (draftJson != null && draftJson.isNotEmpty) {
      return jsonDecode(draftJson) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
