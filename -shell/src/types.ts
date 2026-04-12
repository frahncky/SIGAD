// Tipos de usuário do sistema
export type UserRole =
  | 'professor'
  | 'coordenador'
  | 'servidor'
  | 'chefe_departamento';

// Interface base de usuário
export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  department?: string;
  course?: string;
}

// Permissões por perfil
export const rolePermissions: Record<UserRole, string[]> = {
  professor: [
    'visualizar_plano_ensino',
    'editar_plano_ensino',
    'registrar_atividade',
    'visualizar_relatorios_pessoais',
  ],
  coordenador: [
    'visualizar_plano_ensino',
    'aprovar_plano_ensino',
    'gerenciar_cursos',
    'visualizar_relatorios_curso',
    'gerenciar_professores',
  ],
  servidor: [
    'visualizar_documentos',
    'gerenciar_documentos',
    'visualizar_relatorios',
    'configurar_sistema',
  ],
  chefe_departamento: [
    'visualizar_plano_ensino',
    'aprovar_plano_ensino',
    'gerenciar_departamento',
    'visualizar_relatorios_departamento',
    'gerenciar_orcamento',
    'gerenciar_professores',
    'gerenciar_servidores',
  ],
};

// Rótulos amigáveis para os perfis
export const roleLabels: Record<UserRole, string> = {
  professor: 'Professor',
  coordenador: 'Coordenador do Curso',
  servidor: 'Servidor Administrativo',
  chefe_departamento: 'Chefe do Departamento',
};
