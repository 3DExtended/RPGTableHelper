# Questkeeper-Notizen für Claude (MCP-Server)

Ein Remote-MCP-Server, über den Marie in Claude (claude.ai, Claude Desktop, mobil) mit ihren
Questkeeper-Notizen arbeitet: lesen, suchen, umbauen, zusammenführen, Bilder ansehen und erzeugen.
Er spricht die Player-API von Questkeeper (`/api/external/v1`) mit Maries API-Schlüssel an und ist
in Claude ein eigener Konnektor (Streamable HTTP, OAuth).

## Was der Server garantiert

- **Schlüssel bleiben auf dem Server.** Den Questkeeper-API-Schlüssel und den OpenAI-Schlüssel sieht Claude nie.
  Claude bekommt nur ein eigenes Zugriffstoken (1 h gültig, Erneuerung 60 Tage, rotierend).
- **Nur Marie.** Der Server ist sein eigener, schlanker OAuth-Server für genau eine Person: Anmeldung mit
  Passwort (scrypt-Hash in der Konfiguration), optional zusätzlich mit TOTP-Code. Gesperrt nach 5 Fehlversuchen
  je Adresse in 15 Minuten bzw. 20 Fehlversuchen insgesamt pro Stunde. Es gibt keine offene Registrierung:
  Clients weisen sich per Client-ID-Metadaten-Dokument auf `claude.ai` aus (oder über eine feste Client-ID).
- **Nur Maries eigene Notizen.** Kampagnen, Gruppen und Notizen, die Marie selbst geschrieben hat. Was andere ihr
  freigegeben haben, gibt es hier nicht. Jede Aktion lädt die Notiz frisch und prüft das erneut, nicht nur beim Auflisten.
- **Versionsschutz.** Jede Notiz hat eine Version (`lastModifiedAt`). Änderungen nennen die gelesene Version;
  hat sich die Notiz inzwischen (z. B. in der App) geändert, wird nichts gespeichert.
- **Freigaben bleiben, wie sie sind** (siehe unten). Neue Blöcke sind privat; nur `freigabe_aendern` ändert Freigaben.
- **Löschen nur mit Bestätigung.** Notizen, Blöcke und Gruppen löschen sowie Freigaben erweitern gehen in zwei
  Schritten: Der erste Aufruf beschreibt die Folgen und gibt einen Code; erst ein zweiter Aufruf mit demselben
  Inhalt und diesem Code führt es aus (10 Minuten gültig, einmal). Eine Gruppe löschen löscht nie ihre Notizen.
- **Logs ohne Inhalte.** JSON-Zeilen nur mit Werkzeugname, IDs, Anzahlen, Status und Dauer. Nie Titel, Texte,
  Bildunterschriften, Prompts, Bilder, Tokens oder Schlüssel. Upload-Links und Query-Strings werden geschwärzt.

## Freigaberegeln

| Aktion | Was mit den Freigaben passiert |
| --- | --- |
| `bloecke_verschieben`, `notizen_zusammenfuehren`, `bloecke_anordnen` | Jeder Block behält ID, Inhalt, Bild und genau seine Leser (Questkeeper verschiebt die Blöcke selbst, nichts wird kopiert). |
| `block_aufteilen` | Jeder Teil bekommt genau die Leser des ursprünglichen Blocks. |
| `bloecke_verschmelzen` | Gleiche Leser bleiben; bei unterschiedlichen (auch Teilmengen) wird der Block **privat**, und die Antwort sagt das. Text und Leser werden in einem Schritt gespeichert. |
| `block_bearbeiten` | Leser bleiben. Nennt Claude Quellblöcke (`verwendeteQuellbloecke`), die nicht jeder Leser sehen darf, wird der Block privat und das gemeldet. |
| `bloecke_hinzufuegen`, `notiz_anlegen`, Bilder | Immer privat. |
| `gesamtdokument_erstellen` | Kopien sind privat; nur mit `freigabenUebernehmen` bekommt jede Kopie genau die Leser ihres Originals. |
| `freigabe_aendern` | Das einzige Werkzeug für Freigaben. Einschränken sofort, Erweitern mit Bestätigung. |

Zusätzlich gibt es ein Sicherheitsnetz gegen versehentliches Abschreiben: Enthält ein Text für einen geteilten
Block wörtliche Passagen (8 Wörter am Stück oder einen ganzen kurzen Block) aus einem Block, den nicht alle Leser
sehen dürfen, wird er abgelehnt. Das erkennt Kopien, keine Umschreibungen; die eigentliche Garantie sind die
Regeln in der Tabelle.

## Werkzeuge

| Bereich | Werkzeuge |
| --- | --- |
| Lesen | `kampagnen_auflisten`, `gruppen_auflisten`, `notizen_auflisten`, `notizen_durchsuchen` (Volltext, `#tags`, Gruppen), `notizen_lesen` (mehrere auf einmal, mit Freigabe je Block) |
| Notizen | `notiz_anlegen`, `notiz_umbenennen`, `notizen_loeschen`, `gesamtdokument_erstellen` |
| Blöcke | `bloecke_hinzufuegen`, `block_bearbeiten`, `block_aufteilen`, `bloecke_verschmelzen`, `bloecke_anordnen`, `bloecke_verschieben`, `block_loeschen`, `notizen_zusammenfuehren` |
| Gruppen | `gruppe_anlegen`, `gruppe_umbenennen`, `gruppe_loeschen`, `notizen_verschieben` |
| Freigaben | `freigabe_aendern` |
| Bilder | `bilder_auflisten`, `bild_ansehen` (als Bild für Claude), `bild_hochladen` (https-Link oder kleines Base64), `bild_upload_link` (Einmal-Link, 15 min), `bild_generieren` (OpenAI) |

Hochgeladene Bilder werden in PNG/JPEG umgewandelt, aufgerichtet und ohne Metadaten (z. B. GPS) gespeichert.
Links werden nur geladen, wenn der Host auf öffentliche Adressen zeigt (kein Zugriff aufs Heimnetz).

## Einrichten auf Unraid

1. **API-Schlüssel (Marie):** In der Questkeeper-App unter **API-Schlüssel** einen neuen Schlüssel erstellen
   mit den Rechten `notes:read`, `notes:write` und `campaigns:read`.
2. **Cloudflare Tunnel:** In Zero Trust → Networks → Tunnels einen neuen Tunnel anlegen (eigener Tunnel, nicht der
   des Backends). Public Hostname, z. B. `notizen.peter-esser.de`, Service `http://questkeeper_mcp:8787`.
   Den Token in `tunnel.env` eintragen.
   - Kein Cloudflare Access davor: Claudes Server können sich dort nicht anmelden. Geschützt ist alles durch OAuth.
   - Falls Bot Fight Mode oder WAF-Regeln aktiv sind: für diesen Hostnamen Anfragen aus Anthropics Netz
     `160.79.104.0/21` durchlassen, sonst scheitern Verbindung oder Anmeldung.
3. **Konfiguration** (im Repo auf dem Server, `applications/questkeeper-mcp`):
   ```bash
   cp mcp.env.example mcp.env && cp tunnel.env.example tunnel.env
   mkdir -p /mnt/disk2/appdata/questkeeper_mcp && chown 99:100 /mnt/disk2/appdata/questkeeper_mcp
   docker compose build
   docker compose run --rm questkeeper_mcp node dist/cli.js passwort-hash
   docker compose run --rm questkeeper_mcp node dist/cli.js totp-geheimnis   # optional
   ```
   Die ausgegebenen Zeilen und `PUBLIC_BASE_URL`, `QK_API_KEY` (und optional `OPENAI_API_KEY`) in `mcp.env`
   eintragen. Das `totp-geheimnis` gibt auch einen `otpauth://`-Link für Maries Authenticator-App aus.
4. **Starten:** `docker compose up -d`. Prüfen:
   ```bash
   curl https://notizen.peter-esser.de/.well-known/oauth-protected-resource/mcp
   curl -i -X POST https://notizen.peter-esser.de/mcp    # 401 mit WWW-Authenticate
   ```
5. **Update:** `git pull`, dann `docker compose up -d --build`.

Die Daten in `/mnt/disk2/appdata/questkeeper_mcp` sind klein: Token-Hashes (`auth-store.json`), der Zähler für
Bildgenerierung und ggf. `abgemeldet-vor`. Verlust heißt nur: Marie meldet sich neu an.

### Bildgenerierung

Optional mit OpenAI (`OPENAI_API_KEY`). Am besten ein eigenes OpenAI-Projekt mit Ausgabelimit anlegen.
`OPENAI_IMAGE_MODEL` (Standard `gpt-image-2.5-flare`) vor dem Start mit der aktuellen Modellliste von OpenAI
abgleichen; `OPENAI_MAX_IMAGES_PER_DAY` (Standard 20) begrenzt die Kosten. Bilder landen privat in der Notiz.

## In Claude verbinden (Marie)

1. Claude → **Anpassen → Konnektoren** (Customize → Connectors) → eigenen Konnektor hinzufügen (Add custom connector).
2. Name „Questkeeper-Notizen“, URL `https://notizen.peter-esser.de/mcp`, **Verbinden**.
3. Es öffnet sich die Anmeldeseite des Servers; sie zeigt, wohin es danach zurückgeht (`claude.ai`).
   Passwort (und ggf. Code aus der Authenticator-App) eingeben → **Anmelden und erlauben**.
4. Im Chat den Konnektor über das Werkzeug-Menü einschalten. Bei Werkzeugen mit Löschwirkung fragt Claude nach.

Falls die Anmeldung scheitert, weil Claude die Client-ID nicht automatisch nutzt: in `mcp.env`
`STATIC_CLIENT_ID=<lange Zufallszeichenkette>` setzen, neu starten und beim Konnektor in den erweiterten
Einstellungen den eigenen OAuth-Client wählen und als Client-ID genau diesen Wert eintragen (kein Secret).

**Abmelden erzwingen** (z. B. Gerät verloren): `docker compose exec questkeeper_mcp node dist/cli.js abmelden`
beendet sofort alle Anmeldungen. Für den Notfall zusätzlich den API-Schlüssel in der App widerrufen.

## Lokal prüfen mit dem MCP Inspector

**Mit Beispieldaten, ohne Backend:**
```bash
npm ci
npm run dev:fake          # http://localhost:8787/mcp, Passwort dev-passwort-123, Client-ID "inspector"
```
- Oberfläche: `npx @modelcontextprotocol/inspector`, Transport **Streamable HTTP**, URL `http://localhost:8787/mcp`.
  In den Authentifizierungs-Einstellungen die Client-ID `inspector` eintragen, dann **Connect**. Es öffnet sich die Anmeldeseite; Passwort `dev-passwort-123`. Danach unter **Tools**
  z. B. `notizen_durchsuchen` mit `suche: Leuchtturm` aufrufen.
- Kommandozeile:
  ```bash
  TOKEN=$(npm run -s dev:token -- http://localhost:8787)
  npx @modelcontextprotocol/inspector --cli http://localhost:8787/mcp --transport http \
    --header "Authorization: Bearer $TOKEN" --method tools/list
  npx @modelcontextprotocol/inspector --cli http://localhost:8787/mcp --transport http \
    --header "Authorization: Bearer $TOKEN" --method tools/call --tool-name notizen_durchsuchen --tool-arg suche=Leuchtturm
  ```

**Gegen ein lokales Backend:** Backend starten (`dotnet run` wie in der Backend-Doku), in der App einen
API-Schlüssel anlegen, dann eine `mcp.local.env` anlegen:
```
PUBLIC_BASE_URL=http://localhost:8787
QK_API_BASE_URL=http://localhost:5214/api/external/v1
QK_API_KEY=<Schlüssel>
LOGIN_PASSWORD_HASH=<aus: npm run build && npm run cli -- passwort-hash>
ALLOW_LOOPBACK_REDIRECTS=true
STATIC_CLIENT_ID=inspector
DATA_DIR=./data
```
und `npm run dev`. Inspector wie oben; für `dev:token` das eigene Passwort als `DEV_PASSWORD` setzen.

**Tests:** `npm test` (Freigaberegeln, Versionen, Löschen in zwei Schritten, Anmeldung, Logs ohne Inhalte,
Link-Schutz) gegen eine nachgebaute Player-API in `test/fakeQuestKeeper.ts`; `npm run typecheck`.

## Technik

- Node 24, TypeScript, `@modelcontextprotocol/sdk` (Streamable HTTP, zustandslos: neuer Server je Anfrage,
  JSON-Antworten). `GET /mcp` antwortet 405.
- OAuth: `/.well-known/oauth-protected-resource[/mcp]` (RFC 9728), `/.well-known/oauth-authorization-server`
  (RFC 8414, `client_id_metadata_document_supported`), `/authorize`, `/token` (PKCE S256 Pflicht, `resource`
  muss dieser Server sein, Codes 5 min und einmalig, `iss` in der Antwort nach RFC 9207).
- Backend-Endpunkte, die dafür dazugekommen sind (Blöcke mehrfach anlegen, Reihenfolge und Verschieben,
  Notizen in Gruppen verschieben, `expectedLastModifiedAt`): siehe [`docs/external-api/notes.md`](../../docs/external-api/notes.md).
- Größen: Antworten von `notizen_lesen` bis etwa 120 000 Zeichen (danach mit `abBlock` weiterlesen), Bildvorschauen
  passen sich daran an. Questkeeper erlaubt 30 Änderungen pro Minute; bei 429 wartet der Server kurz und versucht es erneut.
