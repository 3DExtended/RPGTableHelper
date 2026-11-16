# Einstieg, Charakterbögen und Charaktere, 16.11.2026

Grundlage ist meine Vorschlagsliste nach dem UX-Test ([`ux-test-2026-11-16.md`](ux-test-2026-11-16.md), [`ux-fixes-2026-11-16.md`](ux-fixes-2026-11-16.md)).

- Branch: `claude/onboarding-and-sheets`, ohne Upstream. Noch nicht gepusht und nicht nach `main` gemergt.
- Jeder Punkt hat einen eigenen Commit (15eb9b25 bis aad2e312, 21 Commits). Er wurde getestet, bevor der nächste anfing.
- **Backend:** unverändert. Alle 157 geänderten Dateien liegen in `applications/rpg_table_helper`. Neue Daten (vorbereitete Charaktere, Beispielantworten, Markierungen für den Stufenaufstieg) stehen in der Kampagnen-Konfiguration oder in den Zusatzdaten einer Eigenschaft. Ältere App-Versionen ignorieren diese Schlüssel. Neue Feldtypen gibt es nicht.

## Kurzfassung

- **Umgesetzt:** alle 15 Vorschläge und die 6 Reste aus dem Wiederholungstest.
- **Tests:** grün.
  - 920 Tests ohne Golden-Tests (vorher 797).
  - 444 Golden-Tests. Die Golden-Bilder sind dort neu erzeugt, wo sich Seiten absichtlich geändert haben.
  - `flutter analyze`: 56 Befunde (vorher 58), keiner davon neu.
- **Geprüft:**
  - Alles mit Unit- und Widget-Tests. Neue Ansichten habe ich zusätzlich als Probebild gerendert und angesehen.
  - Im iOS-Simulator habe ich nur die Beitritts-Links geprüft, bei laufender App und beim Kaltstart.
  - Nicht geprüft:
    - ein echter Beitritt über den Link mit angemeldetem Konto gegen einen Server
    - Android
- **Offene Fragen:** 25 Stück, gesammelt am Ende. Am wichtigsten:
  - **(1)** Vorbereitete Charaktere werden nicht als vergeben markiert. Zwei Spieler können also denselben übernehmen.
  - **(2)** Eine alte App (0.9.3) könnte beim Speichern der Konfiguration die vorbereiteten Charaktere verlieren.
  - **(3)** Der QR-Code nützt ohne installierte App nichts.

## Reste aus dem Wiederholungstest

| Commit | Was |
| --- | --- |
| 15eb9b25 | Das Charakterformular öffnet sich nur noch einmal pro Charakter von selbst, nicht bei jedem Besuch, solange ein Wert fehlt. Danach führen die Platzhalter im Bogen zu den fehlenden Feldern. |
| a6103708 | Nur noch eine Bildauswahl pro Charakter. Das Porträt unter „Grundwerte“ erscheint nur, wenn der Bogen keine Bild-Eigenschaft hat. Die Bild-Eigenschaft heißt in beiden Vorlagen „Porträt“, also gibt es in SRD „Aussehen“ nicht mehr doppelt. |
| 0ae4ff67 | Die Spieler-Vorschau hat Beispielwerte auf jedem Tab, nicht nur auf dem ersten. Die erzählerische Vorlage hat eigene Beispielwerte (Erzählpunkte, Aspekte, Stress). |
| 72988f0f | Die Vorlage „Leer“ hat zusätzlich ein Feld „Beschreibung“. |
| e67c1534 | In der Stil-Auswahl haben die Stile Namen: „2 von 9“ und Pfeile statt namenloser Punkte. |
| 027f78ec | Die Texte zum Kampagnennamen passen zur neuen Reihenfolge im Assistenten. |

## Charakterbogen einrichten

| Commit | Was | Geprüft |
| --- | --- | --- |
| 05c595b0 | „Neue Eigenschaft“ fragt zuerst „Was willst du erfassen?“: Lebenspunkte & Vorräte, Attribute, Kennzahlen, Zähler und so weiter. Jeder Zweck nutzt einen vorhandenen Feldtyp. Der Editor zeigt die Eigenschaft live so, wie sie auf dem Bogen erscheint. „Alle Feldtypen“ führt zum alten Weg. | Widget-Tests, Probebilder |
| e13fbe3e | Unter „Fertige Bausteine“ lassen sich Eigenschaften aus den Vorlagen Fantasy 5E und Erzählerisch ankreuzen und gesammelt in den aktuellen Tab übernehmen. Was schon auf dem Bogen ist, wird als vorhanden angezeigt und kann nicht doppelt hinein. | Widget-Tests |
| 0871fa36 | Der Vorlagen-Schritt einer neuen Kampagne bietet auch „Aus einer deiner Kampagnen“. Übernommen wird die ganze Konfiguration, nur der Name bleibt. | Widget-Tests |
| 29130209, 161e80fd | „Neues in der Vorlage“: Ältere Kampagnen bekommen neue oder geänderte Eigenschaften der Vorlage zum Ankreuzen angeboten. Alte englische Tabs („Stats“, „Spells“ …) werden umbenannt, statt einen deutschen Tab daneben anzulegen. Die Werte der Charaktere bleiben erhalten, denn die Eigenschaften behalten ihre IDs. | Tests mit einer echten alten Fantasy-Konfiguration |

## Charaktere anlegen

| Commit | Was | Geprüft |
| --- | --- | --- |
| e99e90db | Optionen wie Klasse, Hintergrund, Fertigkeiten und Zauber erscheinen im Formular als Karten mit Erklärung, wo Platz ist zweispaltig. Lange Texte lassen sich mit „Mehr“ aufklappen. | Widget-Tests, Probebilder |
| ebd4e728 | Beispielantworten erscheinen grau im leeren Feld („z. B. Ein Fischerdorf an der Nordküste …“). Die SL legt sie im Eigenschafts-Editor fest. Alle Textfelder der Vorlagen haben eine. | Widget-Tests |
| 1e0483de | „Schnell starten“ ist die erste Karte der Charakter-Einrichtung. Sie fragt nur Name, Kurzbeschreibung und Porträt ab, der Rest bleibt offen. Sie erscheint nur, wenn sie mindestens drei Felder überspringt. | Widget-Tests |
| e4ab4b97 | „Stufenaufstieg“ im Menü des Bogens erhöht die Stufe und fragt dann Tab für Tab die Eigenschaften ab, die die SL mit „Beim Stufenaufstieg abfragen“ markiert hat. | Widget-Tests |
| 0e436928 | Unter „Vorbereitete Charaktere“ füllt die SL Charaktere vorab aus. Ein Spieler mit leerem Bogen sieht sie über „Schnell starten“ und übernimmt einen davon. | Unit- und Widget-Tests |

## Einstieg

| Commit | Was | Geprüft |
| --- | --- | --- |
| e179f695 | „Erst mal ausprobieren?“ im Dialog „Neue Kampagne“ legt eine Demo-Kampagne an. Sie hat den SRD-Bogen, drei fertige Charaktere der Stufe 1 (Brom, Lyra, Pip) als vorbereitete Charaktere und eine Willkommens-Notiz. Sie öffnet sich ohne Assistenten. Vorbereitete Charaktere haben dazu „Bogen ansehen“ bekommen. | Widget-Test über den ganzen Ablauf. Mit einer absichtlich eingebauten Abweichung (Assistent öffnet sich doch) schlägt der Test fehl, er erkennt sie also. Die Werte der Demo-Charaktere werden gegen den Bogen geprüft. |
| 95c9025d | Der QR-Code unter „Spieler einladen“ enthält `questkeeper://join?code=…`. Mit der Handykamera gescannt öffnet er die App mit dem Beitreten-Dialog, der Code ist schon eingetragen. Das Link-Schema ist in Info.plist und im Android-Manifest registriert. Es gibt kein neues Paket. | iOS-Simulator (iPhone 17 Pro): Bei laufender App fragt iOS „In QuestKeeper öffnen?“, danach kommt der Code an. Beim Kaltstart kommt er ebenfalls an. Keine Routing-Fehler. Android ist nicht geprüft. |
| a8a3767a | Auf dem Handy steht „Charakter auswählen“ über „Kampagne auswählen“, außer jemand leitet nur Kampagnen. Tablets zeigen weiter die SL-Liste zuerst. | Widget-Tests |
| aad2e312 | Auf der Kampagnenseite steht eine Checkliste „Erste Schritte (1 von 3)“: Bogen eingerichtet, Spieler eingeladen, erste Notiz. Jeder offene Schritt hat einen Knopf. Wenn alles erledigt ist, verschwindet sie. Mit „x“ lässt sie sich ausblenden. | Widget-Tests |

## Offene Fragen

Hier stehen Produktentscheidungen, die ich nicht selbst treffen wollte, und bekannte Grenzen.

### Vorbereitete Charaktere und Demo

1. **Doppelte Übernahme:** Ein übernommener Charakter wird nicht als vergeben markiert. Zwei Spieler können denselben nehmen. Soll er nach der Übernahme verschwinden? Die Kampagnen-Konfiguration darf nur die SL schreiben (`updatecampagneconfig` prüft `DmUserId`). Möglich wäre also:
   - eine Änderung am Backend, oder
   - die App der SL entfernt den Charakter, sobald sie ihn bei einem Spieler sieht. Dann bleibt er aber so lange sichtbar, bis die SL die Kampagne geöffnet hat.
2. **Alte App-Versionen:** Die Liste steht unter `preparedCharacters` in der Konfiguration. Speichert eine SL mit der alten App 0.9.3 die ganze Konfiguration, gehen die vorbereiteten Charaktere wahrscheinlich verloren. Bei Spielern passiert das nicht, denn sie speichern keine Konfiguration.
3. **Name:** Beim Übernehmen ersetzt der Name des vorbereiteten Charakters den Namen, den der Spieler beim Beitritt eingegeben hat. Ist das gewollt?
4. **Inventar:** Vorbereitete Charaktere haben kein Inventar und kein Geld, nur Bogenwerte.
5. **Keine echten Beispielspieler in der Demo:** Die Spielerliste der SL zeigt nur Spieler, die wirklich beigetreten sind. Beispielspieler gingen nur mit einer Änderung am Backend, denn Charaktere gehören einem Benutzer. Die Demo zeigt deshalb vorbereitete Charaktere und „Bogen ansehen“.
6. **Sprache:** Die Demo-Charaktere gibt es nur auf Deutsch, wie die SRD-Vorlage.
7. **Demo bleibt:** Kampagnen lassen sich nicht löschen, also bleibt auch die Demo in der Liste. Braucht es „Kampagne löschen“ oder „archivieren“?
8. **Checkliste:** Die Willkommens-Notiz der Demo hakt in der Checkliste „Erste Notiz“ ab.

### Beitritts-Links

9. **Nur eigenes Schema:** Ohne installierte App zeigt die Kamera nur einen Link, mit dem iOS nichts anfangen kann. Besser wären Universal Links (`https://…/join?code=`) mit einer Seite, die zum App Store führt. Dafür braucht es eine Domain mit `apple-app-site-association` und `assetlinks.json` sowie ein Entitlement. Welche Domain soll das sein?
10. **Teilen-Text:** Der Text über „Teilen“ enthält weiter nur den Code und keinen Link. Ein `questkeeper://`-Link ist in vielen Messengern nicht anklickbar, deshalb hängt das an Frage 9.
11. **Android:** Das Manifest ist eingetragen, getestet ist es nicht.
12. **Link in einer Kampagne:** Kommt ein Link an, während jemand in einer Kampagne ist, öffnet sich der Dialog erst, wenn er zurück auf dem Startbildschirm ist. Ein Hinweis fehlt.
13. **Eigener Code:** Scannt eine SL ihren eigenen Code, tritt sie ihrer eigenen Kampagne als Spielerin bei, wie schon bei der Eingabe von Hand.
14. **Beitritt nicht geprüft:** Den vollständigen Beitritt über den Link mit angemeldetem Konto gegen einen Server habe ich nicht durchgespielt. Geprüft ist nur, dass der Dialog mit dem Code aufgeht.

### Charakterbogen

15. **Vorlage aktualisieren:** Alle Änderungen sind vorab angekreuzt. Lieber nur neue Eigenschaften, geänderte Texte aber nicht?
16. **Aus Kampagne übernehmen:** Mitkopiert werden auch Darstellung, Gegenstände und Rezepte. Soll es eine Auswahl geben, etwa „nur den Bogen“?
17. **Bogen teilen:** Einen Bogen als Datei oder Code mit anderen SL zu teilen ist nicht umgesetzt.
18. **Ältere SRD-Kampagnen:** Die Beispielantworten und die Markierungen für den Stufenaufstieg bekommen sie nur über „Neues in der Vorlage“. Die Meldung erscheint deshalb bei allen alten SRD-Kampagnen einmal.
19. **Korrektur:** Ich hatte früher geschrieben, die Varianten-Titel der Stile seien englisch. Das stimmte nicht, sie sind übersetzt.

### Charaktere

20. **Zauber beim Stufenaufstieg:** Markiert sind nur „Zauberplätze gesamt“ und „Zaubertricks“. Sollen auch die bekannten oder vorbereiteten Zauber abgefragt werden?
21. **Tippbare Beschriftungen:** In den Karten und beim Stufenaufstieg lässt sich die Beschriftung nicht antippen, nur die Karte oder das Kästchen.

### Startbildschirm und Checkliste

22. **Startbildschirm:** Auf dem Handy bleibt die Einleitung mit den zwei Weg-Karten auch für wiederkehrende Nutzer über den Listen. Soll sie für sie zusammenklappen?
23. **„Spieler eingeladen“** gilt erst als erledigt, wenn jemand beigetreten ist, nicht schon beim Öffnen von „Spieler einladen“.
24. **Notizen zählen:** Die Zahl der Notizen wird nur beim Laden der Kampagnenseite neu gelesen. Nach der ersten Notiz ist der Haken erst beim nächsten Öffnen da.
25. **Haken „Bogen eingerichtet“:** Er ist nach der Vorlagenwahl immer gesetzt, denn jede Vorlage hat Eigenschaften.

Dazu: „Ausblenden“ der Checkliste gilt nur auf diesem Gerät.

## Nächste Schritte

- Branch nach `main` mergen (oder als PR) und einen TestFlight-Build bauen. Er sollte zusammen mit den neuen Feldtypen aus dem UX-Branch an alle Spieler gehen (siehe `ux-fixes-2026-11-16.md`, „Neue Probleme“, Punkt 1).
- Mit Testern prüfen:
  - Demo-Kampagne als erster Kontakt
  - QR-Scan mit echter Kamera
  - vorbereitete Charaktere mit zwei Spielern (Frage 1)
