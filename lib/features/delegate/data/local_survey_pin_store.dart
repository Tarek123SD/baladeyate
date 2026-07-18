import 'dart:convert';

import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';

class LocalSurveyPinStore {
  LocalSurveyPinStore({required CacheService cacheService})
      : _cacheService = cacheService;

  final CacheService _cacheService;

  /// Loads all locally stored survey pins (any status).
  Future<List<SurveyPin>> loadDraftPins() async {
    final raw = _cacheService.getData(key: StorageKeys.delegateDraftPins);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map((item) => SurveyPin.fromJson(Map<String, dynamic>.from(item)))
          .where((pin) => pin.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists [pin] while preserving its status (in progress / completed / assigned).
  Future<void> saveDraftPin(SurveyPin pin) async {
    final pins = await loadDraftPins();
    final updated = [
      ...pins.where((item) => item.id != pin.id),
      pin,
    ];

    await _cacheService.saveData(
      key: StorageKeys.delegateDraftPins,
      value: jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> removeDraftPin(String pinId) async {
    final pins = await loadDraftPins();
    final updated = pins.where((item) => item.id != pinId).toList();

    if (updated.isEmpty) {
      await _cacheService.removeData(key: StorageKeys.delegateDraftPins);
      return;
    }

    await _cacheService.saveData(
      key: StorageKeys.delegateDraftPins,
      value: jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }
}
