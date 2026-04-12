import React, { useState } from 'react';
import { User, UserRole, roleLabels } from '../types';

interface LoginProps {
  onLogin: (user: User) => void;
}

const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [selectedRole, setSelectedRole] = useState<UserRole | null>(null);

  const handleLogin = () => {
    if (!selectedRole) return;

    const mockUsers: Record<UserRole, User> = {
      professor: {
        id: '1',
        name: 'João Silva',
        email: 'joao.silva@universidade.edu.br',
        role: 'professor',
        department: 'Computação',
        course: 'Ciência da Computação',
      },
      coordenador: {
        id: '2',
        name: 'Maria Santos',
        email: 'maria.santos@universidade.edu.br',
        role: 'coordenador',
        department: 'Computação',
        course: 'Ciência da Computação',
      },
      servidor: {
        id: '3',
        name: 'Pedro Oliveira',
        email: 'pedro.oliveira@universidade.edu.br',
        role: 'servidor',
        department: 'Secretaria',
      },
      chefe_departamento: {
        id: '4',
        name: 'Ana Costa',
        email: 'ana.costa@universidade.edu.br',
        role: 'chefe_departamento',
        department: 'Computação',
      },
    };

    onLogin(mockUsers[selectedRole]);
  };

  const roles: UserRole[] = ['professor', 'coordenador', 'servidor', 'chefe_departamento'];

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>SIGAD</h1>
        <p className="subtitle">Sistema de Gestão de Atividades Docentes</p>

        <h2>Selecione seu perfil</h2>

        <div className="role-selection">
          {roles.map((role) => (
            <button
              key={role}
              className={`role-button ${selectedRole === role ? 'selected' : ''}`}
              onClick={() => setSelectedRole(role)}
            >
              <span className="role-icon">
                {role === 'professor' && '👨‍🏫'}
                {role === 'coordenador' && '🎓'}
                {role === 'servidor' && '👔'}
                {role === 'chefe_departamento' && '🏢'}
              </span>
              <span className="role-name">{roleLabels[role]}</span>
            </button>
          ))}
        </div>

        <button
          className="login-button"
          onClick={handleLogin}
          disabled={!selectedRole}
        >
          Entrar
        </button>
      </div>
    </div>
  );
};

export default Login;
