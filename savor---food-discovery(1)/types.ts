export interface Dish {
  id: string;
  name: string;
  restaurant: string;
  rating: number;
  reviewCount: number;
  distance: string; // e.g., "0.5 mi"
  imageUrl: string;
  description: string;
  tags?: string[];
  price: number;
}

export interface CartItem {
  dish: Dish;
  quantity: number;
}

export enum NavTab {
  Home = 'Home',
  Favourites = 'Favourites',
  Notifications = 'Notifications',
  Settings = 'Settings'
}

export interface ChatMessage {
  role: 'user' | 'model';
  text: string;
}
