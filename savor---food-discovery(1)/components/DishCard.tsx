import React from 'react';
import { Star, Clock, Heart, Plus } from 'lucide-react';
import { Dish } from '../types';

interface DishCardProps {
  dish: Dish;
  onAddToCart: (dish: Dish) => void;
  onClick: (dish: Dish) => void;
}

export const DishCard: React.FC<DishCardProps> = ({ dish, onAddToCart, onClick }) => {
  return (
    <div 
      onClick={() => onClick(dish)}
      className="flex flex-col bg-white rounded-2xl overflow-hidden hover:shadow-[0_20px_50px_-12px_rgba(0,0,0,0.1)] transition-all duration-500 cursor-pointer group shadow-sm border border-gray-100/60 relative"
    >
      
      {/* Image Container */}
      <div className="relative aspect-[4/3] w-full overflow-hidden">
        <img 
          src={dish.imageUrl} 
          alt={dish.name} 
          className="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-700"
        />
        
        {/* Subtle Gradient Overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent opacity-60" />

        {/* Favorite Button */}
        <button 
          onClick={(e) => { e.stopPropagation(); }}
          className="absolute top-4 right-4 bg-white/30 backdrop-blur-md p-2 rounded-xl hover:bg-white transition-colors group/btn"
        >
          <Heart className="w-4 h-4 text-white group-hover/btn:text-red-500 transition-colors" />
        </button>

        {/* Distance Badge */}
        <div className="absolute top-4 left-4 bg-white/90 backdrop-blur-md px-2.5 py-1 rounded-lg text-[10px] font-bold text-gray-800 shadow-sm flex items-center gap-1">
          <Clock className="w-3 h-3 text-primary" />
          {dish.distance}
        </div>

        {/* Add to Cart Button Overlay */}
        <button 
          onClick={(e) => {
            e.stopPropagation();
            onAddToCart(dish);
          }}
          className="absolute bottom-4 right-4 bg-gray-900/90 backdrop-blur-md p-2.5 rounded-xl hover:bg-black transition-all hover:scale-110 shadow-lg border border-white/10 group/cart active:scale-95"
        >
          <Plus className="w-4 h-4 text-white" />
        </button>
      </div>
      
      {/* Content */}
      <div className="p-4 flex flex-col justify-between flex-1 relative">
        {/* Rating Floating Over Edge */}
        <div className="absolute -top-4 right-auto left-4 bg-white shadow-lg px-2 py-0.5 rounded-lg flex items-center border border-gray-50">
           <Star className="w-3 h-3 fill-amber-400 text-amber-400 mr-1" />
           <span className="text-[10px] font-bold text-gray-900">{dish.rating}</span>
           <span className="text-[9px] text-gray-400 ml-1">({dish.reviewCount})</span>
        </div>

        <div className="mt-1">
          <div className="flex justify-between items-start mb-1">
            <h3 className="font-bold text-lg text-gray-900 leading-tight line-clamp-1 group-hover:text-primary transition-colors flex-1">{dish.name}</h3>
            <span className="text-base font-bold text-gray-900 ml-2">${dish.price}</span>
          </div>
          <p className="text-xs text-gray-500 font-semibold uppercase tracking-wide mb-2 truncate">{dish.restaurant}</p>
          <p className="text-xs text-gray-400 line-clamp-2 leading-relaxed">{dish.description}</p>
        </div>
        
        {/* Tags */}
        <div className="mt-3 flex items-center gap-2">
           {dish.tags?.slice(0, 2).map(tag => (
             <span key={tag} className="text-[9px] bg-gray-100 text-gray-500 px-1.5 py-0.5 rounded-md font-medium">
               {tag}
             </span>
           ))}
        </div>
      </div>
    </div>
  );
};