import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import './index.css';
import { Toaster } from '@/components/ui/toaster';
import { AnimatePresence } from 'framer-motion';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <AnimatePresence>
      <App />
    </AnimatePresence>
    <Toaster />
  </StrictMode>
);