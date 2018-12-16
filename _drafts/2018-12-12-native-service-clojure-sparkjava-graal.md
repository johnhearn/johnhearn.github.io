---
layout: post
asset-type: notes
title: Native Services with Clojure, SparkJava and Graal
description: Combining SparkJava, Graal and Clojure enables us to build dynamic, functional native services..
date: 2018-12-12 23:52:00 +01:00
author: John Hearn

---

```bash
lein new helloworld
```

```clojure
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [com.sparkjava/spark-core "2.7.2"]
                 [org.slf4j/slf4j-simple "1.7.13"]]
```

```clojure
(defn route [handler]
  (reify Route
    (handle [_ ^Request request ^Response response]
      (handler request response))))

(defn get [endpoint routefn]
  (Spark/get endpoint (route routefn)))
```

```clojure
(defn -main []
  (get "/sayHello" (fn [req resp] "Hello World!!")))
```
