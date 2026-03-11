FROM node:19 as build

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./
# Install all dependencies including devDependencies for build stage
RUN npm ci
COPY . ./
RUN npm run build


FROM node:19-alpine3.16

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Copy the entire built app from build stage
COPY --from=build /app/build ./build

# Install only vite for serving the preview
RUN npm install vite

ENV HOST=0.0.0.0
EXPOSE 4173
CMD ["npx", "vite", "preview", "--host", "0.0.0.0", "--port", "4173"]


