# 1. Node alap image
FROM node:18

# 2. Munkakönyvtár
WORKDIR /app

# 3. package.json bemásolása
COPY package.json .

# 4. Dependencies telepítése
RUN npm install

# 5. Forráskód bemásolása
COPY . .

# 6. App futtatása
CMD ["node", "app.js"]

# 7. Kívülről elérhető port
EXPOSE 8080
