# Operatoren

Es gibt viele Operatoren in SQL und noch mehr in unseren Datenbanken, wenn wir eine mit einem erweiterten SQL-Flavour verwenden.

Einige Operatoren auf dieser Seite können in unseren Datenbanken kürzere oder andere Aliase haben. Ich werde mich auf die
Schnittmenge der Operatoren konzentrieren, um es erst einmal einfach zu halten.

Beginnen wir mit den Operatoren, die in allen Datenbanken, die wir verwenden, gleich sind

## Mathematisch

- Addieren `+`
- Subtrahieren `-`
- Dividieren `/`
- Multiplizieren `*`
- Modulo `%`

Du kennst sie wahrscheinlich schon, und ihr seid beste Freunde. Wie in jeder anderen Sprache gibt es sie auch in Sql.

Du musst jedoch beachten, dass Sql wie Java einige Typumwandlungen selbst vornimmt.

Wenn du eine Ganzzahl mit einer Dezimalzahl multiplizierst, erhältst du eine Dezimalzahl. Es gibt einige eingebaute Funktionen und
andere explizite Typumwandlungen, die das ändern können, aber im Moment musst du dich damit abfinden.

```sql
SELECT 1 * 1.0;
-> 1.0

SELECT 5 / 3;
-> 1

SELECT 5 / 2.0;
-> 2.5
```

Alle unsere Datenbanken haben zusätzliche mathematische Operatoren und eingebaute Funktionen wie Quadratwurzel, Absolutwert und mehr.
Sie unterscheiden sich jedoch in der Syntax. Ich werde sie einfach hier verlinken, falls du etwas Spezielles brauchst.

[MySQL](https://dev.mysql.com/doc/refman/8.0/en/numeric-functions.html)
| [SQLite](https://www.sqlite.org/lang_corefunc.html) | [MariaDB](https://mariadb.com/kb/en/numeric-functions/)
| [PostgreSQL](https://www.postgresql.org/docs/9.3/functions-math.html)

## Logisch

### AND/OR

Der Java 'und' (`&&`) Operator wird in sql zu `AND` und der 'oder' (`||`) Operator zu `OR`.

Wir können unsere logischen Prüfungen auch in Gruppen mit geschweiften Klammern zusammenfassen.

``sql
SELECT TRUE UND FALSE;
-> FALSCH

SELECT FALSE ODER (TRUE ODER FALSE) UND TRUE;
-> WAHR
```

**VORSICHT VOR NULL**
Ein Nullwert in einem booleschen Vergleich kann zu ungewollten Ergebnissen führen.

```sql
NULL OR TRUE;
-> WAHR

NULL OR FALSE;
-> NULL

NULL AND TRUE;
-> NULL

NULL UND FALSCH;
-> FALSCH
```

### NOT Schlüsselwort

Das Schlüsselwort not invertiert jeden booleschen Wert. Das ist ähnlich wie das `!` in Java.

```sql
SELECT NOT TRUE;
-> FALSE

SELECT NOT (FALSE UND TRUE);
-> WAHR

SELECT TRUE UND NICHT FALSE;
-> WAHR
```

### Gleichheit

#### EQUAL

Anders als in Java können wir die Gleichheit mit einem einfachen `=` prüfen

````Sql
SELECT 1 = 2;
-> FALSE
```

#### NOT EQUAL

Nicht gleich ist offensichtlich ähnlich wie gleich, aber wir haben hier zwei verschiedene Möglichkeiten.

Mit dem Operator `!=`

```sql
SELECT 1 != 2;
-> WAHR
```

Oder mit dem Schlüsselwort NOT von vorhin

```sql
SELECT NOT 1 = 2;
-> WAHR
```

### IS und Null-Gleichheit

Die Prüfung auf Null ist ein bisschen anders. Unser Problem ist, dass eine Gleichheitsprüfung auf null null zurückgibt.

```sql
SELECT NULL = NULL;
-> NULL
```

An dieser Stelle verwenden wir das Schlüsselwort `is`, das mit dem Schlüsselwort not kombiniert werden kann, um einen `!=` Operator zu ermöglichen

```sql
SELECT NULL IST NULL;
-> WAHR

SELECT NULL IST NICHT NULL;
-> FALSE
```

### Größer und kleiner

Alles, was eine Größe hat, ist größenmäßig vergleichbar. Das gilt für Strings, numerische Werte, Daten und mehr.

Wie in Java haben wir hier die gleichen Operatoren.

- Größer als `>`
- Größer als oder gleich `>=`
- kleiner als `<`
- Kleiner als oder gleich `<=`

```sql
SELECT 'abc' > 'ab';
-> TRUE

SELECT 5 >= 5;
-> WAHR

SELECT 5.0 < 5.01;
-> WAHR

SELECT 5.0 <= 5.0;
-> WAHR
```

### BETWEEN

Außerdem gibt es den Operator between, der überprüft, ob ein Wert zwischen zwei verschiedenen Werten liegt.

Die untere und obere Grenze sind inklusive. Die Reihenfolge spielt keine Rolle.

```sql
~~
WÄHLE 1 ZWISCHEN 0 UND 5;
~~
-> WAHR

SELECT 0 ZWISCHEN 5 UND 0;
-> WAHR

WÄHLE 5 ZWISCHEN 0 UND 5;
-> WAHR
```

Du kannst auch das Schlüsselwort `NOT` verwenden

```sql
SELECT 1 NICHT ZWISCHEN 0 UND 5;
-> FALSE
```

## Textvergleich und Mustervergleich

Oft müssen wir Texte oder Teile von ihnen vergleichen. Unsere Datenbanken bieten uns bereits einige gute Möglichkeiten, dies zu tun.

### LIKE

Der Like-Operator verwendet eine einfache Syntax für den Mustervergleich

- `%` ist ein Platzhalter für mehrere Zeichen
- `_` ist ein Platzhalter für ein Zeichen

`%`Sql
SELECT 'abcdef' LIKE 'abc'; -- (1)
-> FALSE

SELECT 'abcdef' LIKE 'abc%'; -- (2)
-> WAHR

SELECT 'abcdef' LIKE '__c%'; -- (3)
-> WAHR

SELECT 'abcdef' LIKE '%cde%'; -- (4)
-> WAHR

```

1. Wir prüfen, ob der String wie abc ist, aber wir fügen keinen Platzhalter am Ende hinzu
2. Wir prüfen, ob die Zeichenfolge mit abc beginnt. Wir fügen auch einen Platzhalter am Ende hinzu, der auf alle folgenden Zeichen passt.
3. Wir prüfen nur, ob das dritte Zeichen ein "c" ist. Wir fügen auch einen Platzhalter hinzu
4. Wir prüfen, ob die Zeichenkette `cde` mit zwei Platzhaltern enthält

**Hinweis zur Groß- und Kleinschreibung**

In MySQL, SQLite und MariaDB ist der `LIKE` Operator **groß-klein-unabhängig**.

PostgreSQL verwendet `LIKE` für **Groß-/Kleinschreibung unterscheiden** und `ILIKE` für **Groß-/Kleinschreibung nicht unterscheiden**.

### Regex

In MySQL und MariaDB gibt es den REGEXP-Operator. SQLite verfügt ebenfalls über diesen Operator, hat ihn aber nicht
standardmäßig. Wenn er verwendet wird, wird ein Fehler ausgegeben.

PostgreSQL verwendet den Operator `~` für den Regex-Abgleich unter Berücksichtigung der Groß- und Kleinschreibung und `~*` für den Abgleich ohne Groß- und Kleinschreibung.

Bemerkenswert ist auch, dass die Operatoren REGEXP und `~` nicht prüfen, ob die gesamte Zeichenkette mit dem Ausdruck übereinstimmt. Es wird nur
nur auf eine Teilsequenz geprüft.

Die Verwendung ist im Allgemeinen die gleiche.

```sql title="MariaDB und MySQL"
SELECT 'abcdef' REGEXP 'CDE'; -- (1)
-> WAHR

SELECT 'abcdef' REGEXP '[CDE]'; -- (2)
-> WAHR
```

1. Groß- und Kleinschreibung wird nicht berücksichtigt. Wir prüfen, ob die Zeichenkette CDE enthält
2. Groß- und Kleinschreibung wird nicht berücksichtigt. Wir prüfen, ob die Zeichenkette ein `c`, `d` oder `e` enthält.

```sql title="PostgreSQL"
SELECT 'abcdef' ~ 'CDE'; -- (1)
-> FALSE

SELECT 'abcdef' ~* 'CDE'; -- (2)
-> WAHR

SELECT 'abcdef' ~* '[CDE]'; -- (3)
-> WAHR
```

1. Abgleich unter Berücksichtigung der Groß-/Kleinschreibung. Wir prüfen, ob der String `CDE` mit der richtigen Groß- und Kleinschreibung enthält.
2. Abgleich ohne Berücksichtigung der Groß-/Kleinschreibung. Wir prüfen, ob die Zeichenfolge "CDE" enthält.
3. Groß- und Kleinschreibung wird nicht berücksichtigt. Wir prüfen, ob die Zeichenfolge ein "c", "d" oder "e" enthält.
