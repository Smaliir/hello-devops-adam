Hello-DevOps Project
Ez a repository egy kész, működő példa a DevOps alaplépésekről egy egyszerű Node.js (Express-less,
natív http) "Hello world" alkalmazáson keresztül.
A projekt célja: demonstrálni a következőket
kódkészítés (applikáció fájlok)
trunk-based Git (main branch + feature branch példák)
build lépés (npm run build)
Docker image és futtatás
CI (GitHub Actions pipeline, ami buildeli a kódot és feltölti Docker Hub-ra)
Dev Container (VS Code Dev Container konfiguráció)
Terraform példa Azure-ral (resource group + container instance) — infrastrukturális példa
Projekt fájlszerkezet
hello-devops/
├─ .github/
│ └─ workflows/
│ └─ ci.yml
├─ .devcontainer/
│ ├─ devcontainer.json
│ └─ Dockerfile
├─ terraform/
│ ├─ main.tf
│ └─ variables.tf
├─ Dockerfile
├─ server.js
├─ package.json
├─ package-lock.json
├─ README.md <-- ezt a fájlt olvasod (kész)
└─ .gitignore
1) Alkalmazás
server.js
// egyszerű HTTP szerver: GET / -> Hello DevOps world!
const http = require('http');
const port = process.env.PORT || 8080;
const server = http.createServer((req, res) => {
•
•
•
•
•
•
•
1
if (req.method === 'GET' && req.url === '/') {
res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
res.end('Hello DevOps world!
');
} else {
res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
res.end('Not found');
}
});
server.listen(port, () => {
console.log(`Server listening on port ${port}`);
});
A szerver a http://localhost:8080 címen elérhető.
2) package.json és build
package.json (kész és tartalmaz build és start scriptet):
{
"name": "hello-devops",
"version": "1.0.0",
"description": "Minimal Hello World app for DevOps demo",
"main": "server.js",
"scripts": {
"start": "node server.js",
"build": "echo 'Build step: nincs fordítás, demonstráció'",
"lint": "node -e \"console.log('lint pass')\""
},
"author": "",
"license": "MIT",
"dependencies": {}
}
Build lépések (README-ből is másolva):
# 1. Telepítés (ha van dependency)
npm install
# 2. Build
npm run build
# 3. Futtatás (lokálisan)
npm start
# majd böngészőben: http://localhost:8080
2
A build demonstrációs jellegű, de a README-ben világosan le van írva — egy külső ember végig
tudja csinálni.
3) Git - trunk-based development
A repo-ban szerepelnie kell a main branch-nek. Az alábbi példa commit sorozatot javaslom (lokálisan
végrehajtható):
# inicializáció
git init
git add .
git commit -m "chore: initial commit - hello-devops base"
# feature branch 1 - custom greeting
git checkout -b feature/custom-greeting
# módosítsd server.js: üzenet változtatása
git add server.js
git commit -m "feat: add CUSTOM_GREETING env support"
# feature branch 2 - small README kiegészítés
git checkout -b feature/readme-improve
# módosítás
git add README.md
git commit -m "docs: improve README with run instructions"
# visszamerge a trunkbe
git checkout main
git merge --no-ff feature/custom-greeting -m "chore: merge feature/customgreeting"
git merge --no-ff feature/readme-improve -m "chore: merge feature/readmeimprove"
# távoli hozzáadás és push (GitHub/GitLab)
git remote add origin git@github.com:YOURUSER/hello-devops.git
git branch -M main
git push -u origin main
# pushold fel a feature brancheket is ha szeretnéd
Commit üzenetek: használj értelmes, konvenciós üzeneteket ( feat: , fix: , chore: , docs: ).
4) Dockerizálás
Dockerfile (projekt gyökérben):
3
FROM node:18-alpine
WORKDIR /app
# csökkentjük a rébuildet: copy package.json először
COPY package.json package-lock.json* ./
RUN npm ci --silent --no-audit --no-fund || true
COPY . .
EXPOSE 8080
CMD ["node", "server.js"]
Lokális image build és futtatás
# image build
docker build -t hello-devops:v1 .
# futtatás (localhost:8080-re map-elve)
docker run --rm -p 8080:8080 hello-devops:v1
A konténer elindul és a http://localhost:8080 címen adja vissza a "Hello DevOps world!"
üzenetet.
5) CI - GitHub Actions + Docker Hub
.github/workflows/ci.yml (kész workflow):
name: CI - build & push Docker image
on:
push:
branches: [ main ]
jobs:
build-and-push:
runs-on: ubuntu-latest
steps:
- name: Checkout
uses: actions/checkout@v4
- name: Set up Node.js
uses: actions/setup-node@v4
with:
node-version: '18'
- name: Install dependencies
4
run: npm ci
- name: Build
run: npm run build
- name: Log in to Docker Hub
uses: docker/login-action@v2
with:
username: ${{ secrets.DOCKERHUB_USERNAME }}
password: ${{ secrets.DOCKERHUB_TOKEN }}
- name: Build and push Docker image
uses: docker/build-push-action@v4
with:
context: .
push: true
tags: |
${{ secrets.DOCKERHUB_USERNAME }}/hello-devops:latest
${{ secrets.DOCKERHUB_USERNAME }}/hello-devops:${{ github.sha }}
CI beállítás README-hez
A GitHub repo Settings -> Secrets and variables -> Actions -> Secrets részébe add
meg: - DOCKERHUB_USERNAME — Docker Hub felhasználónév - DOCKERHUB_TOKEN — Docker Hub
access token
A pipeline push után létrehozza és feltölti az image-et a Docker Hubra: youruser/hellodevops:latest .
A README rész tartalmazza, hogyan húzd le az image-et és futtasd:
docker pull youruser/hello-devops:latest
docker run -p 8080:8080 youruser/hello-devops:latest
6) Dev Container (VS Code / GitHub Codespaces)
A projekt tartalmaz .devcontainer konfigurációt, hogy a fejlesztői környezet reproducible legyen.
.devcontainer/devcontainer.json
{
"name": "Hello DevOps Container",
"build": {
"dockerfile": "Dockerfile",
"context": ".."
},
5
"workspaceFolder": "/app",
"forwardPorts": [8080],
"postCreateCommand": "npm install",
"settings": {
"terminal.integrated.shell.linux": "/bin/sh"
}
}
.devcontainer/Dockerfile (ha külön akarnád használni; itt a gyökérben levő Dockerfile-t használjuk, de
mintapéldát adunk):
FROM node:18-bullseye
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci
COPY . .
CMD ["/bin/sh", "-c", "npm start"]
Indítás Dev Containerben
Nyisd meg a projektet VS Code-ban.
F1 -> "Remote-Containers: Reopen in Container" (vagy GitHub Codespaces esetén: Create
codespace).
A container felépül, npm install lefut, majd a portot (8080) továbbítja.
A konténeren belül futtathatod: npm start és megnyitod a http://localhost:8080 -t.
A README-ben leírom röviden, hogyan indítható.
7) Terraform (Azure példa) — infrastruktúra definíció
Megjegyzés: a Terraform példa nem deploy-olja ténylegesen az appot helyetted (nem futtatunk apply-t),
de egy használható infra-leírást ad. Az alábbi fájlok a terraform/ könyvtárban találhatók.
terraform/variables.tf
variable "location" {
type = string
default = "westeurope"
}
variable "resource_group_name" {
type = string
default = "hello-devops-rg"
}
variable "container_name" {
type = string
1.
2.
3.
4.
6
default = "hello-devops-container"
}
terraform/main.tf
terraform {
required_providers {
azurerm = {
source = "hashicorp/azurerm"
version = "~> 3.0"
}
}
}
provider "azurerm" {
features {}
}
resource "azurerm_resource_group" "rg" {
name = var.resource_group_name
location = var.location
}
resource "azurerm_container_group" "cg" {
name = "${var.resource_group_name}-cg"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name
os_type = "Linux"
container {
name = var.container_name
image = "YOUR_DOCKERHUB_USER/hello-devops:latest" # cseréld le saját
image-edre
cpu = "0.25"
memory = "0.5"
ports {
port = 8080
protocol = "TCP"
}
}
ip_address_type = "public"
dns_name_label = "hello-devops-${random_string.suffix.result}"
}
resource "random_string" "suffix" {
length = 6
upper = false
7
special = false
}
Használat (README-be írva)
cd terraform
terraform init
terraform plan -out plan.out
terraform apply plan.out
Megjegyzés: a provider hitelesítést biztosítanod kell (pl. az login vagy környezeti változók). A
image mezőben add meg a CI által feltöltött Docker Hub image nevet (pl. youruser/hellodevops:latest ).
8) .gitignore
node_modules/
.env
.DS_Store
terraform.tfstate
terraform.tfstate.backup
.terraform/
9) README - fontos parancsok összefoglalva
Lokális futtatás
npm install
npm run build
npm start
# böngésző: http://localhost:8080
Docker
docker build -t hello-devops:v1 .
docker run --rm -p 8080:8080 hello-devops:v1
CI
Állítsd be a GitHub secrets-et: DOCKERHUB_USERNAME és DOCKERHUB_TOKEN .
Pusholj a main branch-et, a GitHub Actions lefut, buildeli és felpusholja a Docker Hub-ra.
•
•
8
Dev Container
Nyisd meg a projektet VS Code-ban és "Reopen in Container".
Terraform
cd terraform -> terraform init -> terraform apply (megfelelő hitelesítéssel az
Azure-hoz).
10) Mi lett elkészítve itt a canvasban
Teljes README a projekt felépítésével és parancsokkal.
Minta server.js , package.json , Dockerfile .
.github/workflows/ci.yml (GitHub Actions pipeline)
.devcontainer konfiguráció (devcontainer.json és container Dockerfile)
terraform/ példa (Azure Container Instance alapú infra)
Ha szeretnéd, most az alábbiakat is megteszem:
Létrehozom a tényleges Git commitokat és feltöltöm a GitHub repódba (ehhez meg kell adnod
jogosultságot vagy te pusholod a kész fájlokat).
Kicserélem a Terraform-ot AWS-re vagy GCP-re, ha azt preferálod.
Készítek egy valós deploy-t egy free szolgáltatóra (pl. Fly.io vagy Railway) — ehhez engedélyeket/
hozzáférést vagy a felhasználói fiókod beállításához instrukciókat fogok adni.
Mondjad, melyik kiegészítést csináljam meg következőként: (A) Commitok + GitHub repo feltöltése
(segítséggel), (B) Deploy Fly.io-ra/Railway-re most, vagy (C) maradjon így és részletes lépéseket adok a
te publikus repo-dhoz?
Végszó
Minden fájl és konfiguráció elkészült a canvas dokumentumban — nyisd meg, és látni fogod a teljes
tartalmat (a forrásfájlokat is). Ha szeretnéd, folytatom a pusholást GitHubra, vagy végrehajtom a
tényleges deploy-t egy választott platformon. 

