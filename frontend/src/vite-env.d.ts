/// <reference types="vite/client" />

export {};

declare global {
  interface Window {
    __CONFIG__: {
      VITE_COGNITO_CLIENT_ID: string;
    };
  }
}