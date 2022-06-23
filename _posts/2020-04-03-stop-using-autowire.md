---
layout: post
asset-type: post
name: stop-using-autowire
title: Stop Using @Autowire
description: Some reasons why Spring's @Autowire annotation could be considered a code smell.
image: /assets/images/springframework/icon.png
date: 2020-04-03 14:25:00 +02:00
author: John Hearn
tags:
- spring framework
- java

---

The [Spring Framework](https://spring.io/) is one of the most widely used Java frameworks around. There is a lot of great stuff in the Spring eco-system so it's a shame to see its flagship feature, a dependency injection container, being widely misused.

First some history{% marginnote past "Cheesy quote of the day: „*You have to know the past to understand the present.*“ —  Carl Sagan" %}.

Spring has been around since the early-2000s and was conceived as an [antidote](https://www.amazon.com/Expert-One-One-Design-Development/dp/0764543857) to the messy J2EE situation at the time. Its principal (but certainly not its only) attraction was a **strong focus on Inversion of Control** (IoC) and its dependency injection framework emerged amongst a plethora of competing DI containers.

In the beginning we had *bean descriptors* written in XML (best forgotten) and then{% sidenote 2007 "In 2007, apparently." %}, when annotations became fashionable, and driven partly by competing frameworks like PicoContainer and Guice, (much of) the XML was replaced with `@Autowire`.

The strength of `@Autowire` (and, equally, `@Inject`{% sidenote inject "`@Autowire` and the standardised `@Inject` annotations are essentially the same and Spring supports both. I'll consider them as synonyms in this post." %}) is its simplicity: add the annotation and let the framework do the rest.

Even at that time there was a big debate about whether to use constructor or field injection, the former better by design and the latter simpler to apply, but in either case the annotation was required to be present somewhere in the class.

The rather unfortunate consequence of having to add Spring specific code to otherwise clean domain objects was considered a worthwhile trade-off. And since we're using the annotation anyway why not just add it everywhere?

**The annotation is no longer required on constructors and the trade-off is no longer worthwhile**. Nonetheless millions of developers are dragging it into the 2020s needlessly along with its disadvantages.

As an example consider this code:

```java
class MyClass {
    @Autowire private Foo foo;
    @Autowire private Bar bar;

    ...
}
```

This can be converted to the following code without having to do any other changes. Spring will handle it just fine.

```java
class MyClass {
    private final Foo foo;
    private final Bar bar;

    public MyClass(Foo foo, Bar bar) {
        this.foo = foo;
        this.bar = bar;
    }

    ...
}
```

Granted that there are a couple of extra lines of boilerplate code{% sidenote lombok "If this is important to you then consider using [Lombok to generate the appropriate constructor automatically](https://www.baeldung.com/spring-injection-lombok), but note that that has its own trade-offs." %} but there are [strong arguments](https://kinbiko.com/java/dependency-injection-patterns/) why the second option should be preferred and `@Autowire` **should now be considered a code smell**, especially on fields or accessors. This post outlines some of them.

There are also stylistic reasons{% sidenote othereasons "From maintainability issues to the IDE warnings about unassigned fields." %} but I'll skip them here and concentrate on pure, cold engineering. Much of the same reasoning can be applied to the use of the `@Value` annotation as well. The objections can be grouped into two main categories.

Firstly, **it makes it impossible to use the final modifier**. Using the final modifier on fields is an important feature for multiple reasons:

Compilation fails if you have not provided all the necessary dependencies, whereas `@Autowire` fails at runtime. **Compile time guarantees are stronger and safer than runtime testing**, they just are. It’s easier and quicker to fix compilation errors than it is to find runtime bugs. So much magic makes configuration problems really hard to debug at runtime. *You will lose time over this*.

The simple fact that a value cannot change after construction gives **additional assurances about the behaviour of the code** just by looking at it. It explicitly declares intent and can help avoid some very hard to find bugs.

Final fields are [guaranteed to be synchronised](https://www.javamex.com/tutorials/synchronization_final.shtml) between threads. If you don't declare fields final, then you must cover thread-safety by some other means, or accept that you don’t have it.

The JVM adds extra care-taking to non-final fields to ensure [correct memory ordering](https://dzone.com/articles/final-keyword-and-jvm-memory-impact) which is not needed in final fields. Additionally, [there are plans](https://bugs.openjdk.java.net/browse/JDK-8233873) to allow the JIT compiler to aggressively optimise code in the knowledge that a field value will not change, as [currently happens with static final fields](https://shipilev.net/jvm/anatomy-quarks/15-just-in-time-constants/).

That should be enough by itself but there is another major group of objections, namely that it **hides dependencies instead of making them explicit**.

It’s so easy to add an `@Autowire` annotation to a field that the structure of the object graph almost inevitably becomes messy over time and, if not careful, can even lead to hard to maintain [circular dependencies](https://softwareengineering.stackexchange.com/a/12030).

A long list of dependencies in a constructor is a signal that a class has too many responsibilities (violating the [SRP](https://en.wikipedia.org/wiki/Single-responsibility_principle)) but it’s easy for the same number of annotations to go unnoticed inside a class with many fields.

`@Autowired` classes are needlessly harder to test. Either we have to bootstrap the entire framework (see below), make our fields public or use something like Mockito's `@InjectMocks`, a good example of engineering a solution to a problem that can been avoided altogether.

It’s a NullPointerException [waiting to happen](http://olivergierke.de/2013/11/why-field-injection-is-evil/). If you construct an instance outside of Spring then the fields must be public or otherwise initialised using setters, breaking encapsulation. It also means it’s possible to create an object in an invalid state breaking the “make invalid state unrepresentable” advice.

Finally, it unnecessarily ties your code to the Spring framework binaries making migrations between frameworks{% sidenote migrations "Unfortunately I've had to do several over the years: EBJ -> Spring, Spring -> EJB, Spring Boot 1.x -> Spring Boot 2.x 😠" %} and restructuring of the domain much harder. This also applies to `@Service`, `@Component`, etc. which can also be removed but that’s another story.

Having said all that, as always there are some notable exceptions to the general rule.

Autowiring with `@Bean` annotations can (and probably should) be used in Spring configuration classes, which you are likely already using if you're using Spring. In this case `@Autowire` is still mostly unnecessary and again you can keep Spring stuff out of your domain. For example:

```java
@Configuration
static class SomeConfiguration {

    @Bean
    public MyClass myClass(Foo foo, Bar bar) {
        return new MyClass(foo, bar);
    }
}
```

This may be useful if you want to perform some additional configuration and avoids the `@PostConstruct` nonsense. Again, the idea is to keep all the Spring based annotations inside the configurations and outside the domain classes. This way your domain classes will be clean and typically easier to test without the heavy machinery of...

`@SpringBootTest` [automagically](https://www.baeldung.com/spring-boot-testing) uses `@Autowire` to inject fully configured objects into your tests. A suitable constructor would be better but JUnit{% sidenote junit "Another ubiquitous annotation magic wielding library" %} has its limitations. Take for example:

```java
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(classes = ApplicationConfig.class)
public class BigOldServiceTestIT {

  @Autowired private BigOldService service;

  ...
}
```

There are probably more exceptions, there always are. I'll add them as I think of them. On the other had there are definitely more reasons not to, we haven even talked about anaemic domains and good OO design here. That'll be for another post.
