---
layout: post
asset-type: post
title: Inverse Markov
description: Inferring a model about how stuff moves about
date: 2022-10-29 08:46:00 +02:00
category: 
author: John Hearn
tags: estimation modelling

---

Markov chains are a fantastic tool for modelling how stuff moves about over a network of possible states. Think about them as probabilistic state machines. Its uses are widespread, from Google's [PageRank algorithm](https://saattrupdan.github.io/2020-08-07-pagerank/) which models the way users move about the internet to analysing the ways players move around a [Monopoly board](http://www.bewersdorff-online.de/amonopoly/). We can also use it as a simple model of workload in a distributed system or team. 

In my case I had some economic data and I wanted to see if I could make a fortune finding a trend in the market{% marginnote notrich "Needless to say the result was negative and my wealth has increased only in terms of knowledge." %} so I found myself wanting to determine a Markov chain model from real-world data.

It turns out that this topic was studied extensively in the last century[^Lee1965]'[^Lee1968] and, although simple and well understood, it took me a while to get my head around it. I'm writing it up here to help me remember.

For the background of the maths behind Markov chains in general there are numerous resources [online](https://www.google.com/search?q=markov+chain). Basically we repeatedly apply a transformation to the current state to turn it into a new state. We then apply the same transformation to the new state to create the next state and so on. Remarkably, no matter which state we start in, while conditions stay constant the system _always_ converges to the same steady state (plus a bit of noise). We can use this fact to work backwards from observations of the sequence of states and infer the model that would have generated them.

Say we have a state represented by a vector $\nu$ and a transformation represented by a matrix $P$. Based on a sequence of noisy observations of the state, $\left(\nu_1, \nu_2...\nu_n\right)$, what is our best estimate of $P$?

We'll need plenty of observations so let's put them together into the same matrix: $$V = \left[\nu_1, \nu_2...\nu_{n-1}\right]$$

Each application of $P$ takes us to the subsequent state so we have $$VP = \left[\nu_2, \nu_3...\nu_n\right] = U$$

We end up with an equation involving $\nu_1, \nu_2...\nu_n$.

Since $P$ is a square matrix we will need $n$ to be at least equal to the number of states. If we have more then even better. Using the [_pseudo-inverse_](https://en.wikipedia.org/wiki/Moore%E2%80%93Penrose_inverse) of the states we can get the [least squares](https://en.wikipedia.org/wiki/Moore%E2%80%93Penrose_inverse#Linear_least-squares) best estimate for P.
$$\hat P = V^+ \times U$$

Where the $^+$ symbol represents the generalised inverse which in fact is easy enough to calculate, $V^+ = (V'V)^{-1}V'$.

In Julia, assuming we already have the state data in the variable $\nu$, this becomes

```julia
V = ν[1:n-1,:]
U = ν[2:n,:]

V⁺ = inv(V'V)V'

Pest = V⁺*U
```

This works fairly well but it has problem. The peudo-inverse knows nothing of the contraint on the probabilities which must all be positive. Various workarounds exist but in the end we end up having to fiddle with the numbers to get them all positive in the optimal way.

Luckily for us, optimisation algorithms for situations like these have also been studied extensively. Julia's [JuMP eco-system](https://jump.dev/), for instance, provides tools which eat these kinds problems for breakfast.

We are optimising for the minimum square difference between $U$ and $VP$ where the entries in $P$, always positive, are the variables we are trying to determine, $p_{ij} > 0 \space \forall i,j$

Specifically, we are finding values for $p_{ij}$ with the objective of minimising
$$(U-VP)^2 = (U-VP)' \cdot (U-VP)$$

We also have the condition that the entries must be positive and the constraint that the rows must sum to 1, $\sum_{j}{p_{ij}} = 1$.

Assuming $r$ is the number of states, in JuMP we can define the problem like this:
```julia
model = Model(Ipopt.Optimizer)

@variable(model, p[1:r^2] >= 0.0)
@objective(model, Min, (U - V*P)'*(U - V*P))
for j in 1:r
    @constraint(model, sum(p[i] for i in j:r:r^2) == 1.0)
end

optimize!(model)

Pest = reshape(value.(p), r,r)
```

With this code I've been able to recover a good approximation to the transition matrix in testing, the approximation becomming better with increasing sample size. 

We could give the algorithm an initial hint based on the pseudo-inverse described above but in my experiments the optimisation algorithm is fast enough to not require it. 

The method could be improved by quantifying the uncertainty in the results. On way would be to batch observations and look at the distribution of results. Another might be to apply a bayesian approach using a Dirichlet multinomial as the prior and updating with the observations. A problem for another time.


References

[^Lee1965]: <sup><sub>Lee, T. C., Judge, George G., Takayama, T., 1965. On Estimating the Transition Probabilities of a Markov Process. American Journal of Agricultural Economics 47, 742–762. [https://doi.org/10.2307/1236285](https://doi.org/10.2307/1236285)
[^Lee1968]: <sup><sub>Lee, T. C., Judge, George G., Zellner, A., 1968. Maximum Likelihood and Bayesian Estimation of Transition Probabilities. Journal of the American Statistical Association 63, 1162–1179. [https://doi.org/10.1080/01621459.1968.10480918](https://doi.org/10.1080/01621459.1968.10480918)
