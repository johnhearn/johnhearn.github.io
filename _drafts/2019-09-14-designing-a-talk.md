---
layout: post
asset-type: article
name: designing-a-talk
title: Designing a Talk
description: Do a talk at a conference, they said. 
date: '2019-09-14T13:30:00.000+02:00'
author: John
tags:

---

One of the nicest things about working at Codurance is the bi-weekly *catch-ups*. Those of us who are working mainly at client offices go to the Codurance office, meet other Codurancers who we haven't seen for a while, eat together and share our experiences. We also do lightning talks about things that interest us and at the same time get a chance to practice our presentation skills. After doing many of these internal talks, someone said in a peer review that maybe I should take it up a notch and do a talk externally. Always trying to push out of my comfort zone (aka a sucker for punishment) I proposed a talk at the Barcelona Software Crafters conference, with a very short synopsis. 

> How predictable is your code? How predictable is your system, your project or your business? What does it mean to be predictable? Knowing this will help us write better code, create better systems and run better projects and help us understand why agile practices work and when they may not be enough...

To my astonishment it was accepted.

The theme of the talk was clear to me and I had (in my head) a clear narrative to explain. 

- Predictably unpredictable code (traditional complexity metrics)
- Predictably unpredictable systems (Game of Life, deterministic complexity)
- Predictably unpredictable complex adaptive systems (human systems, Systems Thinking and Cynefin)

However, as I tried to nail down the actual slides I realised it wouldn't be as easy as I had anticipated. For one, as I added individual ideas which I wanted to cover I couldn't find a clean, linear arc for the presentation (things seem much cleaner in one's head). What's more, during the research, more and more related topics came up and I couldn't cover them all. And all the while I still had to be true to the original proposal. 

So I wrote down a new possible arc:

- Connection
- Interaction
- Systems
- Adaptation

With this outline I had the same problem, I had simply pivoted what was essientially a two-dimensional idea:

|                 | Code | System | CAS  |
| --------------- | ---- | ------ | ---- |
| **Connection**  | x    | x      | x    |
| **Interaction** |      | x      | x    |
| **System**      |      | x      | x    |
| **Adaptation**  |      |        | x    |

Actually **Interaction** and **System** cover the same points so we can simplify:

|                 | Code | System | CAS  |
| :-------------- | ---- | ------ | ---- |
| **Connection**  | x    | x      | x    |
| **Interaction** |      | x      | x    |
| **Adaptation**  |      |        | x    |

So I can traverse this row-wise or column-wise, top-down or bottom-up, right to left or left to right. I chose column-wise, left-right, top-down. 

- Code - Connection (traditional complexity)
- System - Connection - Interaction (dynamic complexity, Systems Thinking)
- CAS - Connection - Interaction - Adaptation (adaptive complexity, Cynefin)

Wrapping in an introduction and a final section which rewinds the talk, I have the high-level, linear arc I needed.

- Ice breaker (local feedback demo with clapping)

- Introduction

  - drop pen
  - if only we could predict the future (BTTF II)
  - tireless search for predictability doesn't always work
  - raising the bar (Alex Bolboaca)
  - recipies vs principles (Heston Blumenthal)

- Connections in code

  - condition separation (coupling)
  - gilded rose
  - duplicated code
  - **first definition of complexity**
  - common in TDDed code
  - importance of refactoring to reduce implicit connections
  - doing things more than once

- Connections in systems

  - system connections and coupling; [a system is not a tree](https://www.youtube.com/watch?v=ARkLVvtxUZI) (Henney)
  - indirect coupling
  - Relationship between things as well as the things themselves (Mary Poppendick ([here](http://www.leanessays.com/2019/07/grown-up-lean.html)) (The dance as opposed to the dancers) 
  - "dynamic" (Scorpios quote) (monitoring) 

- Interactions in systems

  - self-reinforcing coupling (logging CPU -> scaling -> problems -> logging CPU) 
  - Netflix scale (vizceral screenshot)
  - **second definition of complexity**
  - many failures identified only in retrospect
  - resilience (modularity, redundancy, diversity, anti-fragile)
  - dangers of interfering with such a system (mosquitos, unexpected consequences, cobra effect)
  - Systems Thinking (outside looking in)

  ----

- More interactions in systems

  - pushing complexity: Game of Life and friends
  - **third definition of complexity**
  - emergence; phases
  - in nature (you; weather, on Jupiter, sun spots, three-body problem, galactic filaments;  hexagonal columns, traffic jams, washboarding, ripples, petri dishes, gravity or even time itself)
  - The End of Certainty

- Connections in CASs

  - crowd dynamics (eg. Mecca: "simulation is part but not enough")
  - social systems are another level (families, communities, social networks, cities, countries) -The realm of policy and politics
  - adaptive, independent agents - inside looking out
  - **fourth definition of complexity**

  - predictable irrationality (confirmation bias, success bias, etc.) (computer learns to predict unpredictability)
  - Self-organising (back to **clapping**)
  - Cynefin; decision landscape (mapping), catastrophic fold, disorder domain; pre-scrum
  - agile in complicated or simple domain is wasteful; safe-to-plan
  - predicting things in the complex domain is futile. **Design for serendipity**, deliberate connections, coherent probes and experiments; safe-to-fail
  - Link with OODA, 3X
  - Dancing with systems; future of agility

- Summary

  - Rewind back through different types of complexity

- Questions

TODO: Add more references to where agile practices fit in