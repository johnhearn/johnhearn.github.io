---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-julia-part-1
title: Building a QPU simulator in Julia - Part 1
description: A new tack, finding Julia and serendipity.
date: 2019-05-07 20:42:00 +02:00
author: John Hearn
tags:
- quantum computing
- tdd
- julia

---

Just for a kicks, I started rewriting [Quko], my simple quantum computing simulator, [in clojure](building-a-qpu-simulator-in-clojure-part-1). I thought that having powerful linear algebra libraries like [Neanderthal] would help simplify the task but it didn't feel right. I decided to put it on hold until I got some inspiration. 

{% marginfigure ssn-talk "assets/images/pointcare-snns.png" "The talk included Julia code for generating this Pointcaré section of the chaotic interaction between 3 spiking neural networks (SNNs) which I, ironically, converted to Kotlin." %}

So, I started looking again at [*complexity* theory](encounter-with-complexity). I was lead via [logistic maps](https://en.wikipedia.org/wiki/Logistic_map), and [other](https://en.wikipedia.org/wiki/Lotka%E2%80%93Volterra_equations) [dynamic](https://en.wikipedia.org/wiki/Rayleigh%E2%80%93B%C3%A9nard_convection) [systems](https://en.wikipedia.org/wiki/Galaxy_filament) to a library called [DynamicSystems.jl](https://juliadynamics.github.io/JuliaDynamics/) written in a language called [Julia]. I remembered having seen Julia two years ago from another [talk](https://www.youtube.com/watch?v=cLLQcshWEbE) on simulating spiking neural networks using Julia.


The things that were bothering me in Kotlin and Clojure when building the QPU simulator were complex numbers and linear algebra, specifically the Krondecker product, and it turns out that Julia supports both natively! So it was worth giving it a try{% sidenote guide "Edit: For a nice guide through [Julia] syntax take a look at the [ThinkJulia online book](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html). It pretty much covers all the basic and is very easy to understand." %}.

Installing Julia on a Mac is as simple as you might expect{% sidenote jupyter "You can use it from [Jupyter], if you prefer. I wrote down how to do that in a [separate note](using-julia-in-jupyter). The community overlap with Python is understandable." %}

```console
> brew install julia
...
```

Like Clojure, Julia has a nice REPL for developing and testing ideas quickly. Built-in support for vectors means that defining a qubit is easy{% sidenote float32 "Julia uses 64-bit floats by default. We don't need that level of precision and 32-bit floats save memory, a simple but important consideration for QPU simulators." %}:

```console
julia> qubit = Float32(1) * [1, 0]
2-element Array{Float32,1}:
 1.0
 0.0
```

Julia has dynamic typing so the variable type doesn't need to be set explicitly. The Hadamard operator{% sidenote hadamard "Defined as $$H = \\frac{1}{\\sqrt{2}} \\left(
  \\begin{array}{c} 
  1 & 1 \\\\ 
  1 & -1 \\\\ 
  \\end{array} 
  \\right)$$" %} is similarly easy to define with Julia's matrix syntax:

```console
julia> H = Float32(1/sqrt(2)) * [1 1; 1 -1]
2×2 Array{Float32,2}:
 0.707107   0.707107
 0.707107  -0.707107

julia> H * qubit
2-element Array{Float32,1}:
 0.70710677
 0.70710677
```

Taking it a step further we can use complex numbers natively. For example, we are able to define the [$$\sqrt{NOT}$$ gate](https://en.wikipedia.org/wiki/Quantum_logic_gate#Square_root_of_NOT_gate_(%E2%88%9ANOT)){% sidenote hadamard "Defined as $$ \\sqrt{NOT} = \\frac{1}{2} \\left(
  \\begin{array}{c} 
  1+i & 1-i \\\\ 
  1-i & 1+i \\\\ 
  \\end{array} 
  \\right)$$" %} almost as easily:

```console
julia> halfX = Float32(0.5) * [1+im 1-im; 1-im 1+im]
2×2 Array{Complex{Float32},2}:
 0.5+0.5im  0.5-0.5im
 0.5-0.5im  0.5+0.5im

julia> halfX * qubit
2-element Array{Complex{Float32},1}:
 0.5f0 + 0.5f0im
 0.5f0 - 0.5f0im
```

We can test that it's unitary using the conjugation operator, `'`, and the `@test` macro:

```console
julia> using Test
julia> @test halfX'*halfX ≈ [1 0; 0 1]
Test Passed
```

It's normal in Julia to use Unicode characters directly. This is strange at first but makes formulas very succinct. In the above test we used the `≈`  character{% sidenote approx "In the REPL, type `\\approx` and then press `Tab`." %} to perform a machine-precision equality test.

Being a functional language, it's straightforward to turn our operators into functions. X is the quantum NOT operator:

```console
julia> X = (qubit) -> Float32(1) * [0 1; 1 0] * qubit
#3 (generic function with 1 method)

julia> @test X(X(qubit)) ≈ qubit
Test Passed
```

This language really is a close to perfect for my project! [Serendipity](https://cognitive-edge.com/blog/serendipity/){% sidenote serendipity "Techniques for [encouraging serendipity](https://cognitive-edge.com/blog/exaptation-managed-serendipity-part-i/) are an important part of 
 the [Cynefin] framework, which I also happen to be studying at the moment. De Bono's concept of *Readiness* in action again." %} is a wonderful thing.


[Neanderthal]: https://neanderthal.uncomplicate.org/
[Quko]: https://github.com/johnhearn/quko
[Julia]: https://julialang.org/
[Jupyter]: https://jupyter.org/
[Cynefin]: https://cognitive-edge.com/videos/cynefin-framework-introduction/
