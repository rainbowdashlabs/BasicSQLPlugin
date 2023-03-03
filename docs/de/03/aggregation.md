# Aggregation

Neben dem Speichern und Lesen von Daten können Datenbanken zahlreiche statistische Aktionen mit unseren Daten durchführen.

Die gebräuchlichsten Operationen sind das Zählen, Minimal-, Maximal-, Summen- und Durchschnittsberechnung von Werten.
Deshalb werden wir uns darauf konzentrieren.
Deine Datenbank hat viel mehr Aggregationen und besonders Postgres ist sehr stark, wenn es um Aggregation geht.

Für diesen Abschnitt werden wir erneut unseren `friend_graph` verwenden.
Um eine sinnvolle Anzahl von Operationen durchführen zu können, müssen wir unserem Graphen weitere Daten hinzufügen.

Außerdem müssen wir einige Daten in unserer Tabelle `money` und `channel_subscription` anlegen, da diese wahrscheinlich irgendwann gelöscht wurde.


<Details>
<summary>Datenerstellung</summary>

<Details>
<summary>Postgres</summary>

```postgresql
INSERT INTO money (SELECT id, ROUND(RANDOM() * 10000) FROM player)
ON CONFLICT DO NOTHING;

INSERT INTO friend_graph
VALUES (1, 2),
       (1, 3),
       (1, 4),
       (4, 2),
       (4, 3),
       (4, 3)
ON CONFLICT DO NOTHING;

INSERT INTO channel_subscription
VALUES (1, 1),
       (1, 2),
       (2, 1),
       (2, 2),
       (2, 3),
       (3, 1)
ON CONFLICT DO NOTHING;
```

</details>


<Details>
<summary>SqLite</summary>

```sqlite
INSERT INTO money
SELECT id, RUND(RANDOM() * 10000)
FROM player
BEI KONFLIKT NICHTS TUN;

INSERT INTO friend_graph
VALUES (1, 2),
       (1, 3),
       (1, 4),
       (4, 2),
       (4, 3),
       (4, 3)
ON CONFLICT DO NOTHING;

INSERT INTO friend_graph
VALUES (1, 1),
       (1, 2),
       (2, 1),
       (2, 2),
       (2, 3),
       (3, 1)
ON CONFLICT DO NOTHING;
```

</details>



<Details>
<summary>MariaDB & MySQL</summary>

```mysql
INSERT IGNORE INTO money (SELECT id, ROUND(RAND() * 10000) FROM player);

INSERT IGNORE INTO friend_graph
VALUES (1, 2),
       (1, 3),
       (1, 4),
       (4, 2),
       (4, 3),
       (4, 3);

INSERT IGNORE INTO channel_subscription
VALUES (1, 1),
       (1, 2),
       (2, 1),
       (2, 2),
       (2, 3),
       (3, 1);
```

</details>


</details>

## Zählen

Zählen ist einer der häufigsten Fälle in SQL.
Normalerweise wollen wir die Einträge zählen, die eine bestimmte Bedingung erfüllen.
Zum Beispiel wollen wir alle Freunde des Spielers mit der ID 2 zählen.
Das ist ganz einfach, denn wir müssen nur die Funktion `count` in einem `SELECT` mit einer `WHERE`-Anweisung aufrufen.
Hier gibt es nicht viel Neues und du wirst das meiste davon wiedererkennen.

```postgresql
-- Wir verwenden hier immer einen Alias, da dies Namenskonflikte bei der Verwendung der Daten in anderen Abfragen vermeidet.
-- Wenn wir keinen Alias setzen würden, hätte die Spalte den Namen der Funktion, die wir aufrufen.
SELECT COUNT(1) AS friend_count
FROM friend_graph
WHERE player_id_1 = 2
   OR player_id_2 = 2;
```

Wir kennen jetzt die Anzahl der Freunde von Spieler zwei, die bei mir mit den oben gezeigten Daten 3 ist.
Das funktioniert doch schon ganz gut, oder?

Aber warum benutzen wir `count(1)`?
Die Eins in unserer Zählung ist einfach ein beliebiger Wert.
Das kann alles Mögliche sein.
Normalerweise verwenden die Leute dort ein "*".
Die 1 hat den Vorteil, dass die Datenbank direkt weiß, dass wir neben den Daten, die wir für unsere `WHERE`-Klausel benötigen, keine weiteren Daten benötigen.
Deshalb bevorzuge ich persönlich immer die Zahl 1.

## Min, Max, Summe und Durchschnitt

Die Aggregate `MIN`, `MAX`, `SUM` und `AVG` (Durchschnitt) funktionieren alle auf die gleiche Weise.
Wähle deine Daten aus und packe die Daten, die du berechnen willst in eine Aggregatfunktion.

Holen wir uns den Mindestwert unserer `money` Tabelle:

```postgresql
-- Denke erneut daran, einen Alias zu verwenden.
SELECT MIN(money) AS min_money
FROM money
```

Der Clou ist, dass wir mehrere Aggregationen gleichzeitig verwenden können, solange wir die gleichen Zeilen aggregieren:

```postgresql
SELECT MIN(money) AS min_money,
       MAX(money) AS max_money,
       AVG(money) AS average_money,
       SUM(money) AS total_money
FROM money
```

Jetzt haben wir wahrscheinlich alle Informationen, die wir für unsere `money` Tabelle brauchen.

## Gruppieren

Nun wollen wir wahrscheinlich nicht immer nur die Einträge in einer Tabelle zählen.
Die Gruppierung ist für Datenoperationen und Aggregationen unerlässlich.
Die Gruppierung fasst alle Einträge zusammen, die in einer bestimmten Spalte den gleichen Wert haben, und ermöglicht die Aggregation der zusammengefassten Spalten.

Damit können wir zum Beispiel zählen, wie viele Kanäle ein Spieler abonniert hat.
Dazu müssen wir nur unsere player_id-Spalte **gruppieren** und **zählen**, wie viele Spieler in jeder Gruppe sind.
Wenn wir das als Abfrage formulieren, sieht es so aus:

```postgresql
SELECT player_id, COUNT(1) AS channel_count
FROM channel_subscription
GROUP BY player_id;
```

| player_id | channel_count |
|:----------|:--------------|
| 3         | 1             |
| 2         | 3             |
| 1         | 2             |

Jetzt können wir sehen, dass Spieler 3 einen Kanal abonniert hat, während Spieler 2 drei Kanäle abonniert hat.
Bei der Gruppierung ist zu beachten, dass du nur die Spalten auswählen kannst, die in deiner `GROUP BY`-Klausel oder in einer Aggregatfunktion wie `SUM` und anderen Dingen erwähnt werden.
Es macht vielleicht keinen Sinn, aber wir könnten zum Beispiel auch die Summe der `channel_ids` zählen.

```postgresql
SELECT player_id, COUNT(1) AS channel_count, SUM(channel_id) AS channel_sum
FROM channel_subscription
GROUP BY player_id;
```

| player_id | channel_count | channel_sum |
|:----------|:--------------|:------------|
| 3         | 1             | 1           |
| 2         | 3             | 6           |
| 1         | 2             | 3           |

Wenn du versuchen würdest, die `channel_id` ohne die Summenfunktion auszuwählen, würdest du einen Fehler erhalten, weil die Datenbank nicht weiß, was sie mit dieser Spalte machen soll.

## Gruppieren mit einem anderen Aggregat

Wenn du mit etwas wie unserem `friend_graph` arbeitest, kann es schwierig sein, alle Freunde eines Spielers zu zählen, da der Spieler in `player_id_1` oder `player_id_2` sein kann.
Leider gibt es keine gute Möglichkeit, sie in einer einzigen `SELECT`-Anweisung zu zählen.
Dafür brauchen wir drei `SELECT`-Anweisungen.
Zwei, um für jede ID zu zählen und eine weitere, um die Zählungen beider Ids zu kombinieren.
Wir verwenden `UNION`, um die beiden Zählungen unserer Abfrage zu kombinieren, die wir in eine Unterabfrage packen und dann die Summe der beiden Spielerzahlen berechnen.
Das ist ein fortgeschrittenes Thema, und wir werden hier noch einige Dinge verwenden, die noch nicht bekannt sind.
Vielleicht kommst du später noch einmal zurück und verstehst es ganz, oder du benutzt es einfach als Referenz, wenn du erneut auf das gleiche Problem stößt.

```postgresql
SELECT player_id_1 AS id, COUNT(1) AS friend_count
FROM friend_graph
GROUP BY player_id_1
-- UNION führt standardmäßig eine Deduplizierung der Einträge durch. Da wir das nicht wollen, verwenden wir ALL, was diesen Schritt überspringt
UNION ALL
SELECT player_id_2 AS id, COUNT(1) AS friend_count
FROM friend_graph
GROUP BY player_id_2
```

Mit der obigen Abfrage erhalten wir dann diese Tabelle:

| id  | friend_count |
|:----|:-------------|
| 4   | 2            |
| 2   | 1            |
| 1   | 3            |
| 3   | 2            |
| 4   | 2            |
| 2   | 2            |

Alles, was wir jetzt noch tun müssen ist, unsere ID zu gruppieren und die Summe der Freundesanzahl zu berechnen.

```postgresql
SELECT id, SUM(friend_count)
-- Dieses Konstrukt nennt man eine Subquery. Anstatt direkt eine Tabelle zu lesen, lesen wir die Ergebnisse einer anderen Abfrage.
FROM (SELECT player_id_1 AS id, COUNT(1) AS friend_count
      FROM friend_graph
      GROUP BY player_id_1
      UNION ALL
      SELECT player_id_2 AS id, COUNT(1) AS friend_count
      FROM friend_graph
      GROUP BY player_id_2) counts -- Dies ist ein Alias für unsere Subquery.
-- Wir gruppieren unsere Einträge
GROUP BY id;
```

Am Ende erhalten wir schließlich unser Ergebnis:

| id  | summe |
|:----|:------|
| 3   | 2     |
| 4   | 4     |
| 2   | 3     |
| 1   | 3     |

Das sind die Gesamtzahlen, die wir haben.
Du hast es noch nicht verstanden?
Mach dir keine Gedanken darüber.
Wenn du es brauchst, kommst du einfach wieder.
