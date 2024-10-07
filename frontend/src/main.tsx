import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import { WalletProvider } from './WalletProvider.tsx';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
     <WalletProvider>
      <App />
    </WalletProvider>
  </StrictMode>,
)
