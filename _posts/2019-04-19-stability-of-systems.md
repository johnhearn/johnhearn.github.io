---
layout: post
asset-type: article
name: stability-of-systems
title: The Stability of Systems
description: A quote from an ecologist regarding the stability of ecosystems could also apply to software systems.
date: '2019-04-19T11:30:00.000+00:00'
author: John
tags:
- complexity
- systems
- cynefin

---

I recently read this in a popular science magazine:

> *If a system is to persist rather than to collapse in the face of change, it needs to be robust. **Three features** make an ecosystem, or a planetary system, more robust, says ecologist Simon Levin at Princeton University. 
> First, robust systems have some degree of **redundancy**, so the loss of any particular component - the extinction of a species, say, - doesn't critically compromise the whole.
> Second, they have **diversity**, which increases the odds that at least some species will be able to cope with unexpected change.
> Third, they have **modularity**, so that failure of part of the system doesn't bring down the whole thing.* - The Goldilocks Planet - New Scientist (23 March 2019)

These principles seem to be quite applicable to any complex system, including distributed software systems. In particular, when I read that quote, I immediately thought of Netflix and its well publicised techniques for making their platform reliable in the face of infrastructure problems.

In the above quote, the ecologist talks about robust systems but, technically, the terms **robustness** and **resilience** have different meanings in this context, *robustness* being strength to bear additional load and *resilience* the ability to adapt and respond in the face of changing external factors. The looser, everyday meanings of these words mean that authors (myself included) are liable mix these two concepts even though each play separate roles in a stable system.

Bear in mind that here we are talking about the stability of an entire system, not any particular component, and certainly not the robustness of any individual component. Having said that, systems principles tend to be fractal in nature, applicable at different scales simultaneously, so similar techniques which hold at a system level may also be applicable at component level too.

Let's take a quick look at each of the principles from the quote in terms of software. 

### Redundancy

A distributed software system must be able to take unplanned peaks in load which arise from unexpected changes in the environment like a viral link or, more commonly, the outage of another component. Auto-scaling (a kind of latent redundancy) can help cope with changing load over minutes or hours but sudden peaks require continuous redundancy to avoid service degradation. By intentionally building redundancy into their infrastructure, Netflix [routinely](https://www.networkworld.com/article/3178076/why-netflix-didnt-sink-when-amazon-s3-went-down.html) [survives](https://www.computer.org/publications/tech-news/research/realizing-software-reliability-in-the-face-of-infrastructure-instability) AWS outages, even though it runs entirely on AWS. 

Similarly, if there is a single design principle behind most if not all distributed systems then it is to have [no single point of failure](https://en.wikipedia.org/wiki/Single_point_of_failure). If a entire systems depends on one particular part of the system to be present then the system is not resilient at all{% sidenote bus-factor "In a similar vein, for organisations and projects we have the [bus factor](https://en.wikipedia.org/wiki/Bus_factor), where an endeavour might fail because of the loss of one or more of its members." %}.

A risk-based design approach really comes into its own here.

### Diversity

What happens when Netflix's personalised recommendations services can't take the load? They fallback to simpler recommendation services or generic suggestions. The user may not even notice the difference and, even if they do, it's much better than the alternative. Netflix's [Hystrix](https://github.com/Netflix/Hystrix) fault tolerance library{% sidenote resilience4j "See also [resilience4j](https://github.com/resilience4j/resilience4j)." %} provides timeout and the circuit breaker mechanisms but without diversity there is no alternative to fall back to.

This is reminiscent of the idea that, in some circumstances, the same or similar services could be written for and run on multiple platforms at the same time. This might sound odd to many engineers but this approach would be justifiable if the [risk to the business](https://en.wikipedia.org/wiki/Expected_loss) of an outage, whatever the [MTTR](https://blog.fosketts.net/2011/07/06/defining-failure-mttr-mttf-mtbf/), is greater than cost of adding and maintaining more diversity.

### Modularity

Modularity, and the related concept of minimising coupling, has been the basis of many, if not most, good design practices for decades. A change in one module should have minimum affect on another, either directly (dependency) or indirectly (shared assumptions). Remember the [three tenets](https://www.youtube.com/watch?v=AJW2FAJGgVw) of modularity: strong encapsulation, well-defined interfaces, and explicit dependencies, all of which are ultimately related to managing coupling. And, of course, the best kind of coupling between modules is no coupling at all, in other words, total isolation.

### Conclusion

Famously, Netflix uses [Chaos engineering](https://en.wikipedia.org/wiki/Chaos_engineering) to test the stability of their systems by deliberately applying selective, or even mass outages. Similarly, the article from which the quote above is taken suggests that extinctions, or even mass extinctions, in Earth's past have actually made its ecosystem more stable. Of course there are other ways we can increase the stability of complex software systems, or even organisations, but it is nonetheless interesting to see the similarities between distributed software and natural ecosystems. 

I think the principles underlying these ideas are actually applicable to any complex system.  Consider how they are represented in more sophisticated design frameworks like systems thinking, Cynefin and risk-based decision making. And better ways of thinking about resilience will take us into [Anti-fragility](https://en.wikipedia.org/wiki/Antifragile) and related ideas.

There is certainly a great deal to learn in this area. 

