import React from 'react';
import { X, Clock, Star, Plus, MapPin } from 'lucide-react';
import { Dish } from '../types';

interface DishDetailModalProps {
  dish: Dish | null;
  onClose: () => void;
  onAddToCart: (dish: Dish) => void;
}

export const DishDetailModal: React.FC<DishDetailModalProps> = ({ dish, onClose, onAddToCart }) => {
  if (!dish) return null;

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-black/60 backdrop-blur-sm transition-opacity duration-300"
        onClick={onClose}
      />
      
      {/* Modal Container */}
      <div className="relative w-full max-w-sm bg-white rounded-3xl shadow-2xl overflow-hidden transform transition-all duration-300 scale-100 opacity-100 flex flex-col max-h-[85vh]">
        
        {/* Close Button */}
        <button 
          onClick={onClose}
          className="absolute top-4 right-4 z-20 p-2.5 bg-black/20 hover:bg-black/30 backdrop-blur-md rounded-xl text-white transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Hero Image */}
        <div className="relative h-72 w-full flex-shrink-0 group">
          <img 
            src={dish.imageUrl} 
            alt={dish.name} 
            className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-gradient-to-b from-black/10 via-transparent to-black/60" />
          
          <div className="absolute bottom-5 left-6 right-6 text-white translate-y-0 transition-transform duration-300">
             <div className="inline-flex items-center bg-white/20 backdrop-blur-md rounded-lg px-2 py-1 mb-2 border border-white/10">
                <MapPin className="w-3 h-3 mr-1 text-white" />
                <span className="text-[10px] font-bold uppercase tracking-wide">{dish.restaurant}</span>
             </div>
             <h2 className="text-2xl font-bold leading-tight shadow-black/10 drop-shadow-lg">{dish.name}</h2>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto bg-white flex flex-col flex-1">
          <div className="flex items-center justify-between mb-5">
            <div className="flex items-center space-x-3">
              <div className="flex items-center space-x-1 bg-green-50 px-2.5 py-1.5 rounded-lg border border-green-100">
                <Star className="w-3.5 h-3.5 text-green-600 fill-green-600" />
                <span className="text-xs font-bold text-green-800">{dish.rating}</span>
                <span className="text-[10px] text-green-600 font-medium opacity-80">({dish.reviewCount})</span>
              </div>
              <div className="flex items-center space-x-1 bg-gray-50 px-2.5 py-1.5 rounded-lg border border-gray-100">
                <Clock className="w-3.5 h-3.5 text-gray-500" />
                <span className="text-xs font-medium text-gray-600">{dish.distance}</span>
              </div>
            </div>
            <div className="text-xl font-bold text-gray-900 bg-gray-50 px-3 py-1 rounded-lg border border-gray-100">${dish.price}</div>
          </div>

          <div className="space-y-4 mb-6">
            <h3 className="text-sm font-bold text-gray-900 uppercase tracking-wider">Description</h3>
            <p className="text-gray-500 text-sm leading-relaxed font-medium">
                {dish.description || "A delicious culinary masterpiece prepared with fresh, high-quality ingredients to delight your taste buds."}
            </p>
          </div>

          {dish.tags && dish.tags.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-8">
                {dish.tags.map(tag => (
                <span key={tag} className="px-3 py-1.5 bg-gray-50 text-gray-500 text-[10px] uppercase font-bold tracking-wide rounded-lg border border-gray-100">
                    {tag}
                </span>
                ))}
            </div>
          )}

          <div className="mt-auto pt-4">
            <button 
                onClick={() => {
                    onAddToCart(dish);
                    onClose();
                }}
                className="w-full bg-gray-900 text-white py-4 rounded-xl font-bold text-sm hover:bg-black transition-all transform active:scale-95 shadow-xl shadow-gray-200 flex items-center justify-center gap-2.5 group"
            >
                <div className="bg-white/20 rounded-full p-1 group-hover:bg-white/30 transition-colors">
                    <Plus className="w-4 h-4" />
                </div>
                <span>Add to Order · ${dish.price}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};