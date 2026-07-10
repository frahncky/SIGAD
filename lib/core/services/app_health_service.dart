class AppHealthSnapshot {
  const AppHealthSnapshot({
    required this.totalActions,
    required this.totalErrors,
    required this.errorsByFeature,
    required this.eventsByFlow,
  });

  final int totalActions;
  final int totalErrors;
  final Map<String, int> errorsByFeature;
  final Map<String, int> eventsByFlow;
}

abstract final class AppHealthService {
  static int _totalActions = 0;
  static int _totalErrors = 0;
  static final Map<String, int> _errorsByFeature = <String, int>{};
  static final Map<String, int> _eventsByFlow = <String, int>{};

  static void registerAction(String eventName) {
    _totalActions += 1;
    _eventsByFlow.update(eventName, (count) => count + 1, ifAbsent: () => 1);
  }

  static void registerError(String eventName) {
    _totalErrors += 1;
    final feature = _extractFeature(eventName);
    _errorsByFeature.update(feature, (count) => count + 1, ifAbsent: () => 1);
    _eventsByFlow.update(eventName, (count) => count + 1, ifAbsent: () => 1);
  }

  static AppHealthSnapshot snapshot() {
    return AppHealthSnapshot(
      totalActions: _totalActions,
      totalErrors: _totalErrors,
      errorsByFeature: Map<String, int>.from(_errorsByFeature),
      eventsByFlow: Map<String, int>.from(_eventsByFlow),
    );
  }

  static String _extractFeature(String eventName) {
    final normalized = eventName.trim();
    if (normalized.isEmpty) return 'unknown';

    final withoutOperationId = normalized.split(':').first;
    final feature = withoutOperationId.split('_').first;
    return feature.isEmpty ? 'unknown' : feature;
  }
}
