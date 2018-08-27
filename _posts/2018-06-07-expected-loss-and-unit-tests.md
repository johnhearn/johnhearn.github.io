---
layout: post
asset-type: article
name: expected-loss-unit-test
title: Expected Loss of a Unit Test
description: Exploration of the concept of expected loss as a measure of the effectiveness of a unit testing
date: 2017-06-07 09:18:00 +00:00
author: John Hearn
tags:
- tdd

---

During my explorations of TDD I have found myself reading and hearing all sorts of opinions about its effectiveness. In the extreme cases the polemic is absolute, both camps seem to be 100% convinced of the truth of their views, which, as in other walks of life, is usually a sign that they are seeing the same truth from different perspectives.

In the case of the "[TDD is the minimum in professionality](https://www.researchgate.net/publication/3248924_Professionalism_and_Test-Driven_Development)" vs "[TDD is destroying your design](http://david.heinemeierhansson.com/2014/test-induced-design-damage.html)" debate I'm coming to the (actually obvious) realisation that the underlying truth that both sides are seeing but approaching in different ways is to get Code That Works<sup>(TM)</sup>.

Making the case for the latter point of view it's interesting to read James O Coplien's excellent article "[Why Most Unit Testing is a Waste](http://rbcs-us.com/documents/Why-Most-Unit-Testing-is-Waste.pdf)" (and I recommend that you do if you are interested in the subject). Many of the risks he sees with over-zealous unit testing (and indirectly TDD) I have noticed myself in the field and even mentioned before.

For example, tests with negative value, that is tests which don't directly test any actual business requirement but nonetheless require maintenance, pop up surprisingly regularly. They are avoided only by exercising extreme care during development and need to be actively hunted down after refactoring.

Another, and I think even more pernicious problem with unit tests is that they often trick you into thinking that the code that they cover has indeed been tested. It sounds slightly ridiculous to suggest otherwise but indeed that is the case in many many situations. Tests may cover lines of code but, in any code complex enough to warrant testing then they almost certainly don't cover all possible combinations of input and state, which become very large, very quickly (Coplien talks about trillions of combinations, without exaggeration).

<aside>Hello</aside>

Unit testing is not a silver bullet. Unit tests, along with a large part of the best practices of computer sciences are a tool for making quality software. Quality in this case means low failure rates. However I feel that unit testing has almost single handedly been bearing the burden of the quality measure. Have we forgotten the alternatives?

## Write Code that is Hard to Get Wrong

Programming is communication. Communication between programmer and machine. The more obvious that communication is, the harder it is to make a mistake. Once again this applies generally, not just to code. Simpler communication is less likely to be misunderstood.

A question often asked when starting to write unit tests is: should we write tests for accessor methods? Is a setter method hard to get wrong? It's not impossible but very nearly.

### What's for sure is that sometimes the [*expected loss*](https://en.wikipedia.org/wiki/Expected_loss) of writing a test is much greater that the *expected loss* of **not** writing it.

What does that mean? It means that in terms of time and resources the cost (expected loss) of just writing the test is non-zero, let's say 1 minute, not to mention the cost of executing and maintaining it over time.

On the other hand the cost of NOT writing it is probably near 0, in fact it may actually be 0 if the function was correct all along.

But what if I accidentally write a setter like this?

```java
public void setValue(int value) {
  value = value;
}
```

I have done this maybe once or twice in my professional career so the probability of it happening again is maybe several tens of thousands to one, let's just say 10,000:1 for arguments sake. What's the expected loss? Say it takes half an hour to find the bug and another minute to fix it. The total cost in the statistical sense is *31 minutes * 0.00001* that is to say *186ms*.

So we see the expected loss of not writing this test is a fraction of the expected loss of writing it.

It could also be the case that this error turns into some insidious bug which causes your company to lose millions... the probability of that is so low that the expected loss stays negligible (we could probably estimate that too if you're concerned).

It's a similar concept to pot-odds in poker. Do I play or fold? Check the risk/reward FTW.

Can we reduce the expected loss further? Of course, for example we could try to avoid the setter altogether. It can't go wrong if it doesn't exist. That may or may not be possible but it's a worthy goal.

Another way is to change to a property based language (like Kotlin) or use something like Lombok. In this latter case we have:

```java
@Setter
private int value;
```

This has an even lower expected loss, even when including the overhead of installing Lombok in your IDE.

So this is also why **short methods are good**. Because they're **harder to get wrong and therefore the expected loss is lower**.

A real example. I found myself with a code base with several dozen methods of this type:

```java
public String getValue() {
  if (null == data) {
    return null;
  }
  else {
    return data.getValue();
  }
}
```

Ask ourselves "can this go wrong?" Hardly, it would seem. It's even (mis-)using the weird looking C++ technique to avoid setting data to null accidentally. But actually there were several cases where it did go wrong, the name of the methods did not exactly match, i.e. `getValue()` accessed `data.getVal()`, for example. This caused a mismatch and the corresponding bug. Should all 20 or so of these methods be tested then? Let's first see if we can reduce the expected loss.

First we could try and factor out all that boilerplate using lambdas or something. That could get ugly very quickly. Let's take a step back. It turned out that actually `data` should never be null. It could be null because no earlier checks has been added but that's different. We can ensure that data is never null by making it final and setting it to a non-null value in the constructor. That way we can reduce the above code to a single call to a getter and hence reduce expected loss.

What this shows it that expected loss not only can be reduced by simplifying, it can also be reduced using design by contract. In this case the contract states that "data" cannot be null, a fact that we check once at construction time or even statically in the case of a null-safe language like Kotlin. We thus remove a whole swathe of null checks and additional code. Remember any code has a non-zero expected loss.

We can go further... the new reduced methods are just delegates. If we use Kotlin or Lombok to generate our delegate method there would be no need to write these methods at all, reducing expected loss and completely eliminating the need for testing.

## A Big Mistake

One of the biggest mistakes of the last decade has been the promotion of dynamic typing to production code. Why is dynamic typing so bad? Well, it's not for a toy problem and saves you some actual typing (as in key presses) but it raises expected loss. Why? Because static typing reduces the probability of failure, due to the wrong type of argument, for example... it's harder to get wrong.

## Summing up

The statistical technique of using expected loss is a useful approach to measure software quality. If we are looking for low failure rates in code it may not necessarily make sense to just add more tests, what may be more effective is to reduce the risk by refactoring to simpler code which is harder to get wrong.
