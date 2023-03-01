# Try with Resources

Try with resources ist ein allgemeines Konzept von Java. Es wird vor allem für IO verwendet und wenn du sicherstellen willst, dass Objekte
auf die richtige Art und Weise abgerissen werden. Du hast es vielleicht schon bei der Verwendung von Input Streams beim Lesen von Daten kennengelernt.

Try with resources kann mit jedem Objekt verwendet werden, das `AutoClosable` ist, also mit jedem Objekt, das `Closeable` ist. Eine Menge
Klassen im Sql-Paket sind Closeable, und es ist auch erforderlich, sie zu schließen, normalerweise mit einigen kleinen
Ausnahmen.

Um dir zu zeigen, wie das geht, werden wir eine kleine Klasse schreiben, die `Closeable` implementiert.

Das Konstrukt von try with resources sieht wie folgt aus:

<!-- @formatter:off -->

```java
try (MyCloseable closeable = new MyCloseable()) {
    closeable.exception();
    return closeable.read();
}
```

<!-- @formatter:on -->

Alle `Closeable` innerhalb der try-Klammer werden geschlossen, sobald die Ausführung die geschweiften Klammern verlässt. Das klingt vielleicht schwer zu
schwer vorstellbar, also schauen wir uns ein wenig Code an.

Innerhalb der try-Klammer müssen keine Objekte erstellt werden. Es geht nur um die Zuweisung. Du kannst auch
mehrere schließbare

<!-- @formatter:off -->

```java
MyCloseable closeable = new MyCloseable();
MyCloseable anotherCloseable = new MyCloseable();
try (closeable; anotherCloseable) {
    closeable.exception();
    return closeable.read();
}
```

<!-- @formatter:on -->

Normalerweise wird die try-Anweisung mit einer catch-Klausel kombiniert, da meistens irgendeine Art von IOException geworfen wird oder
in unserem Fall meist SQLExceptions.

Schauen wir uns an, wie und wann unser Code ausgeführt wird. Dafür brauchen wir eine "AutoClosable"-Klasse. Wir wissen, dass
jedes `Closeable` ein `AutoClosable` ist, also werden wir eine Klasse erstellen, die das implementiert.

```java
class MyCloseable implements Closeable {

    String read() {
        return "Erledigt";
    }

    void exception() throws IOException {
        throw new IOException();
    }

    @Override
    public void close() throws IOException {
        System.out.println("Geschlossen");
    }
}
```

Du siehst, dass wir die Methode `close()` implementieren, die einfach `Closed` ausgibt. Außerdem haben wir eine Methode, die
eine Ausnahme auslöst und eine andere, die einfach einen String zurückgibt.

```java
import java.io.Closeable;
import java.io.IOException;

public class TryWithResources {

    public static void main(String[] args) {
        System.out.println(io());
    }

    public static String io() {
        try (MyCloseable closeable = new MyCloseable()) {
            return closeable.read();
        } catch (IOException e) {
            System.out.println(e);
        }
        return "fehlgeschlagen";
    }
}
```

Ausgabe:

```
Geschlossen
erledigt
```

Wir rufen unsere `io()` Methode auf. Diese Methode erzeugt das Auto-Closable innerhalb der Try-Klammer. Dann rufen wir die read
Methode auf, die die Zeichenkette `Done` zurückgibt. Wenn wir uns unsere Ausgabe ansehen, können wir sehen, dass die close-Methode tatsächlich aufgerufen wird, sobald
die Return-Anweisung ausgeführt wird.

Das Gleiche passiert, wenn anstelle einer Rückgabe eine Ausnahme geworfen wird. Das ist der wichtigste Teil.

```java
import java.io.Closeable;
import java.io.IOException;

public class TryWithResources {

    public static void main(String[] args) {
        System.out.println(ioException());
    }

    public static String ioException() {
        MyCloseable closeable = new MyCloseable();
        MyCloseable anotherCloseable = new MyCloseable();
        try (closeable; anotherCloseable) {
            closeable.exception();
            return closeable.read();
        } catch (IOException e) {
            System.out.println(e);
        }
        return "Fehlgeschlagen";
    }
}
```

Ausgabe:

```
Geschlossen
java.io.IOException
Fehlgeschlagen
```

Hier kannst du sehen, dass selbst wenn eine Ausnahme ausgelöst wird, das `Closeable` geschlossen wird, bevor der Catch-Block bearbeitet wird. Das
bedeutet auch, dass der Catch-Block optional ist und das `Closeable` auch geschlossen wird, wenn wir die Ausnahme nicht abfangen.
Ausnahme nicht abfangen.
