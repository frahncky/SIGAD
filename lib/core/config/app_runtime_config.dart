enum DataSourceMode { local, remote }

abstract final class AppRuntimeConfig {
  static const String flavor = String.fromEnvironment(
    'SIGAD_FLAVOR',
    defaultValue: 'dev',
  );

  static const String _dataSourceValue = String.fromEnvironment(
    'SIGAD_DATA_SOURCE',
    defaultValue: 'local',
  );

  static const bool enableObservability = bool.fromEnvironment(
    'SIGAD_OBSERVABILITY_ENABLED',
    defaultValue: false,
  );

  static const String observabilityEndpoint = String.fromEnvironment(
    'SIGAD_OBSERVABILITY_ENDPOINT',
    defaultValue: '',
  );

  static const bool verboseLogs = bool.fromEnvironment(
    'SIGAD_VERBOSE_LOGS',
    defaultValue: false,
  );

  static const bool enableRemoteFallback = bool.fromEnvironment(
    'SIGAD_ENABLE_REMOTE_FALLBACK',
    defaultValue: true,
  );

  static final DataSourceMode dataSourceMode = _resolveDataSourceMode(_dataSourceValue);

  static DataSourceMode _resolveDataSourceMode(String value) {
    switch (value.toLowerCase()) {
      case 'remote':
        return DataSourceMode.remote;
      case 'local':
      default:
        return DataSourceMode.local;
    }
  }
}
