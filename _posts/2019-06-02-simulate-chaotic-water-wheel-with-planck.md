---
layout: post
asset-type: post
name: simulate-chaotic-water-wheel-with-planck
title: Chaotic Waterwheel with Planck
description: A simulation of a chaotic waterwheel with the Planck JavaScript physics engine.
date: 2019-06-02 18:22:00 +02:00
author: John Hearn
tags:
- complexity
- javascript

---

> (Update: Many thanks to [shakiba](https://github.com/shakiba) for fixing this and adding it to the [Plank.js](https://github.com/shakiba/planck.js) homepage as an example.)

{% marginfigure malkus "assets/images/complexity/malkus_wheel.gif" "A schematic of the chaotic Malkus waterwheel discussed by Steven Strogatz in [lecture 15](https://www.youtube.com/watch?v=HljJv7Hf6Zo) of his course." %}
I'm just finishing [Steven Strogatz](https://twitter.com/stevenstrogatz?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor)'s [Nonlinear Dynamics and Chaos](https://www.youtube.com/playlist?list=PLbN57C5Zdl6j_qJA-pARJnKsmROzPnO9V) course and one of the systems he discusses is the chaotic Malkus water wheel. This is a real set up devised to mimic the famous [Lorenz equations](https://en.wikipedia.org/wiki/Lorenz_system). 

> "*In the 1960s... a real system was needed to demonstrate that chaos and the butterfly effect were realities and not mere mathematical artefacts... W.V.R. Malkus, a mathematician at MIT, realized that the Lorenz-Equations can be transformed into the equations of motion of a waterwheel. This waterwheel was built at MIT in the 1970s and helped to convince the sceptical physicists of the reality of chaos*" - taken from [here](http://goodshare.org/wp/climate-bai/)

It consists of a stream of water feeding into multiple, leaky cups mounted on a rotating wheel. The weights of the cups containing water produce a chaotic behaviour causing the wheel to rotate in different directions unpredictably.
{% marginfigure real "assets/images/complexity/malkus_wheel.jpeg" "A real construction of the wheel. [Here](https://www.youtube.com/watch?v=51FgNhrS6jg)'s another one with a video." %}
So today I thought I'd play with this idea and try to reproduce it in a 2D physics engine. I chose [Planck](http://piqnt.com/planck.js/), a JavaScript physics engine based on the Box2D implementation in C++.

It took a while to tune the size of the balls representing the water flow and the gaps in the cups which regulate the outflow. It's far from perfect but it demonstrates the idea.

Anyway here's the result.

<pre>
<iframe width="400" height="400" src="{{ site.url }}/assets/frames/chaos-wheel-planck.html">
</pre>
