abstract final class EventPayloadSanitizer {
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'cookie',
    'email',
    'pass',
    'password',
    'professor',
    'session',
    'sessiontoken',
    'token',
    'userid',
  };

  static Map<String, Object?> sanitizeDetails(Map<String, Object?> details) {
    if (details.isEmpty) return const {};

    final sanitized = <String, Object?>{};
    for (final entry in details.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      sanitized[key] = _sanitizeEntry(key, entry.value);
    }
    return sanitized;
  }

  static Object? _sanitizeEntry(String key, Object? value) {
    if (value == null) return null;

    final normalizedKey = key.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (_sensitiveKeys.any(normalizedKey.contains)) {
      return _redacted(value);
    }

    if (value is String) {
      final trimmed = value.trim();
      if (_looksLikeEmail(trimmed) || _looksLikeToken(trimmed)) {
        return _redacted(trimmed);
      }
      if (trimmed.length > 200) {
        return '${trimmed.substring(0, 200)}...';
      }
      return trimmed;
    }

    return value;
  }

  static bool _looksLikeEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  static bool _looksLikeToken(String value) {
    if (value.toLowerCase().startsWith('bearer ')) return true;
    return value.length >= 20 && RegExp(r'^[A-Za-z0-9\-_\.]+$').hasMatch(value);
  }

  static String _redacted(Object value) {
    final raw = value.toString();
    final suffix = raw.length <= 4 ? raw : raw.substring(raw.length - 4);
    return '***$suffix';
  }
}
