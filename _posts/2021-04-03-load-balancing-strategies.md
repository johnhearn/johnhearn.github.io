---
layout: post
asset-type: post
title: Load Balancing Strategies and their Distributions
description: A comparison of different load balancing strategies and the statistical distribution of requests.
date: 2021-04-03 17:27
category: 
author: John Hearn
tags:

---

Results of a simulation to compare four of the most well known load balancer strategies:

1. **Round robin** - requests are routed to each of the available servers in turn
2. **Least occupied** - requests are routed to the server with least current requests
3. **Random** - requests are routed to a randomly selected server
4. **Random 2** - requests are routed to one of two randomly selected servers, where the chosen server has least current requests (see [here](https://www.haproxy.com/blog/power-of-two-load-balancing/) and [here](https://www.nginx.com/blog/nginx-power-of-two-choices-load-balancing-algorithm))

## The experiment

* **Arrival rate**: requests arrive with a Poisson process with mean $\lambda$.
* **Service rate**: request completions are distributed with a Log-Normal distribution (although any realistic distribution shows the same characteristics).
* **Load factor** is the ratio of arrival rate to completion rate, ranging strictly from 0.0 to 1.0. If greater than 1 then the requests would accumulate without end.

We keep a record of the number of requests in the system for a single server. The [Julia code](https://nbviewer.jupyter.org/github/johnhearn/notebooks/blob/0209bfb5a128fd332250cf341b97064281ea4feb/Smadex/Load%20Balancing%20Stats.ipynb) is here.

## The results

The difference in the distributions of the concurrent requests in with the different strategies is clear.

{% maincolumn "assets/images/load-balancing/hist-20-75.png" "Distribution of concurrent requests under different load balancing strategies. The requests are distributed over 20 servers with average arrival rate of 10 per step at 75% load factor." %}

Notice how remnants of the input and output distributions are still visible in the *round robin* strategy. The *least occupied* and *random 2* strategies tend to concentrate the distribution around its average. On the other hand the *random* strategy seems to spread the distribution still further.

How does the average vary with load factor?

{% maincolumn "assets/images/load-balancing/mean-20-p.png" "Change in average concurrent requests as load factory varies, keeping number of servers at 20." %}

All strategies perform progressively worse as load factor increases, as would be expected. However the *least occupied* and *random 2* strategies are noticeably better that the others, even at higher load factors.

And how does it change with number of servers?

{% maincolumn "assets/images/load-balancing/mean-c-80.png" "Change in average concurrent requests as number of servers varies, keeping load factor constant at 80%." %}

Clearly the best strategies require a minimum number of servers over which to spread the requests. That number is relatively small (in this example around 10) and very little improvement is observed with additional servers. The others are unaffected by number of servers.

## Variance

The spread in concurrent requests will translate to a spread in latencies too. For a distributed systems we are usually interested in maintaining predictable latencies and minimising long-tails, so we want to minimise this spread. It's visibly clear that *least occupied* is the best in this case as it has the narrowest distribution. Let's have a look at the variance for each one, taking *round robin* as the base.

{% maincolumn "assets/images/load-balancing/variance-20-p.png" "Comparison of variance of the distribution of concurrent requests under different load balancing strategies, keeping the number of servers at 20." %}

What is the relationship between number of servers and the variance?

{% maincolumn "assets/images/load-balancing/variance-c-80.png" "Change in variance under different load balancing strategies as number of servers increases." %}

We can see that when there is only a single server, all strategies are the same (obviously). Both the *round robin* and *random* strategies have little or no effect on the variance, no matter how many servers there are in the cluster. Although bot *least occupied* and *random 2* fare better, the *least occupied* has a clear advantage here and seems to be able to capitalise on additional servers more effectively.

## Shedding

We employ a shedding mechanism to help keep request distributions under control independently of the load balancing strategy. How does this affect the results? Here we apply a simple shedding of requests by disallowing more than 20 concurrent requests per server.

{% maincolumn "assets/images/load-balancing/hist-20-75-shedding20.png" "Distribution of concurrent requests under different load balancing strategies, shedding requests above 20 per server." %}

The mean of the worse strategies has actually gone down, however much more shedding is being done. That means that server throughput (serviced requests) should be lower. On the other hand the average latencies will also be higher due to the higher load on the server.

## Conclusion

{% marginfigure "entropy" "assets/images/load-balancing/entropy-c-80.png" "As an aside, we can also calculate the entropy of the distribution and see (as shown in the graph above) that it has also has **decreased** for the *least occupied* and *random 2* strategies while it has actually **increased** for the random one. One interpretation of these results is that the *random* strategy introduces a little bit of new uncertainty into the system. On the other hand *least occupied* and *random 2* actually remove uncertainty. This is the load balancer equivalent of [Maxwell's demon](https://en.wikipedia.org/wiki/Maxwell's_demon), applying work to each request in order to reduce its uncertainty." %}

Of all the strategies *round robin* and *random* are disastrous and either do nothing to improve the distribution of requests or actually make it worse. However, the *least occupied* and *random 2* strategies are able to take advantage of multiple servers to not only reduce the mean but also reduce the variance across the cluster.

While the *least occupied* is slightly better in terms of the spread of requests, the *random 2* has some other advantages. Firstly, it's slightly simpler and therefore faster in practice because only 2 servers are checked for each request rather than all of them. More importantly, it avoids servers which are (re)starting receiving all the load immediately. This is useful when the server needs some time to warmup caches, etc.