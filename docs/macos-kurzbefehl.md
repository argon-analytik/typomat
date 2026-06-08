# macOS-Kurzbefehl einrichten

Diese Anleitung beschreibt, wie du einen Typomat-Diplomat in der Kurzbefehle-App
als Schnellaktion einrichtest.

## 1. Neuen Kurzbefehl erstellen

1. Öffne **Kurzbefehle**.
2. Erstelle einen neuen Kurzbefehl.
3. Benenne ihn zum Beispiel **Swiss-Diplomat** oder **German-Diplomat**.

## 2. Eingabe konfigurieren

Der Kurzbefehl soll markierten Text aus Apps übernehmen können.

1. Öffne die Details des Kurzbefehls.
2. Aktiviere **Als Schnellaktion verwenden**.
3. Aktiviere **Share-Sheet** und **Schnellaktionen**.
4. Stelle **Wenn es keine Eingabe gibt** auf **Zwischenablage abrufen**.

## 3. Shell-Skript-Aktion hinzufügen

![Kurzbefehle-App mit Shell-Script-Aktion](assets/macos-shortcut-shell-script.png)

1. Füge die Aktion **Shell-Skript ausführen** hinzu.
2. Wähle als Shell **perl**.
3. Stelle **Eingabe** auf **Kurzbefehleingabe**.
4. Stelle **Eingabe übergeben** auf **an stdin**.
5. Lasse **Als Admin ausführen** ausgeschaltet.
6. Kopiere den Inhalt des gewünschten Scripts aus `scripts/` in die Aktion.

## 4. Ergebnis ausgeben

Füge am Ende die Aktion **Stoppen und ausgeben** hinzu.

Als Ergebnis wählst du **Shell-Skriptergebnis**.

## 5. Script-Ausführung erlauben

Falls macOS das Script blockiert:

1. Öffne die Einstellungen der Kurzbefehle-App.
2. Wechsle zu **Fortgeschritten**.
3. Aktiviere **Ausführen von Skripten erlauben**.
4. Optional: Aktiviere **Teilen grosser Datenmengen erlauben**.

## 6. Benutzung

1. Markiere Text.
2. Klicke mit der rechten Maustaste.
3. Wähle **Schnellaktionen** oder **Dienste**.
4. Starte den gewünschten Diplomat.

Nicht jede App erlaubt das direkte Ersetzen von markiertem Text. Wenn es nicht
klappt, kopiere den Text zuerst, führe den Kurzbefehl aus und füge das Ergebnis
danach wieder ein.
