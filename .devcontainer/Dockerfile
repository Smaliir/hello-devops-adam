FROM node:18-bullseye
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
CMD ["node", "app.js"]
