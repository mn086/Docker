# Basis-Image: Verwendet das offizielle Node.js-Image in der Alpine-Version 22.14.0 (Alpine Linux ist sehr klein und sicher)
FROM node:22.14.0-alpine

# Wechselt zum vordefinierten Node-Benutzer aus Sicherheitsgründen mit eingeschränkten Rechten (vermeidet root-Ausführung)
USER node

# Setzt das Arbeitsverzeichnis im Container auf das Home-Verzeichnis des Node-Benutzers
WORKDIR /home/node

# Kopiert alle Projektdateien (außer die in .dockerignore aufgelisteten) vom aktuellen lokalen Verzeichnis
# in das Container-Arbeitsverzeichnis /home/node/ und setzt node:node als Besitzer
ADD --chown=node:node . /home/node/

# Installiert alle Abhängigkeiten aus der package.json
RUN npm install

# Container-Startbefehl: Führt die Node.js-Anwendung aus
# node: Startet die Node.js-Runtime
# app.js: Die Hauptanwendungsdatei, die ausgeführt werden soll
CMD ["node", "app.js"]

# Image erstellen mit: docker build .
# (docker build -t node-app .) erstellt ein Image mit Name node-app und Tag latest
# (docker tag node-app:latest node-app:1.0.0) gibt dem Image zusätzlich den Tag 1.0.0
# Container starten mit: docker run -d -p 8080:8080 --name my-app -e MESSAGE='Hallo Welt!' bb90
# (docker run -d -p 8080:8080 --name my-app -e MESSAGE='Hallo Welt!' node-app)
# (docker run -d -p 8080:8080 --name my-app -e MESSAGE='Hallo Welt!' --restart=on-failure node-app) startet die App bei einem Crash immer wieder neu
# (docker run -d -p 8080:8080 --name my-app -e MESSAGE='Hallo Welt!' --restart=on-failure:5 node-app) startet die App bei einem Crash bis zu 5x neu

# Image auf den Docker Hub hochaden in das private Repository laden
# docker login ausführen falls man nicht angemeldet ist
# docker tag node-app:latest mn086x202503/node-app:latest stellt dem Namen des Images den Docker Hub Benutzernamen voran
# docker push mn086x202503/node-app:latest lädt das Image in das private Repository hoch
# docker pull mn086x202503/node-app:latest lädt das Image aus dem privaten Repository herunter
# docker run -d -p 8080:8080 --name my-app -e MESSAGE='Hallo Welt!' mn086x202503/node-app:latest startet den Container mit dem Image aus dem privaten Repository
