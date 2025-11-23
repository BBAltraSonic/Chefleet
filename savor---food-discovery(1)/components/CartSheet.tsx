import React from 'react';
import { X, Minus, Plus, ArrowRight, ShoppingBag, Trash2 } from 'lucide-react';
import { CartItem } from '../types';

interface CartSheetProps {
  isOpen: boolean;
  onClose: () => void;
  items: CartItem[];
  onUpdateQuantity: (id: string, delta: number) => void;
}

export const CartSheet: React.FC<CartSheetProps> = ({ isOpen, onClose, items, onUpdateQuantity }) => {
  const total = items.reduce((sum, item) => sum + (item.dish.price * item.quantity), 0);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center pointer-events-none">
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm pointer-events-auto transition-opacity duration-300" onClick={onClose} />
      
      <div className="bg-white w-full sm:w-[450px] h-[85vh] rounded-t-3xl shadow-2xl flex flex-col pointer-events-auto transform transition-transform duration-300 animate-slideUp">
        {/* Header */}
        <div className="p-5 border-b border-gray-50 flex justify-between items-center bg-white/80 backdrop-blur-md rounded-t-3xl">
          <div className="flex items-center gap-2.5">
             <div className="p-2 bg-green-50 rounded-xl">
                <ShoppingBag className="w-4 h-4 text-primary" />
             </div>
             <div>
                <h2 className="text-lg font-bold text-gray-900">Your Cart</h2>
                <p className="text-xs text-gray-400 font-medium">{items.length} items</p>
             </div>
          </div>
          <button onClick={onClose} className="p-2 bg-gray-50 hover:bg-gray-100 rounded-xl transition-colors text-gray-400 hover:text-gray-600">
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Items List */}
        <div className="flex-1 overflow-y-auto p-5 space-y-5">
           {items.length === 0 ? (
               <div className="flex flex-col items-center justify-center h-full text-gray-300 space-y-4">
                   <div className="p-6 bg-gray-50 rounded-full">
                      <ShoppingBag className="w-10 h-10 text-gray-200" />
                   </div>
                   <p className="font-medium text-base text-gray-400">Your cart is empty</p>
                   <button onClick={onClose} className="text-primary font-bold text-xs hover:underline">Start Browsing</button>
               </div>
           ) : (
               items.map(item => (
                   <div key={item.dish.id} className="flex gap-3 p-1">
                       <img src={item.dish.imageUrl} className="w-20 h-20 rounded-lg object-cover bg-gray-100 shadow-sm" alt={item.dish.name} />
                       <div className="flex-1 flex flex-col justify-center">
                           <h3 className="font-bold text-base text-gray-900 line-clamp-1">{item.dish.name}</h3>
                           <p className="text-xs text-gray-400 font-medium mb-1.5">{item.dish.restaurant}</p>
                           <div className="font-bold text-gray-900 text-base">${(item.dish.price * item.quantity).toFixed(2)}</div>
                       </div>
                       <div className="flex flex-col items-center justify-between py-0.5">
                           <button 
                             onClick={() => onUpdateQuantity(item.dish.id, 1)} 
                             className="w-7 h-7 flex items-center justify-center bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
                           >
                              <Plus className="w-3.5 h-3.5 text-gray-600" />
                           </button>
                           <span className="text-xs font-bold text-gray-900">{item.quantity}</span>
                           <button 
                             onClick={() => onUpdateQuantity(item.dish.id, -1)} 
                             className={`w-7 h-7 flex items-center justify-center rounded-lg transition-colors ${item.quantity === 1 ? 'bg-red-50 hover:bg-red-100 text-red-500' : 'bg-gray-100 hover:bg-gray-200 text-gray-600'}`}
                           >
                              {item.quantity === 1 ? <Trash2 className="w-3 h-3" /> : <Minus className="w-3.5 h-3.5" />}
                           </button>
                       </div>
                   </div>
               ))
           )}
        </div>

        {/* Footer */}
        {items.length > 0 && (
            <div className="p-6 border-t border-gray-100 bg-white">
                <div className="space-y-2.5 mb-5">
                    <div className="flex justify-between items-center text-gray-500 text-xs font-medium">
                        <span>Subtotal</span>
                        <span>${total.toFixed(2)}</span>
                    </div>
                    <div className="flex justify-between items-center text-gray-500 text-xs font-medium">
                        <span>Service Fee</span>
                        <span>$2.50</span>
                    </div>
                    <div className="pt-3 flex justify-between items-center">
                        <span className="text-base font-bold text-gray-900">Total</span>
                        <span className="text-xl font-bold text-gray-900">${(total + 2.50).toFixed(2)}</span>
                    </div>
                </div>
                <button className="w-full bg-gray-900 text-white py-3.5 rounded-xl font-bold text-base hover:bg-black transition-all transform hover:scale-[1.02] active:scale-95 shadow-xl shadow-gray-200 flex items-center justify-center gap-2 group">
                    Checkout <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </button>
            </div>
        )}
      </div>
    </div>
  );
};