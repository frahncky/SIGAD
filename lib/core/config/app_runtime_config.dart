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

  static const bool _demoAccessRequested = bool.fromEnvironment(
    'SIGAD_ENABLE_DEMO_ACCESS',
    defaultValue: true,
  );

  /// O acesso local existe somente para desenvolvimento e homologação.
  /// Produção deve falhar fechada até que a autenticação institucional esteja
  /// configurada.
  static bool get enableDemoAccess => resolveDemoAccess(
    flavor: flavor,
    demoAccessRequested: _demoAccessRequested,
  );

  static bool resolveDemoAccess({
    required String flavor,
    required bool demoAccessRequested,
  }) {
    if (!demoAccessRequested) return false;

    switch (flavor.trim().toLowerCase()) {
      case 'dev':
      case 'test':
      case 'staging':
        return true;
      default:
        return false;
    }
  }

  static const bool enableRemoteFallback = bool.fromEnvironment(
    'SIGAD_ENABLE_REMOTE_FALLBACK',
    defaultValue: true,
  );

  static final DataSourceMode dataSourceMode = _resolveDataSourceMode(
    _dataSourceValue,
  );

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
