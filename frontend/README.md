# Building frontend applications via npm

1. Setup config.js in frontend/ directory (refer .env.sample)
```js
window.__CONFIG__ = {
  VITE_BACKEND_URL: "http://localhost:8000",
  VITE_MODE: "development",
  VITE_COGNITO_CLIENT_ID: "https://us-east-sampleurl.auth.us-east-1.amazoncognito.com",
  VITE_COGNITO_DOMAIN: "3aa3aaa2aa220a12a2346aa5aa"
};
```

2. Install dependencies
```bash
npm install
```

3. Run in development mode
```bash
npm run dev
```