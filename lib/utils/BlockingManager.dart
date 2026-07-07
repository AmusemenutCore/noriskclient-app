import 'package:noriskclient/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the list of blocked users with an in-memory cache to avoid
/// repeated SharedPreferences reads when filtering post/chat lists.
///
/// The cache is scoped per user UUID: if the active user changes (sign-out /
/// sign-in) the cached data is automatically invalidated so no blocked-list
/// data leaks between accounts.
class BlockingManager {
  // Singleton so the in-memory cache is shared across all callers.
  static final BlockingManager _instance = BlockingManager._internal();
  factory BlockingManager() => _instance;
  BlockingManager._internal();

  Set<String>? _cache;
  // The UUID for which _cache was last loaded.
  String? _cachedForUuid;

  String get _currentUuid => getUserData['uuid'] as String? ?? '';
  String get _storeKey => 'blocked-$_currentUuid';

  Future<Set<String>> _getCache() async {
    final uuid = _currentUuid;
    // Invalidate cache if the active user changed (e.g. after sign-out/in).
    if (_cachedForUuid != uuid) {
      _cache = null;
      _cachedForUuid = uuid;
    }
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    _cache = (prefs.getStringList(_storeKey) ?? []).toSet();
    return _cache!;
  }

  /// Call this on sign-out to ensure the next user starts with a clean cache.
  void invalidate() {
    _cache = null;
    _cachedForUuid = null;
  }

  Future<bool> checkBlocked(String uuid) async {
    return (await _getCache()).contains(uuid);
  }

  Future<List<String>> getBlocked() async {
    return (await _getCache()).toList();
  }

  Future<void> block(String uuid) async {
    final blocked = await _getCache();
    if (blocked.contains(uuid)) return;
    blocked.add(uuid);
    await _persist(blocked);
  }

  Future<void> unblock(String uuid) async {
    final blocked = await _getCache();
    if (!blocked.contains(uuid)) return;
    blocked.remove(uuid);
    await _persist(blocked);
  }

  Future<void> _persist(Set<String> blocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storeKey, blocked.toList());
  }
}
