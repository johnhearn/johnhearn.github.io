---
layout: post
asset-type: notes
name: plot-recipe-for-yao-jl
title: A Plot Recipe for Yao.jl
description: A distribution plot for Yao.jl
date: 2020-07-26 14:30:00 +01:00
author: John Hearn
tags:
- quantum computing
- julia
- yao

---

It's sometimes useful to see a distribution plot for multiple results obtained from a quantum circuit. Take for example the random number generator from a [previous post](quantum-random-numbers-in-yao-jl) where we used such a plot to check the results were uniformly distributed. Julia has great support for plotting. With the [Plots.jl] package it's extremely easy to get a distribution histogram but getting the axes tidy is a bit fiddly. Fortunately Plots.jl provides a very conveniente extension mechanism which we can use.

As a reminder, here we generate an array of random 3-bit numbers using the `nshots` parameter to specify how many, in this case 1000.

```julia
using Yao
n=3
numbers = zero_state(n) |> repeat(n, H) |> r -> measure(r, nshots=10000)
```

```console
1000-element Array{BitBasis.BitStr{3,Int64},1}:
 100 ₍₂₎
       ⋮
 110 ₍₂₎
```

To see the histogram of results we could do something like this:

```julia
histogram(numbers .|> bint, legend=:none, xticks=(0:7))
```

This is OK but it has a few things I don't like, for one the ticks don't really line up properly with the bars. Also the ticks have to be manually set. Also the bins often have to be tweaked manually as well. These things are easy to fix and put inside a Plots.jl recipe for easy reuse.

Looking back at the results, Yao.jl gives us an array of `BitStr` results and the full type `Array{BitBasis.BitStr{3,Int64},1}` is parametrised by the number of bits. That turns out to be quite useful. Defining the recipe function like this:

```julia
@recipe function user_recipe(measurements::Array{BitStr{n,Int},1}) where n
```

We now have access to the number of bits in $n$. The maximum possible value is then `max = (1<<n)-1`. Then we can calculate the histogram using standard Julia tools:

```julia
hist = fit(Histogram, Int.(measurements), 0:max+1)
hist = normalize(hist, mode=:pdf)
```

Notice that this is where the conversion to `Int` happens and we one again use the `max` value that came via the type parametrisation. Next the plot attributes, basically the same as the histogram used above:

```julia
seriestype := :bar
bins := max+1
xticks --> (0:max)
legend --> :none
```

Again using the `max` value. Then we can return the histogram results, centering on the tick marks:

```julia
hist.edges[1] .- 0.5, hist.weights
```

Y voila. Julia will automatically dispatch to our recipe based on the type of the results:

```julia
plot(results)
```

![Distribution of random numbers produced by the recipe](/assets/images/quantum-computing/random-dist-8.png){:width="60%"}

To check with a different distriibution let's try imitating a random 6-sided die by preselection of the unwanted values 6 and 7.

```julia
import YaoBlocks.ConstGate.P0

die = chain(4, 
    repeat(H, 1:3),
    control((2,3), 4=>X),
    put(4=>P0))

results = zero_state(4) |> block |> r -> focus!(r, 1:3) |> r -> measure(r, nshots=10000)
plot(results)
```

![Distribution of preselected random numbers produced by the recipe](/assets/images/quantum-computing/random-dist-6.png){:width="60%"}

Distribution shows values 6 and 7 have 0% probability, as we expected.

Working code available [here](https://nbviewer.jupyter.org/github/johnhearn/notebooks/blob/master/QuantumComputing/A Plot Recipe for Yao.jl.ipynb).


[Yao.jl]: https://github.com/QuantumBFS
[Plots.jl]: https://docs.juliaplots.org/latest/