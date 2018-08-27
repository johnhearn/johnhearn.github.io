---
layout: post
asset-type: article
name: solid-vs-cohesion-and-coupling
title: SOLID Principles, Cohesion and Coupling
description: Some observations about the relationship between well known programming principles
date: 2017-05-15 16:52:00 +00:00
author: John Hearn
tags:
- oop
- programming

---

A few years ago I was given a coding problem as part of a recruitment process for a very well known software consultancy. Fair enough, I thought. Doesn't seem too hard, I thought. A couple of hours and it'll be in the bag.

 I failed the test and was thrown out on my ear with very little ceremony.

 What went wrong? Easy, two things.... Object Oriented Design and TDD skills.

 The solution I submitted had good unit-test coverage, was easy enough to understand, built incrementally, self-documenting, and all the rest it. I'd even go so far as to say it was reasonably well designed by my own pragmatic criteria. It even worked.

 However it did not stand up to scrutiny. A public getter here, a redundant test there, an integration test skulking amongst the unit tests, and that was the end of it. Literal failure.

 How did this happen? I have been doing (or, now it seems, failing to do) OOD for over 15 years. I have read more than many on the subject and worked hard to understand the principles. I am a convert to the cause but somehow my skills still didn't cut the mustard. Likewise TDD. (To my defense, although my day job as technical manager in a bank should expose me daily to these skill sets, it doesn't.)

 So... back to the books (one was recommended to me by the recruiter) and the trusty IDE to hone those skills. This series of posts is to document the journey.

 Back to basics. What is OOD? We all know some textbook examples: a `Car` is a `Vehicle` and has `Wheels`, `Amplifiers` depend on `Speakers`, etc. Choose your metaphor. I'm not here to go over that. I'm interested in the design skills to design good systems and they rarely have anything to do with cars and wheels but rather processors and parsers and formatters and caches and tasks and orders.....

 So lets start with the basic [**SOLID principles** of OOD](https://en.wikipedia.org/wiki/SOLID_%28object-oriented_design%29). There are a million books and internet articles on these principles first proposed in the early 2000s. I don't want to rehash that but rather document some insights I have gained by going back over them and to the skills required to put them into practice. SOLID starts with S....

## S - Separation of responsibilities

A seemingly simple principle and easy to apply, right? Wrong. After going back over the basic definitions, it turns out there is a great deal of subtlety here. Robert C Martin's justification for this principle:

> "If a class has more than one responsibility, then the responsibilities become coupled. Changes to one responsibility may impair or inhibit the class' ability to meet the others. This kind of coupling leads to fragile designs that break in unexpected ways when changed."

... however later he goes on to state,

> "If, on the other hand, the application is not changing in ways that cause the the two responsibilities to change at different times, then there is no need to separate them."

Understanding subtle contradictions like these is actually where the "skill" in OOP lies. Sweeping statements about separation of concerns don't hold if those concerns are so tightly bound that they will always change in tandem. Stated in another way:

> "An axis of change is only an axis of change if the changes actually occur."

Whether or not the changes actually occur may not be immediately apparent or may only become apparent with domain knowledge or driven by testing (a future article) but this will not always be the case. Changes to requirements very often, if not in the majority of cases, affect the design in unexpected ways. Should we design for unexpected changes? There are different schools of thought but in the end experience will be the guide. 

 Lets now jump straight over to the I in SOLID because it has some relevance...

## I - Interface segregation

 An interface specifies a contract, a contract is a single responsibility, or so my logic went. How can an object with multiple interfaces not be implementing multiple responsibilities? I feel to square this circle we should forget the word "responsibility" for a moment and talk about cohesion.

 I have a book called "The Practical Guide to Structured Systems Design" (SSD) written back in 1980 and I feel that many of the concepts explained in that book are as relevant here as they were nearly 40 years ago, and maybe more clearly explained because the world was simpler then.

Cohesion is a measure of the strength of functional relatedness of elements within a module.

Change "module" to "class" and the definition holds for OOD. I contend that "**responsibility**" is giving a name to a set of "**strongly related elements**" or "**stuff which goes together**", in the case of OOD both data and behaviour, grouped by some abstract concept. I had made the mistake of equating responsibility with behaviour. This seems obvious now, which is encouraging because that's what happens when you learn new skills - things seem obvious when they didn't before.

 Now, related elements may certainly have different functional interfaces. An amplifier may have a jack plug socket and co-axial connections but it is nonetheless cohesive and has a single responsibility in that sense.

 Incidentally, the interface segregation principle is also intimately related to the concept of coupling which also elucidates the meaning of this principle. SSD encourages the use of "Narrow (as opposed to broad) connections" to weaken coupling, a concept taken from Yourdon in the 1970s. Essentially **a client depending on a smaller interface has a narrower connection and is therefore less likely to change**.

### The key takeaway is that the **interface segregation principle minimises coupling** while the **single responsibility principle maximises cohesion**.

 For fun, lets look at the other principles in SOLID in terms of cohesion and coupling.

## D - Dependency inversion

 The interface of a class (or interface) must, by definition, be equal to or narrower than its sub-classes (or sub-interfaces). This principle states that, where possible, we should use narrower super-classes rather than broader sub-classes, just what we need to reduce coupling. If a client depends on the narrower (or equal) interface of the super-class rather than the sub-class then that must minimise the coupling. **The farther we go up the class hierarchy the smaller the interface and the lower the coupling**.  If we assume the Liskov principle as well (below) then the interface will always behave as expected. All good. Not much skill involved here..

 Now lets do the O.

## O - Open/closed principle

 Open for extension, closed for modification. Lets put this in terms of cohesion and coupling. In OO we must consider not only public interfaces but protected ones too, that is, the "interface" from classes to their super-classes. Visualise being inside the class "looking up" at the super class: we see everything except the private methods. That interface represents a connection which can be narrow or broad. And we know that **narrow interfaces reduce coupling**.

 So we want restrict that interface, right?

 No so fast. There is another concern and that is how extensible a class is. More extensible classes tend to have broader protected interfaces. The balancing of extensibility with reducing super-class coupling is another **skill** to be learned.

 But wait. The superclass interface can also be modified by overriding methods. It's not actually modifying the source code in the original sense but rather modifying the behaviour as seen by a client.... which leads us finally to L:

## L - the Liskov substitution principle

 Clients are connected to classed not only by their interface defined as methods and data, but also by their behaviour. A kind of semantic coupling. A class can break the contract of the interface of the super-class, which in turn may break a client, which is bad.

That's it for this post. This journey will continue...
  