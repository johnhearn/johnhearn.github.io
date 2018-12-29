---
layout: post
asset-type: article
name: serverless-is-the-new-mainframe
title: Serverless is the new Mainframe
description: Many of the touted advantages of serverless architectures have been enjoyed on Mainframes for decades. What lessons can be learnt for the new serverless era?
date: '2018-12-29T11:00:00.000+00:00'
author: John
tags:
- serverless

---

“Serverless” is the new buzzword with industry voices hailing it as the next paradigm shift. Of course it's marketed as a silver bullet (like any commoditised product) and its superior pricing model will “transform” the sector. That may be true but nonetheless it's interesting to note the similarities{% sidenote similar "Note that similar does not mean identical." %} it has to traditional Mainframe systems that fell out of favour in the developer community some decades ago{% sidenote not-dead "Even though they are actually still [powering much of the western world](http://fingfx.thomsonreuters.com/gfx/rngs/USA-BANKS-COBOL/010040KH18J/index.html)’s financial and public sectors." %}. 

What is serverless computing?

> "Serverless computing allows you to build and run applications and services without thinking about servers." - [AWS Lambda FAQS](https://aws.amazon.com/lambda/faqs/)

What business users want is the ability to deploy **secure and reliable** business services without worrying about infrastructure. If that sounds like a serverless sales-pitch, it's actually the same requirement that Mainframes have been responding to since the 60s.

Of course the world has changed a lot since the first Mainframe were put in place. One of the main differences being "the cloud". Cloud providers slash the upfront outlay required for infrastructure, replacing it with a usage model where you pay only for the servers and network accessories you need. For larger companies who have opted for "private cloud" this difference may not be quite as large as it might seem.

To be clear, I've never been a Mainframe programmer so what I say here is from an outsider's perspective. However I've had some overlap with those who still think Java is the young upstart. Given that background here are some observations:

1. Mainframes and serverless providers allow large numbers of services to be run on a virtualised platform where resource allocation is handled for you in the background, typically by [external engineers](https://www.reuters.com/article/net-us-companies-netflix/netflix-blames-amazon-for-christmas-eve-outage-idUSBRE8BO06H20121226). Their distance from the business itself was deliberate but problematic in Mainframe systems. I've witnessed [personally](https://www.telegraph.co.uk/personal-banking/current-accounts/tsb-customers-hit-outage/) that pain in Cloud based systems and we’re already seeing similar stories in the serverless world.
2. Support for multiple languages with [COBOL](https://increment.com/programming-languages/cobol-all-the-way-down/) and PL/1 being the most common, notwithstanding the fact that it’s “just” a computing platform and there’s support for other more “modern” languages like C and Java. The languages mainly in use in mainframes today are more related to generational preferences than the platform itself, in the same way that my dad still uses trouser braces (notice the cycle there too?). In that light it’s not surprising to see [COBOL being a major language](http://fingfx.thomsonreuters.com/gfx/rngs/USA-BANKS-COBOL/010040KH18J/index.html) for Mainframe and JavaScript being a major language for serverless, when for many cases neither is particularly suited to the task.
3. An operational pricing model based on the load rather than capacity. This is the selling point of serverless and is indeed very attractive for many businesses but in the more mature mainframe arena the pros and cons are [well-known](http://ourdigitalmags.com/publication/?i=513513&article_id=3138790&view=articleBrowser&ver=html5#%7B%22issue_id%22:513513,%22numpages%22:1,%22view%22:%22articleBrowser%22,%22article_id%22:%223138790%22%7D). The major difference here is the lower ramp up costs for Cloud provisioned serverless - you don't need to *buy* the mainframe. 
4. Self-service deployment with the gamut of frameworks and software to help you do that.
5. Terminal based control panels. Not only that but retro interfaces are back [in fashion](http://lcamtuf.coredump.cx/afl/) and what could be more retro than a swanky terminal 3270 emulator emulator!

Apart from unmatched resilience and accuracy, what mainframe systems also have is resource and transaction management capabilities (CICS, for example), something that serverless still does not provide in a standardised way but will certainly begin to do so, possibly [converging](https://thenewstack.io/serverless-architecture-five-design-patterns/) to [message queues](https://hackernoon.com/serverless-transaction-processing-on-aws-2c686155096e) and [transaction compensation](https://microservices.io/patterns/data/saga.html), the pieces are already in place.

What I find most interesting is the drive by the tech giants to push these technologies. Despite the name, serverless functions must obviously be served by servers. Those servers will be deployed in the great data centres run by them. The commoditisation argument, where service infrastructure becomes so cheap and easy as to be considered a utility platform, is ironically exactly the same argument used my the commodity computer manufacturers when computing moved off the mainframe. It seems that commoditisation is a question of perspective.

As a corollary for us programmers this change will usher in a return to something similar to the structured design techniques popularised, you guessed it, by centralised processing paradigm of the last century. Structured design and functional style programming work beautifully together so that’s good news for those of us vested in both.

In synthesis it could be said that after a journey through cloud and managed container ecosystems we’re finally seeing a definite return to centralised processing in the form serverless. Maybe we can learn something from the last time around. 