# Building applications via Docker

We will <u>use root directory as the current context</u> to build images and reference all files from the root directory, as done in Dockerfile as well to copy application files from frontend/ and backend/ directories.

### Building and running backend container

1. Setup .env in backend/ directory (refer .env.sample)
```
PORT=8000
MONGODB_URI=<using mongodb cloud>
ADMIN_EMAIL=
NODE_ENV=development

CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
CLOUDINARY_CLOUD_NAME=

FRONTEND_URL=http://localhost:80

COGNITO_DOMAIN=
COGNITO_CLIENT_ID=
COGNITO_CLIENT_SECRET=
COGNITO_REDIRECT_URI=
COGNITO_USER_POOL_ID=
```

2. Run docker build command from root directory of project

```
docker build -t harshitrajsinha/backend:v1 -f docker/Dockerfile.backend .

docker build --secret id=spotify-frontend-env,src=frontend/.env -t harshitrajsinha/frontend:test -f docker/Dockerfile.frontend .
```

3. Run docker run command from root directory of project
```
docker run -p 8000:8000 --env-file ./backend/.env harshitrajsinha/backend:v1
```

### Building and running frontend container

1. Setup .env in frontend/ directory (refer .env.sample)
```
VITE_BACKEND_URL=http://localhost:8000
VITE_MODE=development
VITE_COGNITO_DOMAIN=
VITE_COGNITO_CLIENT_ID=
```

2. Run docker build command from root directory of project

```
docker build --secret id=spotify-frontend-env,src=frontend/.env -t harshitrajsinha/frontend:v1 -f docker/Dockerfile.frontend .
```

3. Run docker run command from root directory of project
```
 docker run -p 80:80 -d harshitrajsinha/frontend:v1
```