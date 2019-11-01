---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-julia-part-5
title: Building a QPU simulator in Julia - Part 5
description: Grover's search algorithm.
date: 2019-06-25 20:50:00 +02:00
author: John Hearn
tags:
- quantum computing
- julia

---

[Grover's] search is the next algorithm to implement in with Julia. It's not that much more complex that the Deutch-Jozsa algorithm from the [last post](building-a-qpu-simulator-in-julia-part-4) but it is an example of an algorithm that is potentially very useful for quantum circuits. It enables us to search for states satisfying a given set of conditions{% sidenote queens "A toy example of which might be the [N-Queens problem](https://www.google.com/search?q=n-queens+problem+quantum+computing) for very large boards." %} much more quickly, $\mathcal{O}(\sqrt{N})$, than its classical counterpart, $\mathcal{O}(N)$.

We start with a test for the condition we want to search for. In this case a simple match:

```julia
@test groversSearch(4, (it) -> it == 0b1011) == 0b1011
```

It starts with the following circuit:

![Grover's search algorithm circuit](/assets/images/quantum-computing/grovers-circuit.png)

This new part of this is the diffusion operator The first part of which we can translate to our growing Julia library as something like this:

```julia
grovers(Uf) = register(ZERO, ZERO, ZERO, ZERO, ONE) |>
                gate(H, H, H, H, H) |>
                gate(Uf)
```

[Grover's]:(grovers-search)
