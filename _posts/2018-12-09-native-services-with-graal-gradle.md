---
layout: post
asset-type: post
name: native-services-with-graal-gradle
title: Native µservices with Graal and Gradle
date: 2018-12-09 07:52:00 +00:00
author: John Hearn
description: Moving from Maven to Gradle for the Kotlin/SparkJava. Spoiler it's almost too easy.
image: 
    src: /assets/custom/img/blog/graalvm-banner.png
tags: 
- graalvm
- jvm
- kotlin
- microservices

---

In the [last post](native-kotlin-sparkjava-graal) we built the simplest native microservice in Kotlin with SparkJava and Graal. This time we’ll do the same thing with Gradle instead of Maven.

First we need to add our libraries to the Gradle project, including the Kotlin library dependency (as of writing the version is v1.3.10).

```groovy
dependencies {
    compile "com.sparkjava:spark-core:2.7.2"
    compile "org.slf4j:slf4j-simple:1.7.13"
    compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.3.10"
}
```

And to use the Kotlin compiler plugin again becomes more concise compared to Maven.

```groovy
plugins {
    id 'org.jetbrains.kotlin.jvm' version '1.3.10'
}
```

To copy the resources we can use this task:

```groovy
task copyDependencies(type: Copy) {
    from configurations.default
    into 'build/libs'
    shouldRunAfter jar
}

assemble.dependsOn copyDependencies
```

Build the service with Gradle and run it to check it works.

```bash
> ./gradlew clean assemble
> java -cp "build/libs/*" HelloWorldKt
...
[Thread-0] INFO org.eclipse.jetty.server.Server - Started @363ms
> curl localhost:4567/sayHello
Hello World!
```

Building the native executable is just the same as before.