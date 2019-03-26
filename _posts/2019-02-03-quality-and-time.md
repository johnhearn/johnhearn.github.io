---
layout: post
asset-type: article
name: quality-and-time
title: Quality and Time
description: Digging into the meaning of quality and its relationship with time.
date: '2019-02-03T10:30:00.000+00:00'
author: John
tags:
- semiotics
- quality

---

> *'How long will it take?' asked Edith, totally ignoring his objections. <br>
> ’Do you want it quick, cheap, or good? I can give you any two.'*<br> Arthur C Clarke - the Ghost from the Green Banks

{% marginfigure "good-fast-cheap" "https://upload.wikimedia.org/wikipedia/commons/f/fc/Project-triangle.svg" "One version of the project management [trilemma](https://en.wikipedia.org/wiki/Trilemma#The_project-management_trilemma)" %}
When we talk about quality, what do we mean? I've written before about [quality in a professional setting](the-good-programmer) where it can take on an ethical dimension. This time is going to be more about the definition of quality itself, in particular in its relationship with time. 

Take, for example, the project management triangle. There are multiple versions of this triangle (something I’ll come back to in a moment) but the one I have in mind is the one often labelled **Good-Fast-Cheap** or preferably, in my opinion, the equivalent triplet of constraints **Time-Cost-Quality**. I believe it was an observation used in the manufacturing industry although some say it came from Hollywood but in any case the idea is that you must "*choose two*". A better way of understanding the triangle, in less aphoristic terms, is that, **all other things being equal, an improvement to one will negatively impact either or both of the other two**. 

We see this, of course, throughout the software industry where *time* constraints very frequently have a serious negative impact on both cost and quality. You can practice your skills to be better and faster but that usually means you can ask for more money, increasing *costs*. NASA have different constraints and prefers *quality* over everything else because lives literally depend on it.

Furthermore I'd say one of the main reasons for taking on agile practices is that they offset the effect of time constraints by instead focussing on maximal (estimated-business-)value within a given time interval{% sidenote jeffries "[Quality vs Speed? I Don't Think So!](https://ronjeffries.com/xprog/articles/quality/)" %}, fixing *time* in the multi-variate equation and allowing cost and quality to be managed more effectively. This is the key to ensuring a sustainable project and is seriously undermined if fixed deadlines are imposed without regard for to consequences on cost or quality, in effect pulling the carpet out from under the agile process.

An alternative presentation of the time/quality relationship is that higher quality software is easier to maintain, has fewer bugs and is hence faster to deliver. I haven't seen any data on this but it holds with my experience however only over the medium to long term. Long running projects with many changes over time will inevitably be slowed down by low quality designs and will not be sustainable. This is shown in this quintessential diagram:

{% maincolumn 'assets/images/early-and-sustainable-delivery.png' 'Taken from <a href="http://scrumreferencecard.com/scrum-reference-card/">here</a>, originally credited to <a href="https://twitter.com/RonJeffries">Ron Jeffries</a>' %}

The "weak done" line will result in either slow and fragile changes or, even worse, the need for a rewrite. We must take care that our efforts are providing the maximum value **for the lifetime of the product** and if the project is long running then adjusting for time and cost makes perfect economic sense.

If, however, the project is a short term, low requirement or throwaway project or its **business value is realised only through timely delivery** then we must be prepared to adjust our efforts accordingly.

When discussing these ideas with colleagues some interesting ideas came up.

{% marginfigure "time-scope-cost" "https://upload.wikimedia.org/wikipedia/commons/8/88/Project-triangle-en.svg" "Another version of the project management [triangle](https://en.wikipedia.org/wiki/Project_management_triangle)" %}

The first derailed me slightly because it concerned the definition of the project triangle itself and some preferred the labels **Time-Scope-Cost** defining quality as the overall relationship between them. This is another entry for the compendium of frequently confused ideas. There are multiple variants of the triangle with different perspectives and goals. Definitions of the form **Time-Scope-Cost** (or **Speed-Feature-Cost** and many others) use the concept of *quality* in a much broader sense than the concept of quality as we frequently use it as software engineers in terms of *code* quality or *design* quality{% sidenote ploek "[Code quality isn't software quality](https://blog.ploeh.dk/2019/03/04/code-quality-is-not-software-quality/)" %}, and as used in the sense of sustainable delivery. This is a semantic problem but one to bear in mind with conversations with colleagues. Another thing about these models is the tight relationship between the ideas of features/scope/time and schedule. These are not cleanly separable ideas and leads to some overlap and confusion.

A second point was that not all features are equal. Some features may be known to be fixed in scope and require less maintenance over time, or even be likely to be replaced. If we consider the diagram above on a feature by feature basis it again allows us to adjust or efforts for maximum overall value.

A third point was that quality itself is a [multidimensional measure](https://en.wikipedia.org/wiki/Eight_dimensions_of_quality). This again is a broader and arguably much richer definition of quality than the one used to justify sustainable delivery. Bearing this in mind no doubt will make us better developers.

## Lessons learnt
Providing value through high code and design quality has a **direct and somewhat dynamic relationship with time** and depends on **project length and volatility**. Things to bear in mind in our day to day work.

The compendium of confused terms continues to grow. There are **multiple ways of looking at quality** and it's easy to mix them up. I'll be sure to qualify the word when I use it in the future - if we want to communicate ideas then we must have a shared experience of them. 

Not only are there multiple definitions of quality but, as we discovered, **multiple definitions of the project management triangle**, and even different names for it (the iron triangle, for example). Successful conversations rely on shared experience and it rests on us to understand different perspectives to avoid unproductive misunderstandings.

Many thanks to my colleagues at [Codurance](codurance.com) for their feedback and discussions. Generous and informative as always.