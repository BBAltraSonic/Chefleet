import { GoogleGenAI, Type } from "@google/genai";
import { Dish } from "../types";

// Initialize Gemini Client
const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

const modelName = "gemini-2.5-flash";

/**
 * Generates a list of dishes based on a query or defaults.
 * Uses strict JSON schema validation.
 */
export const fetchDishes = async (query: string = "popular lunch dishes"): Promise<Dish[]> => {
  try {
    const response = await ai.models.generateContent({
      model: modelName,
      contents: `Generate 8 diverse, appetizing, and realistic restaurant dish listings for a high-end food discovery app based on the theme: "${query}". 
      Ensure the restaurants sound trendy and realistic. Use specific distances (0.1 - 3.5 mi). Include a realistic price between $12 and $35.`,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.ARRAY,
          items: {
            type: Type.OBJECT,
            properties: {
              id: { type: Type.STRING },
              name: { type: Type.STRING },
              restaurant: { type: Type.STRING },
              rating: { type: Type.NUMBER },
              reviewCount: { type: Type.INTEGER },
              distance: { type: Type.STRING },
              description: { type: Type.STRING },
              price: { type: Type.NUMBER },
              tags: { type: Type.ARRAY, items: { type: Type.STRING } }
            },
            required: ["id", "name", "restaurant", "rating", "reviewCount", "distance", "description", "price"]
          }
        }
      }
    });

    const data = JSON.parse(response.text || "[]");
    
    // Map generic images to the results using high-quality curated images
    return data.map((dish: any, index: number) => ({
      ...dish,
      imageUrl: getImageUrlForDish(dish.name, index)
    }));

  } catch (error) {
    console.error("Gemini API Error:", error);
    return getFallbackDishes();
  }
};

/**
 * Chat with the AI assistant
 */
export const getChatResponse = async (history: { role: string, parts: { text: string }[] }[], message: string): Promise<string> => {
  try {
    const chat = ai.chats.create({
      model: modelName,
      history: history,
      config: {
        systemInstruction: "You are a helpful food concierge for a high-end food delivery app called Savor AI. Help users find dishes and make recommendations. Keep responses concise.",
      }
    });

    const result = await chat.sendMessage({ message });
    return result.text || "";
  } catch (error) {
    console.error("Gemini Chat Error:", error);
    return "I'm having a bit of trouble connecting to the kitchen. Please try again.";
  }
};

/**
 * Helper to match dish names to relevant Unsplash keywords using high-quality static IDs
 */
const getImageUrlForDish = (name: string, index: number): string => {
  const lower = name.toLowerCase();
  
  const imageMap: Record<string, string[]> = {
    taco: [
      "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&q=80",
      "https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=800&q=80",
      "https://images.unsplash.com/photo-1613514785940-daed07799d9b?w=800&q=80"
    ],
    burger: [
      "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80",
      "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=800&q=80",
      "https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&q=80"
    ],
    sushi: [
      "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&q=80",
      "https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800&q=80",
      "https://images.unsplash.com/photo-1615555465696-6d5022dc7797?w=800&q=80"
    ],
    pizza: [
      "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80",
      "https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=800&q=80",
      "https://images.unsplash.com/photo-1594007654729-407eedc4be65?w=800&q=80"
    ],
    salad: [
      "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80",
      "https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800&q=80",
      "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&q=80"
    ],
    pasta: [
      "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=800&q=80",
      "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&q=80",
      "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800&q=80"
    ],
    steak: [
      "https://images.unsplash.com/photo-1600891964092-4316c288032e?w=800&q=80",
      "https://images.unsplash.com/photo-1504973960431-1c467e159aa4?w=800&q=80"
    ],
    ramen: [
      "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80",
      "https://images.unsplash.com/photo-1591814468924-caf88d1232e1?w=800&q=80"
    ],
    dessert: [
      "https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=800&q=80",
      "https://images.unsplash.com/photo-1551024601-564d6d6744f1?w=800&q=80"
    ],
    generic: [
      "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80",
      "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&q=80",
      "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&q=80",
      "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=800&q=80"
    ]
  };

  let selectedKey = 'generic';
  if (lower.includes('taco')) selectedKey = 'taco';
  else if (lower.includes('burger')) selectedKey = 'burger';
  else if (lower.includes('sushi') || lower.includes('roll')) selectedKey = 'sushi';
  else if (lower.includes('pizza')) selectedKey = 'pizza';
  else if (lower.includes('salad') || lower.includes('bowl') || lower.includes('healthy')) selectedKey = 'salad';
  else if (lower.includes('pasta') || lower.includes('spaghetti')) selectedKey = 'pasta';
  else if (lower.includes('steak') || lower.includes('beef')) selectedKey = 'steak';
  else if (lower.includes('ramen') || lower.includes('noodle')) selectedKey = 'ramen';
  else if (lower.includes('cake') || lower.includes('ice cream') || lower.includes('sweet')) selectedKey = 'dessert';

  const options = imageMap[selectedKey];
  // Deterministic selection based on index so it doesn't flicker on re-renders if the list is stable
  return options[index % options.length];
};

/**
 * Fallback data if API fails
 */
const getFallbackDishes = (): Dish[] => [
  {
    id: "1",
    name: "Spicy Chicken Tacos",
    restaurant: "Taco Haven",
    rating: 4.5,
    reviewCount: 120,
    distance: "0.5 mi",
    imageUrl: "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&q=80",
    description: "Authentic street style tacos with spicy salsa.",
    price: 14
  },
  {
    id: "2",
    name: "Vegan Pad Thai",
    restaurant: "Thai Delight",
    rating: 4.2,
    reviewCount: 85,
    distance: "1.2 mi",
    imageUrl: "https://images.unsplash.com/photo-1559314809-0d155014e29e?w=800&q=80",
    description: "Classic stir-fried rice noodles with tofu.",
    price: 18
  },
  {
    id: "3",
    name: "Gourmet Burger",
    restaurant: "Burger Joint",
    rating: 4.8,
    reviewCount: 210,
    distance: "0.8 mi",
    imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80",
    description: "Juicy beef patty with swiss cheese.",
    price: 22
  },
  {
    id: "4",
    name: "Fresh Sushi Rolls",
    restaurant: "Sushi Spot",
    rating: 4.6,
    reviewCount: 150,
    distance: "0.3 mi",
    imageUrl: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&q=80",
    description: "Fresh salmon and avocado rolls.",
    price: 26
  },
  {
    id: "5",
    name: "Margherita Pizza",
    restaurant: "Bella Italia",
    rating: 4.7,
    reviewCount: 320,
    distance: "1.5 mi",
    imageUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80",
    description: "Wood-fired pizza with fresh basil and mozzarella.",
    price: 20
  },
  {
    id: "6",
    name: "Quinoa Salad Bowl",
    restaurant: "Green Eats",
    rating: 4.4,
    reviewCount: 95,
    distance: "0.6 mi",
    imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80",
    description: "Healthy quinoa salad with avocado and lime dressing.",
    price: 16
  }
];
