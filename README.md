# Docker

## Featrures aus dem LINUX Kernel
Ein Prozess soll von allen anderen komplett isoliert laufen (ähnlich wie Virtuelle Maschinen, jedoch teilen sich alle Prozesse den selben LINUX-Kernel, der in Docker gewrapped ist). Docker basiert auf den folgenden Features:
- cgroups
    - Quotas für Prozesse auf CPU- und RAM-Ebene (Limit für Ressourcen)
- Namespaces (ein Prozess wird eingepackt als ob er der einzige Prozess auf der Maschine wäre)
    - PID (simuliert Prozess ID 1, als ob der Prozess der einzige wäre)
    - Netzwerk (simuliert ein Netzwerkinterface allein für den Prozess)
    - Dateisystem (virtuell)
    - ...

## Instalation von Docker (Engine & CLI)
https://docs.docker.com/engine/install/centos/
https://docs.docker.com/desktop/setup/install/mac-install/
https://docs.docker.com/desktop/setup/install/windows-install/
https://github.com/moby/moby/blob/f586a473cf8dc9ac1edf893f70ccf37c2e217035/pkg/namesgenerator/names-generator.go#L844-L846

- Mac OS, Win
    - haben keine Konstrukte des LINUX-Kernels (weshalb die Engine erst mal nichts nützt)
    - Docker Desktop enthält Engine und CLI und leichtgewichtige virtuelle Maschine mit LINUX auf dem Docker ausgeführt wird

- LINUX
    - nur Engine und CLI (Kommandozeilen-Tool) erforderlich

## Prüfung ob Installation erfolgreich war
zum Beispiel mit:
- `docker version` (die Docker Engine muss zum Beispiel durch Start von Docker Desktop laufen)

## Prozesse zum Ausführen
- Herunterladen von Prozessen auf vorgefertigte Images (mit einen oder mehreren Anwendungen)
- Falls keine Eingehenden und Ausgehenden Regeln für Docker in den Firewall-Reglen vorhanden sind (`ping registry-1.docker.io` gehen verloren, bzw. Öffen der Firewall-Einstellungen mit `wf.msc`) können mit geöffneter PowerShell als Administrator folgende Regeln hinzugefügt werden:
    - `New-NetFirewallRule -DisplayName "Docker Engine" -Direction Inbound -Program "C:\Program Files\Docker\Docker\resources\com.docker.backend.exe" -Action Allow`
    - `New-NetFirewallRule -DisplayName "Docker Desktop" -Direction Inbound -Program "C:\Program Files\Docker\Docker\Docker Desktop.exe" -Action Allow`
    - `New-NetFirewallRule -DisplayName "Docker Engine" -Direction Outbound -Program "C:\Program Files\Docker\Docker\resources\com.docker.backend.exe" -Action Allow`
    - `New-NetFirewallRule -DisplayName "Docker Desktop" -Direction Outbound -Program "C:\Program Files\Docker\Docker\Docker Desktop.exe" -Action Allow`
- Falls immer noch kein SignIn und Pull möglich ist, kann es an Proxy-Autokonfiguration und/oder alten virtuellen Adapter (VPN) liegen:
    - Proxy-Autopkonfiguration entfernen:
        - Windows-Einstellungen öffnen
        - Netzwerk & Internet → Proxy
        - Unter "Automatisches Setup" prüfen ob alte Einträge existieren
        - Alle automatischen Proxy-Skripte deaktivieren
    - Virtuelle Adapter bereinigen
        - Alle Netzwerkadapter anzeigen: `Get-NetAdapter | Format-Table Name, InterfaceDescription, Status`
        - Netzwerkeinstellungen öffnen (`ncpa.cpl`)
        - Nach nicht mehr benötigten virtuellen Adaptern suchen (z.B. alte VPN-Adapter)
        - Diese Adapter deaktivieren oder entfernen
    - Neustart
        - `taskkill /f /im "Docker Desktop.exe"`
        - `taskkill /f /im "com.docker.backend.exe"`
        - `Restart-Computer -Force`
- `docker pull [Imagename]`
- `docker pull hello-world` ohne Angabe von Tag wird die neueste Version heruntergeladen ("Using default tag: latest")
- `docker pull ubuntu`
- `docker run [Imagename]` nimmt ein Image und macht daraus einen ausgeführten Container (aus einen Image kann es mehrere ausgeführte Instanzen "Container" geben)
- `docker run hello-world`
- `docker run -it ubuntu bash` der Prozess `bash` aus dem Image `ubuntu` wird interaktiv `it` gestartet (->Anmeldung als Beuntzer@zufällig zugewiesener Hostname, z.B. root@f25746aabecc)
    - `ls` zeigt den Inhalt des Root-Verzeichnis an
    - `uname` zeigt an, dass man sich tatsächlich in LINUX befindet
    - `touch [Dateiname]` eine Datei anlegen (z.B. `touch test_meine_Datei` und Überprüfung mit `ls`)
    - `exit` beendet den Bash
    - `docker run -it ubuntu bash` ruft einen neuen Container auf (neuer Hostname) auf den die erstellten Dateien im vorherigen Container nicht existieren (`ls`). Der vorrige Container wurde also mit dem Beenden des Prozesses rückstandslos entfernt.
- `docker pull ubuntu:21.10` läd eine spezifische Version von Ubuntu herunter (womit beide Ubuntu Images parallel vorhanden sind)
- `docker images` zeigt alle vorhandenen Images an
- `docker run -it ubuntu:20.10 bash` läd die Ubuntu Version 20.10 herunter, da sie noch nicht vorhanden ist und startet sie (ohne das der Befehl `pull` explizit ausgeführt werden muss)

### Applikationen starten
Für nahezu alle Anwendungen gibt es bereits vorhandene Images.
- `docker run -it nginx:1.21.4` zum Starten eines Webservers mit Standard-Kommando (startet den Standardprozess gleichbedeutend wie `docker run -it nginx:1.21.4 nginx`)
    - Tasten 'strg'+'C' zum Beenden des Prozesses
    - mit `it` läuft der Dienst interaktiv, was aber bei einem Dienst der Hintergrund laufen soll, nicht sinnvoll ist
    - `docker run -d nginx:1.21.4` führt den Prozess `nginx` entkoppelt `d` (detached) vom Terminal im Hintegrund aus
    - `docker run -d nginx:1.21.4` kann man beliebig oft ausführen wobei man immer wieder neue Container startet
    - `docker run -d --name mein_webserver nginx:1.21.4` startet den Prozess mit dem definierten Prozessnamen 'mein_webserver'

### Welche Container (aktuell) ausgeführt werden
- `docker ps` zeigt die laufenden Container an (der Prozessname 'NAMES' ist eine Komination aus Adjektiv_Nachname, der leichter handhabbar ist wie die 'CONTAINER ID')
- `docker logs jolly_saha` zeigt die Logs für den Prozess mit Prozessnamen 'jolly_saha' an (statt die 'CONTAINER ID' zu verwenden)
- `docker logs --follow jolly_saha` optional kann die Flag `--follow` oder `-f` angegeben werden, um live die Ausgaben des Prozesses im Terminal zu verfolgen.
- `docker logs 72b` mit der Angabe der ersten Zeichen der 'CONTAINER ID' würde ebenfalls funktionieren, sobald sie eindeutig sind (es keinen weiteren Prozess mit den gleichen ersten Zeichen existiert)
- `docker ps -a` zeigt alle (auch in der Vergangenheit) ausgeführten Container an

## Aufräumen: Container beenden, Container und Images löschen
- `docker stop mein_webserver` beendet den Prozess 'mein_webserver'
- `docker kill jolly_saha` schließt den Prozess sofort (ohne "Herunterufahren")
- `docker rm mein_webserver` löscht den Container 'mein_webserver'
- `docker rmi ubuntu:21.10` entfernt das Image 'ubuntu:20.10'
- `docker system prune --all --volumes` räumt alles `--all`auf, was nicht mehr benutzt wird. Mit `--volumes` werden auch die virtuellen Dateisyteme bereinigt.
- `docker stop a5 47 2d` stoppt mehrere verbleibende laufende Container
- `docker kill mein_webserver && docker rm mein_webserver` schließt und löscht den Prozess

## Ports weiterleiten (Arbeiten mit dem Webserver)
Standardmäßig läuft jeder Webserver-Prozess innerhalb des Containers im jeweils eigenen Netzwerk auf Port 80, welcher jedoch nicht der Port des Hosts ist.
- `docker run -d --name mein_webserver -p 3000:80  nginx` verbindet die Ports des Containers mit dem Host `-p [Host-Port]:[Container-Port]` (Standard tcp) beim Initialisieren des Containers.
- `curl http://localhost:3000` Zugriff auf den Port (auf die Default-Seite von nginx) des virtuellen LINUX Host...Docker kümmert sich um das Routing weshalb man localhost vom Rechner verwenden kann.
- `docker run -d --name mein_webserver -p 3000:80 -e FOO=bar -v ${pwd}:/usr/share/nginx/html nginx` startet den Container mit der Umgebungsvariable `-e` 'FOO' mit dem Wert 'bar'.  Das Volume `-v` leitet ein Verzeichnis des Host-Systems in den Container weiter. Der Container erwartet in '/usr/share/nginx/html' HTML-Dateien. `-v [absoluter Pfad des Hosts]:[Container-Pfad]`, wobei der absolute Pfad (aktuelles Arbeitsverzeichnis) mit einer Sub-Schell `${}` (Unix/Linux/Mac: `$()`) und dem Befehl `pwd` ausgelesen und übergeben werden kann.
    - `curl http://localhost:3000` kann dann die index.html aus diesen Projektverzeichnis, welches sich jetzt auch im Container befindet, öffnen.
    - `curl http://localhost:3000/README.md` kann ebenfalls aufgerufen werden