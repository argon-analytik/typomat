# Typomat

<p align="center">
  <strong>Swiss and German typography cleanup for AI-generated text.</strong><br>
  Local macOS Shortcuts and Perl scripts for quotes, dashes, numbers, prices and common LLM typography drift.
</p>

<p align="center">
  <img alt="Platform: macOS" src="https://img.shields.io/badge/platform-macOS-black">
  <img alt="Runtime: Perl" src="https://img.shields.io/badge/runtime-Perl-39457E">
  <img alt="Privacy: local only" src="https://img.shields.io/badge/privacy-local%20only-0A7F42">
  <img alt="No API required" src="https://img.shields.io/badge/API-not%20required-555">
</p>

Typomat bereinigt Texte, die aus ChatGPT, Claude, Gemini, Notion, Google Docs,
Webseiten oder anderen Quellen kopiert wurden. Der Fokus liegt auf typischen
Mischformen: falsche Anführungszeichen, falsche Gedankenstriche, deutsche und
Schweizer Zahlenformate, Preise, Divis/Bis-Striche und Satzzeichenabstände.

Typomat läuft lokal auf dem Mac. Es wird kein Text an eine API, einen Server
oder einen externen Dienst gesendet.

> Typomat als macOS-Kurzbefehl funktioniert nur unter **macOS**, nicht unter iOS
> oder iPadOS. Die Kurzbefehle verwenden die macOS-Aktion
> **Shell-Skript ausführen** mit Perl.

Warum das Projekt existiert: [Typografie ist die Rhetorik der Schrift](docs/essay-typografie-und-ki.md).

## Direkt installieren

Die fertigen macOS-Kurzbefehle können direkt über iCloud hinzugefügt werden:

| Kurzbefehl | Link |
| --- | --- |
| Swiss Typomat | [Kurzbefehl hinzufügen](https://www.icloud.com/shortcuts/0cb78b98b8734bdda6595df4d7b7f326) |
| German Typomat `„…“` | [Kurzbefehl hinzufügen](https://www.icloud.com/shortcuts/86c17cb2263c46ad805a5d9448f1d341) |
| German Typomat `»…«` | [Kurzbefehl hinzufügen](https://www.icloud.com/shortcuts/0c8d49d9a3b44df9ad58645878e86d40) |

Nach dem Hinzufügen müssen in macOS eventuell noch Script- und
Datenschutzberechtigungen erlaubt werden. Die manuelle Einrichtung ist weiter
unten und in [`docs/macos-kurzbefehl.md`](docs/macos-kurzbefehl.md)
dokumentiert.

## Inhalt

- [Direkt installieren](#direkt-installieren)
- [Varianten](#varianten)
- [Beispiele](#beispiele)
- [Was Typomat korrigiert](#was-typomat-korrigiert)
- [Was Typomat schützt](#was-typomat-schützt)
- [Schnellstart im Terminal](#schnellstart-im-terminal)
- [macOS-Kurzbefehl als Schnellaktion](#macos-kurzbefehl-als-schnellaktion)
- [Tests](#tests)
- [Social Assets](#social-assets)
- [Projektstruktur](#projektstruktur)
- [Grenzen](#grenzen)
- [iCloud-Shortcuts](#icloud-shortcuts)

## Varianten

| Script | Sprache/Region | Anführungszeichen | `ß` | Grosse Zahlen | Runde Preise |
| --- | --- | --- | --- | --- | --- |
| [`scripts/swiss-diplomat.pl`](scripts/swiss-diplomat.pl) | Schweiz | `«Text»`, innen `‹Text›` | `ss` | `100'000` | `29.–` |
| [`scripts/german-diplomat.pl`](scripts/german-diplomat.pl) | Deutschland | `„Text“`, innen `‚Text‘` | bleibt `ß` | `100.000` | `29,–` |
| [`scripts/german-guillemets-diplomat.pl`](scripts/german-guillemets-diplomat.pl) | Deutschland, alternativ | `»Text«`, innen `›Text‹` | bleibt `ß` | `100.000` | `29,–` |

## Beispiele

### Swiss-Diplomat

```text
"Grüße" aus dem KI-Text—aber bitte sauber: 100.000 Zeichen. CHF 29,95.
```

wird zu:

```text
«Grüsse» aus dem KI-Text – aber bitte sauber: 100'000 Zeichen. CHF 29.95.
```

### German-Diplomat

```text
"Grüße" aus dem KI-Text—aber bitte sauber: 100'000 Zeichen. 29.95 €.
```

wird zu:

```text
„Grüße“ aus dem KI-Text – aber bitte sauber: 100.000 Zeichen. 29,95 €.
```

### Verschachtelte Anführungszeichen

```text
«Text text «text text» text text.»
```

wird in der Schweizer Variante zu:

```text
«Text text ‹text text› text text.»
```

### Tabellenzellen

```markdown
| Spalte | Wert |
| --- | --- |
| Text—Text | 100.000 |
| 1-2 | 29.-- |
```

wird im Swiss-Diplomat zu:

```markdown
| Spalte | Wert |
| --- | --- |
| Text – Text | 100'000 |
| 1–2 | 29.– |
```

## Was Typomat korrigiert

| Problem | Swiss-Diplomat | German-Diplomat |
| --- | --- | --- |
| Gerade Anführungszeichen | `"Text"` -> `«Text»` | `"Text"` -> `„Text“` |
| Gemischte Anführungszeichen | `„Text“`, `“Text”`, `«Text»` -> `«Text»` | `„Text“`, `“Text”`, `«Text»` -> `„Text“` |
| Verschachtelte Zitate | `«Text «Zitat» Text»` -> `«Text ‹Zitat› Text»` | `„Text „Zitat“ Text“` -> `„Text ‚Zitat‘ Text“` |
| Deutsches Eszett | `Grüße` -> `Grüsse` | bleibt `Grüße` |
| Geviertstrich zwischen Wörtern | `Text—Text` -> `Text – Text` | `Text—Text` -> `Text – Text` |
| Doppelte Bindestriche | `Text--Text` -> `Text – Text` | `Text--Text` -> `Text – Text` |
| Spaced hyphen | `Text - Text` -> `Text – Text` | `Text - Text` -> `Text – Text` |
| Divis ohne Leerzeichen | `text-text` bleibt `text-text` | `text-text` bleibt `text-text` |
| Zahlenbereich | `1-2` -> `1–2` | `1-2` -> `1–2` |
| Auslassungspunkte | `...` -> `…` | `...` -> `…` |
| Satzzeichenabstände | `Text , oder ?` -> `Text, oder?` | `Text , oder ?` -> `Text, oder?` |
| Grosse Zahlen | `100.000` -> `100'000` | `100'000` -> `100.000` |
| Runde Preise | `29.--`, `29.-` -> `29.–` | `29.--`, `29.-` -> `29,–` |
| Preis-Dezimalzeichen | `CHF 29,95` -> `CHF 29.95` | `29.95 €` -> `29,95 €` |

Dezimalzeichen werden bewusst nur in klaren Währungskontexten korrigiert. So
bleiben technische Werte, Code, Versionen und englischsprachige Zahlen möglichst
unangetastet.

## Was Typomat schützt

Typomat ist konservativ. Zweifelhafte Fälle bleiben lieber unverändert, als dass
Code oder technische Angaben beschädigt werden.

Geschützt werden unter anderem:

- Codeblöcke mit dreifachen Backticks
- Inline-Code in Backticks
- eingerückter Markdown-Code
- URLs
- E-Mail-Adressen
- Markdown-Links
- IPv4- und IPv6-Adressen
- Versionsnummern wie `v1.2.3` oder `macOS 15.4.1`
- Datumswerte wie `08.06.2026` und `2026-06-08`
- Dateipfade wie `/Users/demo/project-1.2.3/file.txt`

IPv4-Adressen werden nicht über feste Präfixe wie `192.` erkannt, sondern als
gültige vierteilige Adresse mit Oktetten von `0` bis `255`. Dadurch bleiben
auch `10.0.0.1`, `8.8.8.8` oder `172.16.254.1/24` geschützt.

## Schnellstart im Terminal

Voraussetzung: macOS bringt Perl bereits mit. Es muss nichts installiert werden.

Swiss-Diplomat:

```bash
pbpaste | perl scripts/swiss-diplomat.pl | pbcopy
```

German-Diplomat:

```bash
pbpaste | perl scripts/german-diplomat.pl | pbcopy
```

German-Diplomat mit Guillemets:

```bash
pbpaste | perl scripts/german-guillemets-diplomat.pl | pbcopy
```

Danach liegt der bereinigte Text wieder in der Zwischenablage.

## macOS-Kurzbefehl als Schnellaktion

Die ausführliche Anleitung mit Screenshots liegt hier:
[`docs/macos-kurzbefehl.md`](docs/macos-kurzbefehl.md).

Kurzfassung:

1. In der Kurzbefehle-App unter **Fortgeschritten** die Option
   **Ausführen von Skripten erlauben** aktivieren.
2. Neuen Kurzbefehl erstellen, zum Beispiel **Swiss-Diplomat**.
3. Eingabe aus **Share-Sheet** und **Schnellaktionen** empfangen.
4. Wenn keine Eingabe vorhanden ist: **Zwischenablage abrufen**.
5. Aktion **Shell-Skript ausführen** hinzufügen.
6. Shell auf **perl** stellen.
7. Eingabe auf **Kurzbefehleingabe** und **an stdin** stellen.
8. Script aus [`scripts/`](scripts/) einfügen.
9. Ergebnis mit **Stoppen und ausgeben** als **Shell-Skriptergebnis** ausgeben.
10. In den Details **Im Share-Sheet anzeigen**, **Als Schnellaktion verwenden**,
    **Menü "Dienste"** und **Ausgabe bereitstellen** aktivieren.

<details>
  <summary>Screenshots der macOS-Einrichtung anzeigen</summary>

  <p>
    <img src="docs/assets/macos-shortcut-full.png" alt="Kompletter Aufbau des macOS-Kurzbefehls" width="720">
  </p>

  <p>
    <img src="docs/assets/macos-shortcuts-advanced-settings.png" alt="Kurzbefehle-Einstellungen: Fortgeschritten" width="420">
  </p>

  <p>
    <img src="docs/assets/macos-shortcut-details-settings.png" alt="Kurzbefehldetails für Share-Sheet und Schnellaktion" width="420">
  </p>

  <p>
    <img src="docs/assets/macos-shortcut-privacy-settings.png" alt="Datenschutz-Einstellungen des Kurzbefehls" width="420">
  </p>
</details>

### Verwendung im Alltag

1. Text in einer App markieren.
2. Rechtsklick.
3. **Schnellaktionen** oder **Dienste** öffnen.
4. **Swiss-Diplomat**, **German-Diplomat** oder die Guillemets-Variante wählen.

In manchen Apps ersetzt macOS den markierten Text direkt. In anderen Apps wird
das Ergebnis angezeigt oder in die Zwischenablage gelegt. Wenn eine App das
Ersetzen nicht unterstützt, kopiere den Text zuerst, führe den Kurzbefehl aus
und füge das Ergebnis danach wieder ein.

## Tests

Der Ordner [`examples/`](examples/) enthält einen absichtlich gemischten
Testtext und die erwarteten Ausgaben für alle drei Varianten.

| Datei | Zweck |
| --- | --- |
| [`examples/test-text.md`](examples/test-text.md) | Input mit Zitaten, Tabellen, Preisen, IPs, Code, URLs und Zahlen |
| [`examples/expected-swiss.md`](examples/expected-swiss.md) | erwartete Ausgabe für Swiss-Diplomat |
| [`examples/expected-german.md`](examples/expected-german.md) | erwartete Ausgabe für German-Diplomat |
| [`examples/expected-german-guillemets.md`](examples/expected-german-guillemets.md) | erwartete Ausgabe für German-Diplomat mit Guillemets |

Einzelne Variante testen:

```bash
perl scripts/swiss-diplomat.pl < examples/test-text.md
```

Alle Varianten gegen die erwarteten Ausgaben prüfen:

```bash
./scripts/test.sh
```

Erwartete Ausgabe:

```text
All Typomat tests passed.
```

## Social Assets

Für LinkedIn und andere Social-Posts gibt es ein reproduzierbares Poster und
einen vorbereiteten Beitragstext:

| Datei | Zweck |
| --- | --- |
| [`poster/typomat-linkedin.html`](poster/typomat-linkedin.html) | HTML/CSS-Poster im Swiss Typographic Style |
| [`poster/typomat-linkedin.png`](poster/typomat-linkedin.png) | gerendertes Beitragsbild, `1200 × 1200` |
| [`docs/social/linkedin-post-typomat.md`](docs/social/linkedin-post-typomat.md) | LinkedIn-Beitragstext mit GitHub- und iCloud-Links |

## Projektstruktur

```text
.
├── README.md
├── docs/
│   ├── essay-typografie-und-ki.md
│   ├── macos-kurzbefehl.md
│   ├── social/
│   └── assets/
├── examples/
│   ├── test-text.md
│   ├── expected-swiss.md
│   ├── expected-german.md
│   └── expected-german-guillemets.md
├── poster/
│   ├── typomat-linkedin.html
│   └── typomat-linkedin.png
└── scripts/
    ├── swiss-diplomat.pl
    ├── german-diplomat.pl
    ├── german-guillemets-diplomat.pl
    └── test.sh
```

## Grenzen

Typomat ist ein pragmatischer Textfilter, kein vollständiger Grammatik-Parser.

- Mehrzeilige oder sehr komplex verschachtelte Anführungszeichen können eine
  manuelle Kontrolle brauchen.
- Bindestriche zwischen Wörtern ohne Leerzeichen bleiben absichtlich erhalten,
  weil sie oft echte Divis-Verbindungen sind.
- Sprachliche Bis-Beziehungen wie `Mo-Di` werden nicht automatisch korrigiert,
  weil das Script nicht zuverlässig wissen kann, ob ein Divis oder ein
  Bis-Strich gemeint ist.
- Dezimalzeichen werden nur in klaren Währungskontexten korrigiert.
- Apostrophe in Namen oder englischen Wörtern werden nicht als
  Anführungszeichen behandelt.

## iCloud-Shortcuts

Direkte iCloud-Links zu den fertigen macOS-Kurzbefehlen:

- Swiss Typomat: <https://www.icloud.com/shortcuts/0cb78b98b8734bdda6595df4d7b7f326>
- German Typomat `„…“`: <https://www.icloud.com/shortcuts/86c17cb2263c46ad805a5d9448f1d341>
- German Typomat `»…«`: <https://www.icloud.com/shortcuts/0c8d49d9a3b44df9ad58645878e86d40>
