import React from 'react';
import { Home, Heart, Bell, User } from 'lucide-react';
import { NavTab } from '../types';

interface BottomNavProps {
  activeTab: NavTab;
  onTabChange: (tab: NavTab) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeTab, onTabChange }) => {
  const navItems = [
    { id: NavTab.Home, icon: Home, label: 'Home' },
    { id: NavTab.Favourites, icon: Heart, label: 'Saved' },
    { id: NavTab.Notifications, icon: Bell, label: 'Alerts' },
    { id: NavTab.Settings, icon: User, label: 'Profile' },
  ];

  return (
    <div className="fixed bottom-6 left-6 right-6 z-40">
      <div className="bg-white/80 backdrop-blur-xl rounded-full shadow-[0_8px_30px_rgb(0,0,0,0.12)] border border-white/50 px-6 py-4 flex justify-between items-center max-w-md mx-auto">
        {navItems.map((item) => {
          const isActive = activeTab === item.id;
          return (
            <button 
              key={item.id}
              onClick={() => onTabChange(item.id)}
              className="group relative flex items-center justify-center w-12 h-12"
            >
              {isActive && (
                <span className="absolute inset-0 bg-green-100 rounded-full scale-100 transition-transform duration-300 -z-10" />
              )}
              <item.icon 
                className={`w-6 h-6 transition-all duration-300 ${isActive ? 'text-primary fill-primary scale-110' : 'text-gray-400 group-hover:text-gray-600'}`} 
                strokeWidth={isActive ? 0 : 2.5}
              />
            </button>
          );
        })}
      </div>
    </div>
  );
};