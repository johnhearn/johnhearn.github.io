---
layout: post
asset-type: article
name: more-than-one-kind-of-project
title: There's More Than One Kind of Project
description: Software engineering projects come in many shapes and this article lists some of them. Different skills apply to each one, however, and we need to be able to distinguish them and apply the right tools to each.
date: 2018-10-28 14:09:00 +02:00
author: John Hearn
tags:
- craftsmanship

---

Of the vast number of abstract terms we use as professionals the term **project** comes up very often. It's such a familiar word that maybe we don't stop to think about what it really means. It turns out, as so often is the case, that its meaning depends on the situation and business context{% sidenote context "hmm... maybe we should apply the bounded context principle to our own communication." %}. 

If you are working on an internal team with a particular set of requirements, a particular workflow and particular end date then you probably have a very clear idea of what "project" means in this scenario. For example, "the project has been cancelled" has a very clear meaning.

On the other had if you're working permanently on the company's public crown jewels and the project is cancelled, that probably means a whole different thing. This kind of situation is being called product-mode development and a great deal has been written about this is the last few years. 

I think that the _product vs project_ dichotomy is not the whole story though. There are other modes and each modes benefits from different methodologies, practices and skills. To be clear, these different modes are not down to project mismanagement (although that happens) but mainly to different business scenarios. I'm listing here some of the project modes I have worked on. It's certainly not an exhaustive list. 

## The Centrepiece

This is the software product which defines a company and generates a substantial part of its revenue. In this situation the sales and marketing teams are probably working together with developer teams on identifying the best features using things like A/B testing and maximising returns by rolling out incrementally. 

Features are needed fast and frequent releases are encouraged. This is where many Agile techniques really shine. For example the constant improvement cycles and regular delivery of Scrum help ensure maximum ROI. Anything but the highest level of estimation is a waste. Minimising waist in the deployment cycle is also a major concern so DevOps practices and continuous deployment/delivery make perfect sense.

The best companies realise that quality is a necessity, not just because downtime directly affects business revenue, but also to ensure the sustained pace of development of new revenue generating features. XP practices like TDD and refactoring really do pave the way for faster development. 

This is indeed a product that requires a stable team, a product mindset and considerable funding. It also is the one developers seem talk about most, although I'm not sure how typical this is in the industry at large. Which leads to another mode on the opposite end of the scale.

## The Scramble

Often in nascent startups where sales (or your co-founder) need demoable features as fast as possible (days or even hours). Requirements are vague and unproven but speed is vital. Often a client will want a demo ASAP. Generate it from a template, hack it, it doesn't matter. A single sale or a single new client can make or break a small company. 

Non-functional prototypes are more difficult to sell so the thing should work but bugs are not a problem as long as a happy path hangs together. Any kind of planning or testing are the first things to go out of the window. Unit testing, forget it.

This demo mode is not the sort of situation that many a conscientious software engineer considers attractive however, on the face of it, it would seem to be a good fit. The work has an undeniable business value and the best craftspeople know how to work well and fast due to deliberate practice. They know when rules can be broken and which technology that will get fast results. 

The idea will often be that the code and/or material will be rewritten in the event of a sale but that often doesn't happen. Ironically the best developers are again best placed to ensure the right balance of quality because this kind of project can, if successful, easily become a Centerpiece.

## The Full Monty

It is a reality that some projects have difficulty releasing anything but a near completed product. It may be because of immovable company culture{% marginnote culture "large and established companies have a lot of difficulty with this" %} or it may be a constraint of the product itself. Embedded systems cannot be released before the hardware is developed. Some financial offerings only work if released as a package.

Importantly, these kind of projects probably have a pre-agreed release date. Quality is a concern but the date is often more important to stakeholders so planning and some level of estimation appropriate to the level of certainty needed by the stakeholders is essential. 

This is anathema to most of what we learn within the agile movement but in fact is compatible with the manifesto. Technical work can still be done iteratively or incrementally. Work can almost always be split into vertical slices and prioritised accordingly but it does mean that frequent releases are less important. For this kind of project the requirements are in place but not fully fleshed out so continuous feedback is beneficial. 

The role of the conscientious software engineer here is difficult but the business motivations no less imperative. Again the craftsman should be able to direct his skills to this kind of situation. Soft skills are as important here as anywhere because trade-offs will need to be evaluated. Requirements will change and expectations must be managed.

## The Migration

A variation of the Full Monty but where requirements, apart from some cosmetic tinkering, are completely known beforehand. This has happened several times in my experience when a product is being migrated from a legacy platform to a new one. 

Requirements are fixed but weak, often in the style "must do the same as that one" but domain experts are usually readily available and may even include members of the team which created the original implementation.

I believe, and I have some evidence to support this, that the feedback loops in some Agile methodologies (such as Scrum) can get in the way and slow down such projects, Kanban and [feature based development](http://agilemodeling.com/essays/fdd.htm) (FDD) are better alternatives. The key here is focus and velocity, meaning that the right engineers work where they can be most beneficial.

The craftsman skills are again important for ensuring speed and quality within reasonable timescales.

## The Austin Allegro

The last example is the trusty maintenance mode project. These projects may or may not be passed to "on-going" teams for bug-fixing and minor enhancements. In any case it's probably working well enough for the job it was designed for and may not be touched for months or years. This is the case for many back-office applications and I have no data to back this up but I guess that this type of application constitutes a considerable part of the current software landscape.

Some people enjoy deep knowledge of a legacy product, other find it unexciting. Nonetheless the conscientious software engineer has a place here too. The maintenance of these systems is of vital importance to many organisations and [legacy refactoring](http://amzn.eu/d/iGwYvm4) is a difficult but rewarding skill with great business value.

## Conclusion

As we have seen here there are various types of software project and no one-size-fits-all approach their to development. It seems to me that this is a need of some kind of categorisation which would help us to apply the right tools to the right projects and enable us to communicate more accurately within the community.


