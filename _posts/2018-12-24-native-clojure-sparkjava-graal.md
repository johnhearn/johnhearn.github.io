---
layout: post
asset-type: notes
title: Native µservices with Clojure, SparkJava and Graal
description: Combining SparkJava, Graal and Clojure enables us to build dynamic, functional style native services.
date: 2018-12-24 11:52:00 +00:00
author: John Hearn

---

Using Clojure to build serve endpoints is an attractive proposition. Services are naturally functional in nature, in fact a service *is* a function. We'll follow the same simple example we used for [Java](native-sparkjava-graal) and [Kotlin](native-kotlin-sparkjava-graal). This is a continuation of those articles but please bear in mind that my Clojure skills do not (yet :) match Java and Kotlin. We start, as you might imagine, with a new project:

```bash
lein new hello-clojure
```

We need to add the dependencies to the main `project.clj` file as well as the name of the main class{% sidenote dashes "Something happened with the dash in the name which became an underscore in some places for some reason." %} that we'll run to start the server:

```clojure
  :dependencies [[org.clojure/clojure "1.9.0"]
                 [com.sparkjava/spark-core "2.7.2"]
                 [org.slf4j/slf4j-simple "1.7.13"]]
  :main hello_clojure.core)
```

Clojure is interoperable with Java but not to the same extent that Kotlin is. To overcome the differences I used a couple of adapters from neat clojure code to Spark's Java classes{% sidenote clojure-spark "I later found a nice [article](https://lispchronicles.com/shortn.html) with a complete service using Clojure and Spark. Their adapters were slightly better than mine so I've incorporated some ideas from that article in what follows." %}. 

```clojure
(ns hello_clojure.core
  (:gen-class)
  (:import (spark Spark Response Request Route)))

(defn route [handler]
  (reify Route
    (handle [_ ^Request request ^Response response]
      (handler request response))))

(defn get [endpoint routefn]
  (Spark/get endpoint (route routefn)))
```

Then we're ready to create the controller which we do from the main method so that it's easy to invoke from the command line. Note also that in the above we used the `gen-class` directive to ensure the main class in the Manifest is correct:

```clojure
(defn -main []
  (get "/sayHello" (fn [req resp] "Hello World!!")))
```

To simplify the generation of the service we can build a self-contained jar using Leiningen. 

```bash
> lein clean && lein uberjar
```

As before, we first check that the service works as normal Java:

```bash
$ java -cp target/hello-clojure-0.1.0-SNAPSHOT-standalone.jar hello_clojure.core
...
[Thread-0] INFO org.eclipse.jetty.server.Server - Started @1033ms
```
```bash
> curl localhost:4567/sayHello
Hello World!
```

Compiling to a native image is as simple as the previous examples with Java and Kotlin.

```bash
> native-image -cp target/hello-clojure-0.1.0-SNAPSHOT-standalone.jar hello_clojure.core
Build on Server(pid: 35646, port: 53994)*
[hello_clojure.core:35646]    classlist:   2,704.82 ms
[hello_clojure.core:35646]        (cap):     909.58 ms
...
[hello_clojure.core:35646]        write:     647.23 ms
[hello_clojure.core:35646]      [total]:  54,900.61 ms
```

And run it:
```bash
> ./helloworld_clojure
...
[Thread-2] INFO org.eclipse.jetty.server.Server - Started @2ms
```
```bash
> curl localhost:4567/sayHello
Hello World!
```

Once again the native binary is roughly 15M but again the start-up time is almost instantaneous. This is a very attractive combination of technologies and worth more investigation.