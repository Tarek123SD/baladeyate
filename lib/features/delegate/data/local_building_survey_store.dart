import 'dart:convert';

import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';

class LocalBuildingSurveyStore {
  LocalBuildingSurveyStore({required CacheService cacheService})
      : _cacheService = cacheService;

  final CacheService _cacheService;

  Future<BuildingSurvey?> loadSurvey(String pinId) async {
    final all = await _loadAll();
    return all[pinId];
  }

  Future<void> saveSurvey(BuildingSurvey survey) async {
    final all = await _loadAll();
    all[survey.pinId] = survey;
    await _persist(all);
  }

  Future<void> removeSurvey(String pinId) async {
    final all = await _loadAll();
    all.remove(pinId);
    await _persist(all);
  }

  Future<Map<String, BuildingSurvey>> _loadAll() async {
    final raw = _cacheService.getData(key: StorageKeys.delegateBuildingSurveys);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};

      return decoded.map(
        (key, value) => MapEntry(
          key,
          BuildingSurvey.fromJson(
            value is Map<String, dynamic> ? value : <String, dynamic>{},
          ),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _persist(Map<String, BuildingSurvey> surveys) async {
    final encoded = jsonEncode(
      surveys.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _cacheService.saveData(
      key: StorageKeys.delegateBuildingSurveys,
      value: encoded,
    );
  }
}

String newLocalId(String prefix) =>
    '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
