// Ein Programm, welches den Text "Hello World" aus einer Umgebungsvariable ausgibt
// Installallation von nodejs erforderlich https://nodejs.org/en

// HTTP Modul einbinden
const http = require('http');

// Modul processenv verwenden um Umgebungsvariablen auslesen zu können
// (package.json mit dependencies erforderlich, Terminal: npm install)
const { processenv } = require('processenv');

// Umgebungsvariable aus der Umgebungsvariable auslesen (falls nichts gesetzt ist: 'Hello World')
const message = processenv('MESSAGE', 'Hello World!');

// HTTP Server erstellen und starten
const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.write(message);
    res.end();
});

// Server auf Port 8080 starten
server.listen(8080, () => {
    console.log('Server is running...');
});

// Das Programm kann als Dienst gestartet werden, wenn mit Hilfe des Dockerfile ein Image erzeugt ist.
// docker build .
// Start mit Image ID im Terminal: docker run -d -p 8080:8080 -e MESSAGE='Hallo Welt!'  5c2700e64c01
// Zugriff: curl http://localhost:8080