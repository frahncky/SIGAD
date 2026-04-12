import React, { useState } from 'react';
import { User } from './types';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Sidebar from './components/Sidebar';
import './App.css';

const App: React.FC = () => {
  const [user, setUser] = useState<User | null>(null);

  const handleLogin = (loggedUser: User) => {
    setUser(loggedUser);
  };

  const handleLogout = () => {
    setUser(null);
  };

  if (!user) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <div className="app-layout">
      <Sidebar user={user} />
      <main className="main-content">
        <header className="top-bar">
          <h1>SIGAD - Sistema de Gestão de Atividades Docentes</h1>
          <button className="logout-button" onClick={handleLogout}>
            Sair
          </button>
        </header>
        <div className="page-content">
          <Dashboard user={user} />
        </div>
      </main>
    </div>
  );
};

export default App;
