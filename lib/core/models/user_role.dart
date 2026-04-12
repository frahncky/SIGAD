enum UserRole {
  professor('Professor', 'PR'),
  coordenador('Coordenador de Curso', 'CC'),
  servidorAdministrativo('Servidor Administrativo', 'SA'),
  chefeDepartamento('Chefe do Departamento', 'CD');

  const UserRole(this.displayName, this.abbreviation);

  final String displayName;
  final String abbreviation;
}
