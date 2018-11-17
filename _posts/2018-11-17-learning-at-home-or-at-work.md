---
layout: post
asset-type: article
title: Professionalism - Learning at Work
description: The debate about where to learn your craft focuses on the professional on the one side or the employer on the other. We should be considering their relationship instead and the ethics of that relationship.
date: '2018-11-17T09:30:00.000+02:00'
author: John
tags:
- craftsmanship

---

When any **professional offers their services** for payment then they necessarily enter into a **two-way contract with their client**, either written, verbal or [implied](https://www.rocketlawyer.co.uk/article/implied-terms-of-employment-contract.rl). A written contract would set out the expectations of each party but many times it's partially or completely assumed based on a (hopefully) common understanding. In any case its terms will **vary according to the nature of the work** being undertaken.

The [debate](https://www.youtube.com/watch?v=u-prgMPHcOE) about when the professional software engineer should practice their craft, that is if it should be expected of the [*employer* to provide training](https://www.praqma.com/stories/2who-pays-for-upskilling-soft-developers/) or whether the *professional* should hone his skills outside of working hours, seems to neglect the fact that any expectation that the professional may have of their employer, or the employer of the professional, is **defined by their relationship, not by either individually**.

This is clear if we recognise that a single professional may have multiple relationships simultaneously with different clients, each with their own terms and expectations. The employer likewise, even more so.

We need to talk not not so much about the actors (professionals, clients, employers, etc.) but rather the **expectations and relationships between them**.

For example, if you work as a freelance contractor then, in addition to your time, you will probably be contracted explicitly to provide some kind of **expertise**. It would be inappropriate, i.e. incompatible with your contract, for you to ask for training in that same area of expertise{% sidenote doctor "Image you've privately contracted a doctor to treat some specific condition and he then asks for training. Jikes."%}. If, however, you need to work with some in-house software with which you have no experience and, importantly, **that expertise was not expected of you**, then here too training on the job is fully compatible with your contract.

On the other hand if you work as an employee for a company then you will have been employed with a given set of skills (ascertained by tests or interviews) for a given amount of hours to **fulfil a specific job title**. You would (or should) not be necessarily expected to know things outside this agreement but, on the other hand, your employer has the right to use your working time as they see fit *within that role*. If that includes training then that is completely compatible with your contract, because you were probably not contracted for anything that you didn't already know and **you can even reasonably ask for training** if you believe you need it to be effective in your role. It may also make business sense for you to be given training for motivational reasons.

As a third option, you may also be subcontracted by an agency in which case there are three simultaneous relationships in play:
- you and the end client
- you and the agency
- the agency and the end client

The first is your day-to-day reality but things actually often go wrong when the second and third are not in sync. In my professional career I have been asked by agencies to lie about my expertise to satisfy *their* contract. This is unfortunately quite widespread but in my opinion **totally unethical**{% sidenote ethics "Software codes of ethics [already exist](https://www.computer.org/web/education/code-of-ethics) but no-one seems to pay them the blind bit of notice." %}. Professional ethics in this area is something we should be [seriously addressing as an industry](https://en.wikipedia.org/wiki/Software_engineering_professionalism).

As a last point, **if you enjoy your job**, as I do, and have an interest in developing your skills and professionalism then **you will want to practice and study in you own time**, i.e. outside of any existing professional relationships, to  help you progress **both professionally and personally**. This is *your* decision.

In contrast, I have seen many many examples of so-called professionals using a project as a springboard for new skills. I call this CV-oriented-development and is effectively using someone else's resources for your own personal gain. A professional should not choose a technology for a project because they want to learn it. They should choose it because they know that it will provide **value to their client** and that they can **provide the expertise** to implement it correctly. Similarly, in my opinion it is *unprofessional* (and even unethical, again) to use a technology which will be hard for the client to maintain when you leave and therefore not provide long-term business value, unless, of course, the ramifications have been explained to the client and agreed specifically with them.

In conclusion, software engineers work with many different employers and clients in many different ways. Whether not to study outside of work depends on your own personal circumstances but, in my personal opinion, it is **not a requirement of professionalism** but rather a means for your own professional and personal advancement. On the other hand, your employer does not necessarily have a responsibility to provide you training either unless that same training also provides value to them, which it often does, or because it's part of the contract you have with them, which it often is.


<br>
<br>
<br>

---------

As an aside, the concept of a contract between professional and client can be abstractly modelled in UML by an association class{% sidenote modelling "Here we are using a model as a thinking tool, a kind of *gedankenmodell*, not as a software design." %}. The lengthy description above could be represented visually in a diagram like this:

{% maincolumn "assets/images/contract-as-association.png" "A model of the two-way relationship between the professional and client." %}

It makes explicit the difference between a property and a *quality*, the `Contract` representing the *qualification* of a relationship between two other entities with its own **independent** properties. There is an important distinction between this definition of a contract and the one sometimes used where a [*service provider* defines a contract](https://en.wikipedia.org/wiki/Design_by_contract) which the client must accept and abide by. 

In my experience these kinds of models are underused in the wild, I guess that's maybe because they are seen as slightly awkward to implement in object oriented languages, although they are natural in relational databases. I'd be interested in hearing about more real-world examples."
