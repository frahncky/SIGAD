import React from 'react';
import { User, roleLabels } from '../types';

interface DashboardProps {
  user: User;
}

const Dashboard: React.FC<DashboardProps> = ({ user }) => {
  const getWelcomeMessage = () => {
    switch (user.role) {
      case 'professor':
        return 'Bem-vindo, Professor! Gerencie seus planos de ensino e atividades.';
      case 'coordenador':
        return 'Bem-vindo, Coordenador! Gerencie os cursos e aprove planos de ensino.';
      case 'servidor':
        return 'Bem-vindo, Servidor! Acesse documentos e configurações do sistema.';
      case 'chefe_departamento':
        return 'Bem-vindo, Chefe! Gerencie seu departamento e recursos.';
      default:
        return 'Bem-vindo ao SIGAD!';
    }
  };

  const getStats = () => {
    switch (user.role) {
      case 'professor':
        return [
          { label: 'Planos de Ensino', value: 4, icon: '📝' },
          { label: 'Atividades Pendentes', value: 3, icon: '⏳' },
          { label: 'Horas Semanais', value: 20, icon: '⏰' },
        ];
      case 'coordenador':
        return [
          { label: 'Planos para Aprovar', value: 12, icon: '📋' },
          { label: 'Professores', value: 25, icon: '👨‍🏫' },
          { label: 'Disciplinas', value: 45, icon: '📚' },
        ];
      case 'servidor':
        return [
          { label: 'Documentos', value: 150, icon: '📁' },
          { label: 'Processos', value: 8, icon: '📋' },
          { label: 'Configurações', value: 5, icon: '⚙️' },
        ];
      case 'chefe_departamento':
        return [
          { label: 'Professores', value: 45, icon: '👨‍🏫' },
          { label: 'Servidores', value: 12, icon: '👥' },
          { label: 'Orçamento', value: 'R$ 500k', icon: '💰' },
        ];
      default:
        return [];
    }
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>{getWelcomeMessage()}</h1>
        <p>Perfil: {roleLabels[user.role]}</p>
      </header>

      <section className="stats-grid">
        {getStats().map((stat, index) => (
          <div key={index} className="stat-card">
            <span className="stat-icon">{stat.icon}</span>
            <div className="stat-info">
              <span className="stat-value">{stat.value}</span>
              <span className="stat-label">{stat.label}</span>
            </div>
          </div>
        ))}
      </section>

    </div>
  );
};

export default Dashboard;
