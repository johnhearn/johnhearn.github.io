---
layout: post
asset-type: notes
title: Native Services with Kotlin, Spark and Graal
description: Combining SparkJava, Graal and Kotlin.
date: 2018-11-14 09:08:00 +01:00
author: John Hearn

---

In the [last post](native-sparkjava-graal.html) we built the simplest native microservice with SparkJava and Graal. This time we'll take it a step further and use Kotlin instead of Java.

First we need to add the Kotlin library dependency to the Maven project (as of writing the version is `v1.3.10`).

```xml
<dependencies>
    ...
    <dependency>
        <groupId>org.jetbrains.kotlin</groupId>
        <artifactId>kotlin-stdlib</artifactId>
        <version>${kotlin.version}</version>
    </dependency>
</dependencies>
```

And the Kotlin compiler plugin. This is all taken directly from the [Kotlin documentation](https://kotlinlang.org/docs/reference/using-maven.html).

```xml
<plugin>
    <artifactId>kotlin-maven-plugin</artifactId>
    <groupId>org.jetbrains.kotlin</groupId>
    <version>${kotlin.version}</version>
    <executions>
        <execution>
            <id>compile</id>
            <goals> <goal>compile</goal> </goals>
        </execution>

        <execution>
            <id>test-compile</id>
            <goals> <goal>test-compile</goal> </goals>
        </execution>
    </executions>
</plugin>
```

With Kotlin our crazily simple microservice becomes even simpler.
```kotlin
import spark.Spark.*

fun main(args: Array<String>) {
    get("/sayHello") { req, res -> "Hello World!" }
}
```

Build the service with Maven and run it to check it works.
```bash
> mvn clean package
```
```bash
> java -cp "target/sparkjava-graal-1.0-SNAPSHOT.jar:target/lib/*" HelloWorldKt
...
[Thread-0] INFO org.eclipse.jetty.server.Server - Started @363ms
```
```bash
> curl localhost:4567/sayHello
Hello World!
```

Let's compile it natively. Because it *is* Java, the command is nearly identical to the Java version.
```bash
> native-image -cp "target/sparkjava-graal-1.0-SNAPSHOT.jar:target/lib/*" HelloWorldKt
Build on Server(pid: 53242, port: 51191)
[helloworldkt:53242]    classlist:     783.03 ms
[helloworldkt:53242]        (cap):   2,139.45 ms
...
[helloworldkt:53242]        write:     591.88 ms
[helloworldkt:53242]      [total]:  53,074.15 ms
```

And run it:
```bash
> ./helloworldkt
...
[Thread-2] INFO org.eclipse.jetty.server.Server - Started @2ms
```
```bash
> curl localhost:4567/sayHello
Hello World!
```

The executable is nearly identical in size and startup speed to the Java version, as would be expected since it's effectively the same code.

This is a basic example but the combination of Kotlin for simplicity in implementation, SparkJava for microservice simplicity and Graal for deployment simplicity is a very attractive proposition for microservice development. However I do have some concerns about production use. Mainly if something were to go wrong there is very little information in the public domain to help you out, and still less for this specific combination. On the other hand these are all open source projects so nothing is hidden.

Another limitation is that many libraries simply don't work with Graal. This is not altogether negative because it will encourage us to go back to simple coding practices however you may have a dependency which you can't change and this could cause major hassle. I think the main drawback initially will be reflection driven mapping, whether of the serialisation or ORM variety. The current options here are to use key/value type mappings ([JSON.simple](https://github.com/fangyidong/json-simple), [JsonPath](https://github.com/json-path/JsonPath), etc.) or compile-time annotation processing ([ig-json-parser](https://github.com/Instagram/ig-json-parser)). Both have drawbacks. In spite of railing against annotations earlier I suspect that compile-time annotations (aka code generation) will have a place.