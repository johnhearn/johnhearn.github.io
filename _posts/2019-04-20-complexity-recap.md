---
layout: post
asset-type: article
name: complexity-recap
title: Complexity in 5 minutes
description: Systems flourish between the predictable and the chaotic.
date: 2019-04-20 12:00:00 +00:00
author: John Hearn
tags:
- complexity
- cynefin
- systems

---

It seems to be a theme of recent posts to go back over books I read more than two decades ago and realise how they formed an integral part of the way I think today{% sidenote explain "And, by realising where they came from, potentially help me to explain my thoughts to others." %}. 

Another such book was [Artificial Life](https://www.goodreads.com/book/show/2307953.Artificial_Life){% marginfigure artificial-life "https://images.gr-assets.com/books/1335347065l/2307953.jpg" "[Artificial Life](https://www.goodreads.com/book/show/2307953.Artificial_Life) (1992) by [Steven Levy](https://www.goodreads.com/author/show/32131.Steven_Levy) was a summary of the work done by visionaries like [von Neumann](https://en.wikipedia.org/wiki/John_von_Neumann), [Conway](https://en.wikipedia.org/wiki/John_Horton_Conway) and [Langton](https://en.wikipedia.org/wiki/Christopher_Langton) who, sometimes accidentally, studied complexity in simple rule based-systems." %}. 

I read this book when I was a teenager in the early to mid-nineties and I can still remember being awestruck by the ideas inside it. One of which was the [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life){% sidenote game-of-life "Which I was proud to be able to reproduce on my Amstrad CPC. It has now become a popular [programming kata](http://codingdojo.org/kata/GameOfLife/), but at that time was somewhat niche to say the least." %} but the idea that struck me most was that of **complexity**, not just in the everyday sense of *very complicated* but with a new and very special meaning: a type of behaviour **between simple and chaotic** where all the interesting stuff happens. 

Langton invented the λ parameter as a kind of life and death measure of how a simple rule based system evolves. At low values the system might be static or periodic and easy to predict. At high values the system might become chaotic, essentially noise. But at a certain point, if **given the right rules and the right initial conditions, complex patterns *emerge***. In fact it was later proved that some of the rules that he found in the complex region on the [*edge of chaos*](https://en.wikipedia.org/wiki/Edge_of_chaos) were exactly those that turned out to be Turing complete, that is able to reproduce any tractable computation.

Stephen Wolfram (the creator of the Mathematica) a few years later published a mighty tome on this subject. [A New Kind of Science](https://en.wikipedia.org/wiki/A_New_Kind_of_Science){% marginfigure artificial-life "assets/images/complexity/nks_cover.jpg" "[A New Kind of Science](https://www.goodreads.com/book/show/238558.A_New_Kind_of_Science) (1997) by [Stephen Wolfram](https://www.goodreads.com/author/show/139599.Stephen_Wolfram) a rather hefty and laborious read." %}, much of which based on his own [experiments](https://www.stephenwolfram.com/publications/academic/universality-complexity-cellular-automata.pdf) performed in the 80s and his laborious work on a certain kind of one-dimensional cellular automata. 

Wolfram [classified his results](https://en.wikipedia.org/wiki/Cellular_automaton#Classification) into [4 separate behaviours](https://www.wolframscience.com/nks/p231--four-classes-of-behavior/), very similar to those rediscovered by Langton in his artificial life experiments.

![Classes of Cellular automa](/assets/images/complexity/langton_lambda2.png)

Class 1 and class 2 are the fixed and cyclic phases, class 3 chaotic and noisy and class 4 the interesting complex behaviour, which again is where the Turing complete rules can be found.

This is a different way of looking at not only science, but also the way we study any non-trivial system, from which the world, as it turns out, is mostly constituted. Reductionist analysis is not always enough.

Fast-forward to today and we have learnt, and are continuing to learn, how, not only we are surrounded by these kinds of systems, in fact, we are part of them. 

Researchers are discovering how ants, bird flocks, social networks, biological reactions and any number of other phenomena display [complex behaviours through self-interactions](https://www.quantamagazine.org/emergence-how-complex-wholes-emerge-from-simple-parts-20181220/). It turns out that we live and work within complexity everyday. Society itself sometimes appears chaotic but emergent patterns persist. Our built-in human behaviours{% sidenote dunbar-number "For example, [Dunbar's number](https://en.wikipedia.org/wiki/Dunbar%27s_number)." %} seem to keep us in the sweet spot. Once again these phases{% sidenote phase-transitions "There has always been much [debate](https://arxiv.org/pdf/adap-org/9303003.pdf) about whether the different states really do represent *phases*, in the same way as the phases of matter, for example. Recent [research](https://www.quantamagazine.org/beyond-the-bell-curve-a-new-universal-law-20141015/) is providing some interesting insights." %} emerge spontaneously, and complex behaviour flourishes between the predictable and the chaotic.

At about the same time that Wolfram was publishing his book, [Dave Snowden](https://cognitive-edge.com/our-people/dave-snowden/) was creating the [Cynefin Framework](https://cognitive-edge.com/videos/cynefin-framework-introduction/) which draws on complexity as a means to help decision making. As we might expect, the framework has a landscape with essentially the same 4 classes (or *domains*), with the addition of *disorder* in the middle where there is simply confusion:

![Cynefin Framework](https://upload.wikimedia.org/wikipedia/commons/1/15/Cynefin_as_of_1st_June_2014.png)

Each domain in this framework has a set of techniques and methods which can be applied on a contextual basis. There is a clockwise drift associated with improved methods and experience and a counter-clockwise drift when knowledge is lost.

Interesting, [according to Snowden](https://www.youtube.com/watch?v=l4-vpegxYPg), agile organisations tend to be constantly on the transition between complex and complicated, in fact this is necessarily so: complex systems are where the interesting things happen but they are also unpredictable. Agile practices try to pull pieces from the complex domain, back into the complicated domain, or even into the obvious one, so that it can be treated in a single, small step, played-out and evaluated. This is what agility means.

Some algorithms are complicated and remain complicated. Machine learning is an example. This is the realm of the experts who can apply learned good practice and know when those practices may or may not be suitable.

Sometimes, however, the simplest projects are situated in the obvious phase already where simple "plan-act-verify" techniques (e.g. waterfall) are perfectly adequate and systematic best practices are possible.

So, from the Game of Life to the Cynefin framework we have seen how systems theory and, in particular, complexity help understand the world around us. Reductionist and one-size-fits-all arguments, pervasive in our industry, don't always hold. The landscape that this provides us helps (me at least) map out and simplify the complex systems in which we find ourselves, including in our everyday lives and the projects we work on, and respond in an appropriate, non-dogmatic way.
