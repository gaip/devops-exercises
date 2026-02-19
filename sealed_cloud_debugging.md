# Sealed Cloud Debugging: Der Postboten-Beweis

Wie man Fehler in einem System findet, in dessen Daten man nicht hineinsehen darf.

## 1. Das Prinzip: Postbote (Umschlag vs. Inhalt)

Stell dir vor, du bist ein **Postbote**.
Die Briefe (Justizdaten) sind **versiegelt**. Du darfst sie niemals öffnen (Payload = "Herr Müller wird angeklagt").
Aber du musst wissen, ob der Brief pünktlich ankam.

*   **Inhalt (VERBOTEN):** Payload. Datenschutz-relevant.
*   **Metadaten (ERLAUBT):** Umschlag. Größe, Gewicht, Zeitstempel, Statuscode.

Du debuggst also den **Zustellprozess**, nicht den Briefinhalt.

---

## 2. Die technische Umsetzung: Die RED-Methode

Wir installieren "Messfühler" (Prometheus), die nur die *Physik* des Systems messen:

1.  **R**ate (Die Menge):
    *   Wie viele Briefe? "100 Requests/Sekunde".
    *   *Nicht:* Wer schreibt wem.
2.  **E**rrors (Die Fehler):
    *   Status? "HTTP 500" (Server kaputt) oder "404" (Nicht gefunden).
    *   *Sicht:* Technischer Fehlercode.
3.  **D**uration (Die Dauer):
    *   Wie lange? "Upload dauert 30 Sekunden".
    *   *Diagnose:* Festplatte voll oder Netzwerk langsam.

---

## 3. Der Trick: Distributed Tracing (Die "Sendungsnummer")

Wenn ein Anwalt sagt: "Mein Upload ging nicht!", fragst du **nicht**: "Was wollten Sie hochladen?" (Inhalt).
Du fragst nach der **Trace-ID** (Sendungsnummer, z.B. `abc-123`).

Diese ID wandert durch alle Systeme:
1.  **Frontend:** Startet `trace-id: abc-123` (Zeit: 0s)
2.  **Backend:** Empfängt `abc-123` (Zeit: 0.1s)
3.  **Datenbank:** Schreibt `abc-123` -> **TIMEOUT** (Zeit: 10s)

**Deine Diagnose:** "Aha, die Datenbank hat einen Timeout bei ID `abc-123`."
**Was du gesehen hast:** Nur Technik.
**Was du NICHT gesehen hast:** Die Akte.

---

## 4. Deine Antwort im Interview (Memorize this!)

> "In der **Sealed Cloud** arbeite ich wie ein Postbote. Ich öffne die Briefe nicht, ich überwache die **Zustellung**.
>
> Ich nutze **Tracing und Metriken** (RED-Methode).
> Ich sehe, dass ein Request mit der ID `abc-123` in der Datenbank einen **Timeout** verursacht oder einen **Fehler 500** wirft.
>
> Damit kann ich das technische Problem lösen (z.B. 'Datenbank ist voll' oder 'Netzwerk ist langsam'), ohne jemals den Namen des Angeklagten oder den Inhalt der Akte gelesen zu haben.
>
> **Datenschutz und effektives Debugging schließen sich nicht aus.**"
