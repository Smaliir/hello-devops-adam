# Hello DevOps! alkalmazás

A projektem egy Node.js alapú „Hello World” webalkalmazás, amelyen bemutathatom az alap DevOps lépéseket:
- Kódkészítés
- Verziókövetés (trunk-based development)
- Build
- Konténerizálás Dockerrel
- DevContainer használata (plusz feladat)
# Felhő szolgáltatás

- Szolgáltató: Render.com
- Deploy lépések:
  1. Regisztráció Render-re GitHub fiókkal
  2. Új Web Service létrehozása a GitHub repó alapján
  3. Build Command: `npm install && npm run build`
  4. Start Command: `npm start`
 # Publikus URL: [https://hello-devops-adam.onrender.com](https://hello-devops-adam.onrender.com)


---

# 1. Alkalmazás

A projektem egy egyszerű HTTP szervert tartalmaz, amely a következő szöveget íratom ki:

**„Hello DevOps!”**

# Futtatás fejlesztői módban

```sh
npm install
npm start

# EIY77Z
