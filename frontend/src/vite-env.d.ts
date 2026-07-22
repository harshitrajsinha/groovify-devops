/// <reference types="vite/client" />

export {};

declare global {
  interface Window {
    __CONFIG__: {
      VITE_COGNITO_CLIENT_ID: string;
      VITE_COGNITO_DOMAIN: string;
      VITE_BACKEND_URL: string;
      VITE_MODE: string;
    };
  }
}