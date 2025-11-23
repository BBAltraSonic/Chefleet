import React from 'react';
import { Search, Navigation, SlidersHorizontal, Map } from 'lucide-react';

interface MapHeaderProps {
  onSearch: (query: string) => void;
}

export const MapHeader: React.FC<MapHeaderProps> = ({ onSearch }) => {
  return (
    <div className="relative w-full h-[50vh] bg-gray-200 overflow-hidden z-0">
      {/* Background Map Image */}
      <img 
        src="https://images.unsplash.com/photo-1524661135-423995f22d0b?w=1600&auto=format&fit=crop&q=80" 
        alt="Map View" 
        className="w-full h-full object-cover opacity-90 saturate-[0.8]"
      />
      
      {/* Top Gradient for Status Bar Area */}
      <div className="absolute top-0 left-0 right-0 h-32 bg-gradient-to-b from-black/40 to-transparent pointer-events-none" />
      
      {/* Bottom Gradient for smooth transition to content */}
      <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-black/10 to-transparent pointer-events-none" />

      {/* Floating Search Bar */}
      <div className="absolute top-12 left-1/2 transform -translate-x-1/2 w-[90%] max-w-md z-20">
        <div className="bg-white/90 backdrop-blur-xl rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.12)] flex items-center p-2 transition-all hover:scale-[1.01] hover:bg-white border border-white/50">
          <div className="p-2 bg-primary/10 rounded-xl">
             <Search className="w-4 h-4 text-primary" />
          </div>
          <input 
            type="text" 
            placeholder="Find restaurants, dishes..." 
            className="flex-1 ml-3 outline-none text-gray-800 placeholder-gray-500 bg-transparent text-xs font-medium"
            onKeyDown={(e) => {
              if (e.key === 'Enter') {
                onSearch(e.currentTarget.value);
              }
            }}
          />
          <button className="p-2 rounded-xl hover:bg-gray-100 text-gray-500 transition-colors border-l border-gray-200 pl-3 ml-1">
            <SlidersHorizontal className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Floating Map Controls */}
      <div className="absolute bottom-12 right-5 flex flex-col space-y-3 z-20">
        <button className="bg-white/95 backdrop-blur-sm p-3 rounded-xl shadow-xl hover:bg-white active:scale-95 transition-all text-gray-700 hover:text-primary">
          <Navigation className="w-4 h-4 fill-current" />
        </button>
        <button className="bg-white/95 backdrop-blur-sm p-3 rounded-xl shadow-xl hover:bg-white active:scale-95 transition-all text-gray-700 hover:text-primary">
          <Map className="w-4 h-4" />
        </button>
      </div>

      {/* User Location Marker - Clean version */}
      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 pointer-events-none">
         <div className="relative">
             {/* Pulsing Effect */}
             <div className="absolute -inset-8 bg-primary/30 rounded-full animate-ping opacity-75"></div>
             <div className="absolute -inset-4 bg-primary/20 rounded-full animate-pulse"></div>
             
             {/* Main Marker */}
             <div className="w-14 h-14 bg-white rounded-full shadow-2xl flex items-center justify-center transform hover:scale-110 transition-transform cursor-pointer pointer-events-auto border-4 border-white relative z-10">
                <div className="w-full h-full rounded-full bg-primary flex items-center justify-center overflow-hidden">
                    <img src="https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=200&h=200&fit=crop" alt="User" className="w-full h-full object-cover" />
                </div>
                {/* Status Dot */}
                <div className="absolute bottom-1 right-1 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></div>
             </div>
         </div>
      </div>

      {/* Nearby Dish Marker 1 */}
      <div className="absolute top-[40%] left-[20%] transform -translate-x-1/2 -translate-y-1/2 pointer-events-none animate-bounce" style={{ animationDuration: '3s' }}>
         <div className="bg-white p-1 rounded-xl shadow-lg shadow-black/10 cursor-pointer pointer-events-auto hover:scale-110 transition-transform relative group">
             <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=100&h=100&fit=crop" className="w-10 h-10 rounded-lg object-cover" alt="Burger" />
             <div className="absolute -top-2 -right-2 bg-green-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full border-2 border-white shadow-sm">9.5</div>
         </div>
      </div>

      {/* Nearby Dish Marker 2 */}
       <div className="absolute bottom-[35%] right-[25%] transform -translate-x-1/2 -translate-y-1/2 pointer-events-none animate-bounce" style={{ animationDuration: '4s', animationDelay: '1s' }}>
         <div className="bg-white p-1 rounded-xl shadow-lg shadow-black/10 cursor-pointer pointer-events-auto hover:scale-110 transition-transform relative group">
             <img src="https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=100&h=100&fit=crop" className="w-10 h-10 rounded-lg object-cover" alt="Sushi" />
              <div className="absolute -top-2 -right-2 bg-green-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full border-2 border-white shadow-sm">9.2</div>
         </div>
      </div>
    </div>
  );
};