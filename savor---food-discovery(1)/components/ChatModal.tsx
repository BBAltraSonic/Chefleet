import React, { useState, useRef, useEffect } from 'react';
import { X, Send, Sparkles, User, Bot } from 'lucide-react';
import { getChatResponse } from '../services/geminiService';
import { ChatMessage } from '../types';

interface ChatModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const ChatModal: React.FC<ChatModalProps> = ({ isOpen, onClose }) => {
  const [messages, setMessages] = useState<ChatMessage[]>([
    { role: 'model', text: 'Hey there! 👋 I\'m your food concierge. Looking for something specific or need a surprise?' }
  ]);
  const [inputValue, setInputValue] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, loading]);

  const handleSend = async () => {
    if (!inputValue.trim()) return;

    const userMsg: ChatMessage = { role: 'user', text: inputValue };
    setMessages(prev => [...prev, userMsg]);
    setInputValue('');
    setLoading(true);

    const history = messages.map(m => ({
        role: m.role,
        parts: [{ text: m.text }]
    }));

    const responseText = await getChatResponse(history, userMsg.text);
    
    setMessages(prev => [...prev, { role: 'model', text: responseText || "I'm checking the menu..." }]);
    setLoading(false);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center pointer-events-none">
      <div className="absolute inset-0 bg-black/40 backdrop-blur-sm pointer-events-auto transition-opacity duration-300" onClick={onClose} />
      
      <div className="bg-white w-full sm:w-[450px] h-[90vh] sm:h-[700px] rounded-t-[2.5rem] sm:rounded-[2.5rem] shadow-2xl flex flex-col pointer-events-auto transform transition-transform duration-300 scale-100 origin-bottom sm:origin-center overflow-hidden">
        {/* Header */}
        <div className="p-6 pb-4 border-b border-gray-50 flex justify-between items-center bg-white/80 backdrop-blur-md absolute top-0 left-0 right-0 z-10">
          <div className="flex items-center space-x-4">
            <div className="relative">
                <div className="w-12 h-12 bg-gray-900 rounded-full flex items-center justify-center shadow-lg">
                    <Sparkles className="w-6 h-6 text-primary" />
                </div>
                <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 rounded-full border-2 border-white"></div>
            </div>
            <div>
              <h2 className="font-bold text-xl text-gray-900">Savor AI</h2>
              <span className="text-xs text-primary font-bold tracking-wide uppercase">Your Concierge</span>
            </div>
          </div>
          <button onClick={onClose} className="p-2.5 bg-gray-50 hover:bg-gray-100 rounded-full transition-colors text-gray-400 hover:text-gray-600">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto pt-24 pb-6 px-6 space-y-6 bg-gradient-to-b from-gray-50 to-white">
          {messages.map((msg, idx) => (
            <div key={idx} className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'} animate-fadeIn`}>
              <div className={`max-w-[85%] p-5 rounded-3xl text-[15px] leading-relaxed shadow-sm relative group ${
                msg.role === 'user' 
                  ? 'bg-gray-900 text-white rounded-tr-sm' 
                  : 'bg-white text-gray-700 border border-gray-100 rounded-tl-sm shadow-[0_2px_10px_rgba(0,0,0,0.05)]'
              }`}>
                {msg.text}
              </div>
            </div>
          ))}
          {loading && (
             <div className="flex justify-start">
               <div className="bg-white px-5 py-4 rounded-3xl rounded-tl-sm shadow-sm border border-gray-100 flex items-center space-x-2">
                   <span className="text-sm text-gray-400 font-medium mr-2">Thinking</span>
                   <div className="flex space-x-1">
                     <div className="w-1.5 h-1.5 bg-primary rounded-full animate-bounce" style={{animationDelay: '0ms'}}></div>
                     <div className="w-1.5 h-1.5 bg-primary rounded-full animate-bounce" style={{animationDelay: '150ms'}}></div>
                     <div className="w-1.5 h-1.5 bg-primary rounded-full animate-bounce" style={{animationDelay: '300ms'}}></div>
                   </div>
               </div>
             </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input */}
        <div className="p-4 bg-white border-t border-gray-50 pb-8 sm:pb-4">
          <div className="flex items-center bg-gray-100 rounded-[2rem] px-2 py-2 pr-2 border border-transparent focus-within:border-gray-200 focus-within:bg-white focus-within:shadow-lg transition-all duration-300">
            <input 
              type="text" 
              className="flex-1 bg-transparent outline-none text-gray-800 placeholder-gray-400 pl-4 py-3 text-base"
              placeholder="Ask for recommendations..."
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            />
            <button 
              onClick={handleSend}
              disabled={loading || !inputValue.trim()}
              className="p-3.5 bg-primary rounded-full text-white hover:bg-primaryDark disabled:opacity-50 disabled:hover:bg-primary transition-all hover:scale-105 active:scale-95 shadow-md shadow-green-200/50"
            >
              <Send className="w-5 h-5 ml-0.5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};