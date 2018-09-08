---
layout: post
asset-type: notes
title: Notes on Go - Go-kit for a Java programmer
date: '2017-11-01T11:38:00.001+01:00'
author: John
tags:
modified_time: '2017-11-01T11:38:08.165+01:00'
blogger_id: tag:blogger.com,1999:blog-525051364647796957.post-755913605831581562
blogger_orig_url: http://john-hearn.blogspot.com/2017/11/notes-on-go-go-kit-for-java-programmer.html
---

We're using a lot of Java/Spring Boot based microservices where I work and the memory footprint is somewhat worrying from a production scalability perspective.

The aim of this experiment is to take some first steps into Go to see if there is potential in exploring Go as an alternative to Java for some microservices. The aim here is take into account factors such as resource consumption, as compared to an identical service implemented in Java, and developer productivity but not not to take into account other factors like developer availability.

One promising Go library to aid in the creation of microservices is [Go kit](https://gokit.io/) . At first glance the simplest example seemed quite complicated. I decided to apply Go kit microservice design decisions to Java to be able to do a direct comparison. Lets take a look at the [simplest example](https://gokit.io/examples/stringsvc.html) from the Go kit website. I'll copy the Go kit article's section headers, comments in the original webpage also apply here. We start with an interface and its implementation.

## Your business logic

```go
type StringService interface {
  sayHi(context.Context, string) (string, error)
}

type stringService struct{}

func (stringService) sayHi(_ context.Context, s string) (string, error) {
  if s == "" {
    return "", ErrEmpty
  }
  return "Hello " + s + "!", nil
}

var ErrEmpty = errors.New("Empty string")
```

The Java version is very similar. Nothing really needs to be said here.

```java
interface StringService {
    String sayHi(String name) throws IOException;
}

static class StringServiceImpl implements StringService {
    public String sayHi(String s) {
        if ("".equals(s)) {
            throw new InvalidArgumentException("Empty string");
        }
        return "Hello " + s + "!";
    }
}
```

## Requests and responses

```go
type sayHiRequest struct {
    S string `json:"s"`
}

type sayHiResponse struct {
    V string `json:"v"`
    Err string `json:"err,omitempty"` // errors don't JSON-marshal, so we use a string
}
```

Java version is almost identical:

```java
static class SayHiRequest {
    String s;
}

class SayHiResponse {
    String v;
}
```

Notice that error handling in Java is done using exceptions, a concept that Go does not have, instead relying on error results in return tuples.

## Endpoints

Go kit provides much of its functionality through an abstraction called an **endpoint**. Now we must construct an instance of this abstraction:

```go
func makeSayHiEndpoint(svc stringService) endpoint.Endpoint {
    return func(ctx context.Context, request interface{}) (interface{}, error) {
        req := request.(sayHiRequest)
        v, err := svc.sayHi(ctx, req.S)
        if err != nil {
            return sayHiResponse{v, err.Error()}, nil
        }
        return sayHiResponse{v, ""}, nil
    }
}
```

We can emulate the Endpoint abstraction with a functional interface in Java.

```java
@FunctionalInterface
interface Endpoint {
    Object func(Object request) throws IOException;
}
```

The use of IOException here is to avoid the need to translate checked exceptions to unchecked ones in the handler code. However, the use of unchecked exceptions would facilitate the use of the Java standard functional library and eliminate the need to specific functional interfaces. We create an instance of the lambda, copying the Go implementation very closely. Error handling is done by exceptions which simplifies the code.

```java
static Endpoint makeSayHiEndpoint(StringService svc) {
    return (req) -> {
        SayHiRequest request = (SayHiRequest)req;
        SayHiResponse response = new SayHiResponse();
        response.v = svc.sayHi(request.s);
        return response;
    };
}
```

## Transports

In the example the service is published as JSON over HTTP.

```java
func main() {
    svc := stringService{}

    sayHiHandler := httptransport.NewServer(
        makeSayHiEndpoint(svc),
        decodeSayHiRequest,
        encodeResponse,
    )

    http.Handle("/sayHi", sayHiHandler)

    log.Fatal(http.ListenAndServe(":8080", nil))
}

func decodeSayHiRequest(_ context.Context, r *http.Request) (interface{}, error) {
    var request sayHiRequest

    if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
        return nil, err
    }
    return request, nil
}

func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
    return json.NewEncoder(w).Encode(response)
}
```

To convert this to Java we're going to use Oracle's built-in HttpServer classes. Since Java does not have a built-in Json serialisation library we'll marshal the JSON with the Gson to provide a realistic comparison.

```java
public static void main(String[] args) throws Exception {
    // ListenAndServe starts an HTTP server on the given port.
    HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);

    // Attach the handler function to the context
    StringService svc = new StringServiceImpl();

    HttpHandler sayHiHandler = HttpTransport.newServer(
        makeSayHiEndpoint(svc),
        simplest_gokit_service::decodeSayHiRequest,
        simplest_gokit_service::encodeResponse
    );
    server.createContext("/", sayHiHandler);
    server.start();
}

static SayHiRequest decodeSayHiRequest(HttpExchange t) throws IOException {
    try(InputStreamReader r = new InputStreamReader(t.getRequestBody())) {
        return new Gson().fromJson(r, SayHiRequest.class);
    }
}

static void encodeResponse(HttpExchange t, Object response) throws IOException {
    try(OutputStream w = t.getResponseBody()) {
        byte[] bytes = new Gson().toJson(response).getBytes();
        t.sendResponseHeaders(200, bytes.length);
        w.write(bytes);
    }
}
```

Again the code is very similar. To emulate the Go kit functionality we add functional interfaces and a method which binds them together to provide the decoder-endpoint-encoder chain. Note that this emulates the entire Go kit library up to this point.

```java
@FunctionalInterface
interface Endpoint {
    Object func(Object request) throws IOException;
}

@FunctionalInterface
interface Decoder {
    Object func(HttpExchange t) throws IOException;
}

@FunctionalInterface
interface Encoder {
    void func(HttpExchange t, Object response) throws IOException;
}

class HttpTransport {
    static HttpHandler newServer(Endpoint endpoint, Decoder decoder, Encoder encoder) {
        return (t) -> encoder.func(t, endpoint.func(decoder.func(t)));
    }
}
```

Run the Go version:

```bash
> go run simplest_gokit_service.go &
> curl -d'{"s":"Donald"}' localhost:8080/sayHi
{"v":"Hello Donald!"}
```

Run the Java version:

```bash
> java -cp .:gson-2.8.2.jar simplest_gokit_service &
> curl -d'{"s":"Donald"}' localhost:8080/sayHi
{"v":"Hello Donald!"}
```

# Middlewares

No service can be considered production-ready without thorough logging and instrumentation.

## Transport logging

```go
func loggingMiddleware(name string, w io.Writer) endpoint.Middleware {
    return func(next endpoint.Endpoint) endpoint.Endpoint {
        return func(ctx context.Context, request interface{}) (interface{}, error) {
            io.WriteString(w, "calling " + name + " endpoint\n")
            defer io.WriteString(w, "called " + name + " endpoint\n")
            return next(ctx, request)
        }
    }
}
```

Here we see the "defer" keyword in action. In Java we use finally: 

```java
static Middleware loggingMiddleware(String name, PrintStream writer) {
    return (next) -> {
        return (request) -> {
            try {
                writer.println("calling " + name + "endpoint");
                return next.func(request);
            }
            finally {
                writer.println("called " + name + "endpoint");
            }
        };
    };
}
```

Once again we create a functional interface to emulate the Go Middleware type:

```java
@FunctionalInterface
interface Middleware {
    Endpoint func(Endpoint next);
}
```

Wiring it up is virtually the same in both languages:

```go
var sayHi endpoint.Endpoint
sayHi = makeSayHiEndpoint(svc);
sayHi = loggingMiddleware("sayHi", os.Stderr)(sayHi)
sayHiHandler := httptransport.NewServer(sayHi, ...
```

And in Java:

```java
Endpoint sayHi = makeSayHiEndpoint(svc);
sayHi = loggingMiddleware("sayHi", System.err).func(sayHi);
HttpHandler sayHiHandler = HttpTransport.newServer(sayHi, ...
```

Run the Go version:

```bash
> go run simplest_gokit_service.go &
> curl -d'{"s":"Donald"}' localhost:8080/sayHi
calling sayHi endpoint
called sayHi endpoint
{"v":"Hello Donald!"}
```

Run the Java version:

```bash
> java -cp .:gson-2.8.2.jar simplest_gokit_service &
> curl -d'{"s":"Donald"}' localhost:8080/sayHi
calling sayHi endpoint
called sayHi endpoint
{"v":"Hello Donald!"}
```

Benchmarking response times would be pointless in this simple scenario. Taking a look the the memory footprint however, without any kind of runtime optimisation, the Java implementation is close to 23Mb while the Go binary runs in a little over 1Mb. This difference by itself would be worth investigating in a system with many microservice instances.

## Conclusions

The Go kit abstractions lend themselves well to composition. It has been possible to recreate the same experience in Java with almost a line for line translation using Java's lambda syntax. The abstractions are quite low level but I can't help feeling that it takes a step too far in terms of developer productivity compared to something like Spring REST Controllers.

On the other hand memory use is many times smaller for the Go binary, as would be expected. I would also expect Java libraries like Spring would bloat the Java version even more.