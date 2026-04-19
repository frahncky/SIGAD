abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'SIGAD_API_BASE_URL',
    defaultValue: 'https://api.sigad.local',
  );

  static const String atividadesPath = '/atividades';
  static const String demandasPath = '/demandas';
  static const String kanbanPath = '/kanban/cards';
  static const String relatoriosPath = '/relatorios';
}
