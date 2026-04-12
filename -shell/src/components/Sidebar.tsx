import React from 'react';
import { User, roleLabels } from '../types';

interface SidebarProps {
  user: User;
}

const Sidebar: React.FC<SidebarProps> = ({ user }) => {
  const getMenuItems = () => {
    const items: { label: string; path: string; icon: string }[] = [
      { label: 'Dashboard', path: '/dashboard', icon: '📊' },
    ];

    switch (user.role) {
      case 'professor':
        items.push(
          { label: 'Meus Planos de Ensino', path: '/planos-ensino', icon: '📝' },
          { label: 'Minhas Atividades', path: '/atividades', icon: '📋' },
          { label: 'Relatórios', path: '/relatorios', icon: '📈' },
        );
        break;
      case 'coordenador':
        items.push(
          { label: 'Planos de Ensino', path: '/planos-ensino', icon: '📝' },
          { label: 'Aprovações', path: '/aprovacoes', icon: '✅' },
          { label: 'Gerenciar Curso', path: '/gerenciar-curso', icon: '🎓' },
          { label: 'Professores', path: '/professores', icon: '👨‍🏫' },
          { label: 'Relatórios do Curso', path: '/relatorios', icon: '📈' },
        );
        break;
      case 'servidor':
        items.push(
          { label: 'Documentos', path: '/documentos', icon: '📁' },
          { label: 'Relatórios', path: '/relatorios', icon: '📈' },
          { label: 'Configurações', path: '/configuracoes', icon: '⚙️' },
        );
        break;
      case 'chefe_departamento':
        items.push(
          { label: 'Planos de Ensino', path: '/planos-ensino', icon: '📝' },
          { label: 'Aprovações', path: '/aprovacoes', icon: '✅' },
          { label: 'Departamento', path: '/departamento', icon: '🏢' },
          { label: 'Professores', path: '/professores', icon: '👨‍🏫' },
          { label: 'Servidores', path: '/servidores', icon: '👥' },
          { label: 'Orçamento', path: '/orcamento', icon: '💰' },
          { label: 'Relatórios', path: '/relatorios', icon: '📈' },
        );
        break;
    }

    return items;
  };

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <h2>SIGAD</h2>
        <p className="user-role">{roleLabels[user.role]}</p>
      </div>

      <nav className="sidebar-nav">
        <ul>
          {getMenuItems().map((item, index) => (
            <li key={index}>
              <a href={item.path}>
                <span className="icon">{item.icon}</span>
                {item.label}
              </a>
            </li>
          ))}
        </ul>
      </nav>

      <div className="sidebar-footer">
        <div className="user-info">
          <span className="user-name">{user.name}</span>
          <span className="user-email">{user.email}</span>
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
