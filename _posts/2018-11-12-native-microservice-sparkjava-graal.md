---
layout: post
asset-type: notes
title: Native µservices with SparkJava and Graal
description: By keeping Java simple and avoiding .
date: 2018-11-12 08:52:00 +01:00
author: John Hearn

---

When annotations were introduced to Java people jumped on the bandwagon, as is the wont of the IT industry. Before long we were to a large extent programming with annotations, even to do things that were easy in plain Java. One of the main problems with this is that we end up **adding complexity in an attempt to hide it**. 

One perfect example of this is Spring Mvc / REST framework. Spring allows you to create microservices very easily using a couple of annotations but at the cost of adding a whole eco-system of libraries to your application and an extensive family of Spring specific annotations to your code-base. 

SparkJava takes an another approach. Microservices written in SparkJava are just plain Java code which use a plain Java library. No annotation magic just plain, simple code. The advantage of this simple style of programming is that it is, well, simpler. It's so simple that **the Graal native compiler just compiles it and runs it without batting an eye-lid**. Something which is currently{% sidenote currently "I'm sure that someone will invent another battery of technologies to overcome this problem, a problem that doesn't even need to exist." %} **impossible** with Spring.

This short post shows how easy it is.

First you'll need to install the latest version of the Graal SDK. As of writing this is `1.0.0-rc9`. I did it using SdkMan:
```
sdk install java 1.0.0-rc9-graal
```
And from then on
```
sdk use java 1.0.0-rc9-graal
```

Then create a basic Maven{% sidenote maven "I chose to use Maven because I know it better. I'd like to do it also with Gradle." %} project and add the minimum dependencies:

{% marginnote slf4j-version "It's important that the Slf4j implementation you choose matches the version specified by `sparkjava`. I had trouble when it didn't." %}

```xml
<dependencies>
    <dependency>
        <groupId>com.sparkjava</groupId>
        <artifactId>spark-core</artifactId>
        <version>2.7.2</version>
    </dependency>
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-simple</artifactId>
        <version>1.7.13</version>
    </dependency>
</dependencies>
```

With SparkJava a microservice is crazily simple.
```java
import static spark.Spark.*;

public class HelloWorld {
    public static void main(String[] args) {
        get("/sayHello", (req, res) -> "Hello world!");
    }
}
```

To run it as a command line program it's convenient to copy all the dependencies together into the same directory. We can do that with Maven.
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-dependency-plugin</artifactId>
    <executions>
        <execution>
            <id>copy-dependencies</id>
            <phase>prepare-package</phase>
            <goals>
                <goal>copy-dependencies</goal>
            </goals>
            <configuration>
                <outputDirectory>${project.build.directory}/lib</outputDirectory>
            </configuration>
        </execution>
    </executions>
</plugin>
```

Build the service with Maven and run it to check it works.
```bash
> mvn clean package
```

An run it:
```bash
> java -cp "target/sparkjava-graal-1.0-SNAPSHOT.jar:target/lib/*" HelloWorld
...
[Thread-0] INFO org.eclipse.jetty.server.Server - Started @383ms
```
```bash
> curl localhost:4567/sayHello
Hello World!
```

Let's compile it natively. The command is thankfully very similar to `java`:
```bash
> native-image -cp "target/sparkjava-graal-1.0-SNAPSHOT.jar:target/lib/*" HelloWorld
...
Build on Server(pid: 31197, port: 52737)*
[helloworld:31197]    classlist:   2,142.65 ms
[helloworld:31197]        (cap):   2,154.21 ms
...
...
[helloworld:31197]        write:     443.13 ms
[helloworld:31197]      [total]:  56,525.52 ms
```

And run it:
```bash
> ./helloworld
...
[Thread-2] INFO org.eclipse.jetty.server.Server - Started @2ms
```
```bash
> curl localhost:4567/sayHello
Hello World!
```

The executable is 14Mb but look at that start time! **2ms**, basically instantaneous. 

Memorywise, according to `top` the memory it takes is 7Mb. The `java` version consumes 151Mb (granted without tuning). It would not be wise to pay too much heed to those numbers but it is clear that there is a considerable improvement from removing the JVM from the runtime{% sidenote link "Compare these results with a Go microservice from a [previous post](notes-on-go-go-kit-for-java-programmer.html)." %}. This is especially important in microservices systems where a large number of independent processes are deployed.

Obviously there is a lot more to do to make this a fully functional service but if we choose to keep using simple, static Java code then problems will be minimised. 

The next step will be to convert to Kotlin and then Gradle. That sounds like a very nice combination :)