---
layout: post
asset-type: post
title: "Predictability and batch size"
description: It turns out that delivery predictability decreases linearly with batch size.
date: 2024-09-28 18:30:00 +02:00
category: 
author: John Hearn
tags: 
- probability
- forecasting

---

Some results from a little Monte Carlo simulation of delivery times [posted on LinkedIn](https://www.linkedin.com/posts/phil-ledgerwood_in-my-last-post-on-this-httpslnkdin-activity-7245467832489046017-sk_N) showed that **predictability decreases with larger batch sizes**. A little maths shows clearly why this is the case. 

### The model

The post compared a team delivering one work item per day with a team delivering 5 work items together every 5 days. The teams have a batch size of 1 and 5 respectively. In this situation we'd expect the mean delivery rate to be the same, namely 1 item per day on average. We'll call the batch size $b$.

In our model, a team will deliver $W$ work items (doesn't matter the size of each item, we're only using the finishing rate in this model) in batches with $\frac{W}{b}$ items in each batch. Let's call the number of batches $r=\frac{W}{b}$. 

In this idealised model, Team 1's probability of delivering each day is close to 1, so for this case let's say $p=1$. Team 2's probability of delivering 5 work items on any particular day is $p=\frac{1}{5}$. So in general on a given day a team delivers $b$ work items with a probability of $p=\frac{1}{b}$.

We want to know the probability of delivering $W$ items of work in $n$ days. This requirement is captured by a [Negative Binomial](https://en.wikipedia.org/wiki/Negative_binomial_distribution) distribution and, luckily for us, all the maths has been previously worked out. We'll break the total delivery time down into two parts. First, the the number of times that a team _fails_ to deliver on a specific day, that is the gaps between deliveries. We'll call that number $k$. Secondly, we need the number of days that it does deliver, this is $r$. We can then say that the total number of days is the sum of the delivery days, $r$, plus the non-delivery days, $k$. In other words, $n=k+r$. In this case then $k$ follows:

$$n-r = k \sim NegativeBinomial(r, p)$$

And from this we can work out the distribution of $n$.

### What does the model tell us?

Given the distribution defined above, and remembering that $r$ is a constant, then the expected value of $n$ is:

$$E[n] = E[k+r] = E[k] + r = \frac{r(1-p)}{p} + r = \frac{r}{p} = \frac{\frac{W}{b}}{\frac{1}{b}} = W$$

So, in this model, to deliver $W$ work items **the average total delivery time is independent of the batch size**, as expected. 

What about its variance? The variance of the mean (a measure of predictability) is:

$$Var[n] = Var[k+r] = Var[k] = \frac{r(1-p)}{p^2} = \frac{W}{b} \frac{(1-\frac{1}{b})}{\left( \frac{1}{b} \right)^2} = W(b-1)$$

So **the variance _increases linearly_ with batch size**. Since the greater the variance the less predictable the result we can say that the predictability _decreases_ with batch size.

The variance **also increases linearly with the amount of work**. This captures the fact that the predictability decreases the further into the future you look, even if the delivery rate remains constant. This is just one of the factors comprising the [cone of uncertainty](https://en.wikipedia.org/wiki/Cone_of_uncertainty) that results solely from batch size.

### A model is a model

In any real team the batch size won't be constant but, all other things being equal, this model is good enough to tell us that regular delivery of smaller batches is preferable to larger ones.{% sidenote "other reasons" "There are other reasons too, like the accumulation of changes increasing the probability of bugs but that is not covered in this model." %}

Also in real teams the work items are generally not completely independent. This can be due to internal team dynamics, one piece of work being a prerequisite of another, etc. The practical effect of this is to increase the variance further. One nice thing about the negative binomial as a modelling tool is that it can easily be tuned to the teams actual data by increasing its variance slightly while keeping the mean constant. In the past I have found this to be a very good approximation of data gathered from real teams.

Another nice thing about using a known distribution is that we can go beyond normal Monte Carlo and use Bayesian inference for forecasting. Having a Bayesian model has the advantage of being deterministic and smoother, regulating and reducing noise or small sample effects that are sometimes evident in Monte Carlo simulations.

As always these results need to be used with caution and a full understanding of what they mean. Nonetheless having models to help us understand the mechanisms and principles behind our intuitions can be very handy at times. 



### Validation

Just to check that the model we've described actually works, the shaded area in the plot below shows 100,000 live results from Monte Carlo simulations of delivery times for 40 pieces of work when 5 items are delivered together. The red line represents the negative binomial model described here. Hopefully, they match as perfectly now as they did when I wrote this.

<br/>

<iframe width="780" height="470" src="{{ site.url }}/assets/frames/negative-binomial-plot.html">

