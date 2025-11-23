import React, { useState, useEffect } from 'react';
import { ShoppingBag, Pizza, Salad, Utensils, Coffee } from 'lucide-react';
import { MapHeader } from './components/MapHeader';
import { DishCard } from './components/DishCard';
import { CartSheet } from './components/CartSheet';
import { DishDetailModal } from './components/DishDetailModal';
import { fetchDishes } from './services/geminiService';
import { Dish, CartItem } from './types';

function App() {
  const [dishes, setDishes] = useState<Dish[]>([]);
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [selectedDish, setSelectedDish] = useState<Dish | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('All');
  const [greeting, setGreeting] = useState('Hello');

  // Initial Load
  useEffect(() => {
    loadDishes();
    
    const hour = new Date().getHours();
    if (hour < 12) setGreeting("Good Morning");
    else if (hour < 18) setGreeting("Good Afternoon");
    else setGreeting("Good Evening");
  }, []);

  const loadDishes = async (query?: string) => {
    setLoading(true);
    const result = await fetchDishes(query);
    setDishes(result);
    setLoading(false);
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    loadDishes(query);
  };

  const addToCart = (dish: Dish) => {
    setCartItems(prev => {
      const existing = prev.find(item => item.dish.id === dish.id);
      if (existing) {
        return prev.map(item => 
          item.dish.id === dish.id 
            ? { ...item, quantity: item.quantity + 1 } 
            : item
        );
      }
      return [...prev, { dish, quantity: 1 }];
    });
    // Optional: Open cart immediately or just show the FAB update
    // setIsCartOpen(true); 
  };

  const updateQuantity = (id: string, delta: number) => {
    setCartItems(prev => prev.map(item => {
      if (item.dish.id === id) {
        const newQty = item.quantity + delta;
        return newQty > 0 ? { ...item, quantity: newQty } : null;
      }
      return item;
    }).filter(Boolean) as CartItem[]);
  };

  const totalItems = cartItems.reduce((acc, item) => acc + item.quantity, 0);
  const cartTotal = cartItems.reduce((acc, item) => acc + (item.dish.price * item.quantity), 0);

  const categories = [
    { name: 'All', icon: Utensils },
    { name: 'Sushi', icon: Utensils },
    { name: 'Burger', icon: Utensils },
    { name: 'Pizza', icon: Pizza },
    { name: 'Healthy', icon: Salad },
    { name: 'Dessert', icon: Coffee },
  ];

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col relative font-sans selection:bg-green-100">
      
      {/* 1. Map Header Section (Fixed at top) */}
      <div className="fixed top-0 left-0 right-0 z-0 h-[50vh]">
        <MapHeader onSearch={handleSearch} />
      </div>

      {/* 2. Main Content Area (Scrollable Sheet) */}
      <div className="relative z-10 mt-[42vh] bg-gray-50 rounded-t-3xl min-h-[60vh] pb-24 shadow-[0_-10px_40px_-15px_rgba(0,0,0,0.2)]">
        
        {/* Pull Indicator */}
        <div className="w-full flex justify-center pt-3 pb-1">
          <div className="w-10 h-1 bg-gray-300 rounded-full opacity-60"></div>
        </div>

        <div className="px-6 pt-4">
           {/* Personalized Header */}
           <div className="mb-6 flex items-center gap-4">
              <div className="relative flex-shrink-0">
                  <div className="w-12 h-12 rounded-full p-1 bg-white shadow-sm border border-gray-100">
                    <img 
                      src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&h=200&fit=crop" 
                      alt="Profile" 
                      className="w-full h-full rounded-full object-cover"
                    />
                  </div>
                  <div className="absolute bottom-1 right-1 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></div>
              </div>
              <div>
                 <h1 className="text-2xl font-bold text-gray-900 tracking-tight leading-tight">{greeting}, Alex</h1>
                 <p className="text-gray-500 text-xs font-medium mt-1">Ready to discover your next favorite meal?</p>
              </div>
           </div>

          {/* Categories Horizontal Scroll */}
          <div className="flex space-x-3 overflow-x-auto no-scrollbar pb-6 -mx-6 px-6">
            {categories.map((cat) => (
              <button 
                key={cat.name}
                onClick={() => {
                  setSelectedCategory(cat.name);
                  if (cat.name === 'All') loadDishes();
                  else loadDishes(cat.name.toLowerCase());
                }}
                className={`flex items-center px-5 py-2.5 rounded-xl whitespace-nowrap transition-all duration-300 border ${
                  selectedCategory === cat.name 
                  ? 'bg-gray-900 text-white border-gray-900 shadow-lg shadow-gray-200 scale-105' 
                  : 'bg-white text-gray-600 border-gray-100 hover:border-gray-300 hover:bg-gray-50'
                }`}
              >
                <span className="text-xs font-semibold">{cat.name}</span>
              </button>
            ))}
          </div>

          {/* Section Title */}
          <div className="flex justify-between items-end mb-4">
            <h2 className="text-lg font-bold text-gray-900">
              {searchQuery ? 'Search Results' : 'Recommended for you'}
            </h2>
            {!loading && (
              <button className="text-[10px] font-bold text-primary uppercase tracking-wider hover:text-primaryDark transition-colors bg-green-50 px-2.5 py-1 rounded-lg">See All</button>
            )}
          </div>

          {/* Grid of Dishes */}
          {loading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3, 4].map((n) => (
                <div key={n} className="bg-white rounded-2xl h-72 animate-pulse border border-gray-100 p-4 space-y-3 shadow-sm">
                  <div className="w-full h-40 bg-gray-100 rounded-xl"></div>
                  <div className="h-3 bg-gray-100 rounded-full w-3/4"></div>
                  <div className="h-2 bg-gray-100 rounded-full w-1/2"></div>
                </div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {dishes.map((dish) => (
                <DishCard 
                  key={dish.id} 
                  dish={dish} 
                  onAddToCart={addToCart} 
                  onClick={setSelectedDish}
                />
              ))}
            </div>
          )}
        </div>
      </div>

      {/* 3. Smart FAB Cart */}
      <div className="fixed bottom-6 right-6 z-50">
          <button 
            onClick={() => setIsCartOpen(true)}
            className={`group relative flex items-center justify-center bg-gray-900 text-white shadow-[0_8px_30px_rgba(0,0,0,0.3)] hover:shadow-[0_20px_40px_rgba(0,0,0,0.4)] transition-all duration-300 active:scale-95 border-4 border-white/10 backdrop-blur-sm ${
                totalItems > 0 ? 'rounded-2xl px-5 py-3 pr-6 space-x-3 h-16' : 'rounded-2xl w-14 h-14 hover:rotate-6'
            }`}
          >
            <div className="relative">
                <ShoppingBag className={`w-6 h-6 ${totalItems === 0 ? 'group-hover:scale-110' : ''} transition-transform`} />
                {totalItems > 0 && (
                    <span className="absolute -top-1.5 -right-1.5 bg-primary text-gray-900 text-[9px] font-bold w-4 h-4 flex items-center justify-center rounded-full border-2 border-gray-900 shadow-sm">
                        {totalItems}
                    </span>
                )}
            </div>
            
            {totalItems > 0 && (
                <div className="flex flex-col items-start animate-fadeIn text-left">
                    <span className="text-sm font-bold leading-none tracking-wide">View Cart</span>
                    <span className="text-[10px] text-gray-400 font-medium leading-none mt-1 font-mono">${cartTotal.toFixed(2)}</span>
                </div>
            )}
          </button>
      </div>

      {/* 4. Cart Sheet */}
      <CartSheet 
        isOpen={isCartOpen} 
        onClose={() => setIsCartOpen(false)} 
        items={cartItems}
        onUpdateQuantity={updateQuantity}
      />

      {/* 5. Dish Detail Modal */}
      <DishDetailModal 
        dish={selectedDish} 
        onClose={() => setSelectedDish(null)} 
        onAddToCart={addToCart}
      />
      
    </div>
  );
}

export default App;