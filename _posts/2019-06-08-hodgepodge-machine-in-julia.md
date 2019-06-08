---
layout: post
asset-type: article
name: hodgepodge-machine-in-julia
title: The Hodgepodge Machine
description: A classic 2D cellular automa with Julia.
date: 2019-06-08 17:16:00 +02:00
author: John Hearn
tags:
- complexity
- julia

---

> "*The pleasure of complexity... the inconceivable nature of nature*" - [Richard Feynmann](https://youtu.be/tD_XAX--Ono?t=67)

Back in the 80s, my Dad used to work as a security guard at a [geothermal energy research site](https://en.wikipedia.org/wiki/Rosemanowes_Quarry) and sometimes I would accompany him on his rounds. The facility was well funded and very advanced for its time and there was all kinds of computer equipment which was at that time both fascinating and alien to me. There was also a collection of science and technology magazines and sometimes I would read them for hours.

The magazines I liked most were Computer Weekly and Scientific American. I liked them mostly for their programming sections. Back in those pre-internet days it was common for the articles to include listings, mostly in Fortran, BASIC and maybe Pascal and even Assembler{% sidenote assembler "Yep, we used to type machine code by hand!" %}. That's how I learned to code.

One [article](https://www.jstor.org/stable/24989205?seq=1#page_scan_tab_contents) I remember particularly fondly was in Scientific American's Computer Recreations section with the caption "*The hodgepodge machine makes waves*"{% sidenote citation "Dewdney, A. (1988). COMPUTER RECREATIONS. *Scientific American*, *259(2)*, 104-107. Retrieved from http://www.jstor.org/stable/24989205" %}. The date was August 1988. It described a set of rules which mimicked a type of chemical reaction, the so called [Belousov-Zhabotinsky reaction](https://en.wikipedia.org/wiki/Belousov%E2%80%93Zhabotinsky_reaction), and resulted in fantastic shapes and behaviours emerging almost like magic. I was able to reproduce that at the time on my Amstrad CPC even though it took ages to update each frame. It was one of my first programming successes.

A few weeks ago one of my colleagues at Codurance wrote an article called [*Nature in Code*](https://codurance.com/2019/05/30/nature-in-code/) where she simulated biological interactions in code and how interesting phenomena emerge naturally. It reminded me of the Hodgepodge Machine and inspired me to try it again with more modern techniques (thank you Solange). So I sat down this morning, and with a little help from this [blog post](https://softologyblog.wordpress.com/2017/02/04/the-belousov-zhabotinsky-reaction-and-the-hodgepodge-machine/), wrote it in Julia. This is the result.
<p/>

<iframe width="560" height="315" src="https://www.youtube.com/embed/9HPaottA9tE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Compare that to this real reaction:
<p/>

<iframe width="560" height="315" src="https://www.youtube.com/embed/8tArShb1fhw?start=57" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

This ties in with recent work I've been doing on dynamical systems and complexity. The hodgepodge machine *is* a dynamical system: deterministic but, under certain conditions, totally unpredictable. 

As Feynman said, "*And it's all really there...but you've got to stop and think about it to really get the pleasure about the complexity;
the inconceivable [he chuckles] nature of nature.*".

Code is on GitHub [here](https://gist.github.com/johnhearn/e17cc9d2e98f7bf3db1012d2046fba78).