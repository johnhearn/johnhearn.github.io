---
layout: post
asset-type: notes
name: deutsch-jozsa-with-yao-jl
title: The Deutsch-Jozsa Algorithm in Yao.jl
description: The simplest quantum algorithm implemented in Yao.jl.
date: 2020-07-25 13:26:00 +01:00
author: John Hearn
tags:
- quantum computing
- julia
- yao

---

(Post adapted from a [similar one](deutsch-jozsa-algorithm) using [Yao.jl](https://yaoquantum.org/) instead of [Quko](https://github.com/johnhearn/quko). [Here](https://qiskit.org/textbook/ch-algorithms/deutsch-josza.html) is another one using [QisKit](https://qiskit.org/))

This post describes one of the first quantum algorithms to be discovered that gave a theoretically significant improvement over the classical equivalent. Having said that it's not useful at all, its main value was that it served as inspiration for other more practical algorithms such as Grover's search and Shor's factoring.

## Simplest case

The simplest statement of the problem is to determine if a boolean function, $$f$$, always results in the same _constant_ value or if it is _balanced_ and returns both true and false depending on the input.

In programming terms this means evaluating the function:

```kotlin
f : (Boolean) -> Boolean
```

for both possible inputs and checking the results. This amounts to applying an XOR operation to the two results:

```julia
f(false) ⊻ f(true)
```

In the classical world this will obviously require **two** evaluations of the function however in the quantum version only **one** evaluation is ever required.

Imagine we are given a gate $$U_f$$ which is based on the function we are interested in. This gate can be constructed in various ways but for now we'll assume that it's given.

Then a circuit for the algorithm can be represented by the following diagram:

![Deutsch's algorithm circuit](/assets/images/quantum-computing/deutschs-circuit.png){:width="320px"}

This equates in Yao.jl to the following snippet:

```julia
deutsch(Uf) = chain(2,
                put(2=>X),
                repeat(2, H),
                Uf,
                put(1=>H))
```

Where $U_f${% sidenote like "One of the things I like about Julia is that it is OK to use naming more akin to the mathematics, even using unicode, than would be conventional in other language conventions." %} is the block implementing the function. If the function is _balanced_ then the measurement will always be `true`, if constant then the measurement will always be `false`.

One way to think about how this works is that the $$U_f$$ gate transforms the superposition of both possible input values. The resulting interference pattern provides us with the result.

As an example, if the function, $f$, evaluates to a constant value $1$. If you work through the logic then the oracle, $U_f$, simply flips the second bit. In Yao.jl the block can be created like this:

```julia
Uf₁ = put(2=>X)
```

Where `put` is a Yao.jl function to add an `X` gate to the second qubit. Then, evaluating the circuit:

```julia
zero_state(2) |> deutsch(Uf₁) |> focus!(1) |> measure!
```

Always results in a `0` to indicate a *constant* function. On the other hand if we try a balanced function which can be represented by the `CNOT` gate.

```julia
Uf₂ = control(1, 2=>X)
```

In this case evaluating the circuit as before results ins a `1` indicating that it is balanced.

## Extending to multiple bits

Other researchers extended to algorithm to multiple bits which corresponds to the function taking an integer argument. The result bust either be *constant*, as before, or *balanced*, meaning that the function returns either 1 or 0 half of the time (other possible functions are not contemplated).

The function becomes:

```kotlin
f : (Int) -> Int
```

and will, on average, need many more evaluations of the function to test be able to determine if it is _constant_ or not.

The quantum circuit in this case would be:

![Deutsch-Jozsa algorithm circuit](/assets/images/quantum-computing/deutsch-jozsa-circuit.png){:width="400px"}

One way to build this circuit in Yao.jl is as follows:

```julia
deutsch_jozsa(m, Uf) = chain(m+1,
                        put(m+1=>X),
                        repeat(m+1, H),
                        Uf,
                        repeat(H, 1:m))
```

In this case $m$ is the number of bits in the integer part of the circuit. This will give us a boolean result for the given function, assuming the function works on $$m$$ bit integers. To build the oracle, $U_f$, we'll use some bit fiddling to create a permutation:

```julia
perm = [(y ⊻ f(x))<<m + x for y in 0:1 for x in 0:2^m-1]
```

The double comprehension syntax is very convenient here. Compare the calculation `y ⊻ f(x)` (where ⊻ means XOR) with the [definition](https://en.wikipedia.org/wiki/Deutsch%E2%80%93Jozsa_algorithm#Algorithm) of the gate.

To convert this to a Yao.jl block we have to create a permutation matrix (complex for generality) and then convert to a matrix block `matblock` for Yao.jl to understand it.

```julia
permute(sparse(I, N, N), perm.+1, collect(1:N)) |>
     Matrix{Complex{Float64}} |>
     matblock
```

We can then test our circuit with a function, say $f(x)=1$ which should give us $0$ since it's constant:

```julia
f(x) = 1 # constant
zero_state(m+1) |> deutsch_jozsa(m, Uf(m, f)) |> focus!(1:m) |> measure!
```

Which indeed results in 0.

To see this all working take a look at [this notebook](https://nbviewer.jupyter.org/github/johnhearn/notebooks/blob/master/QuantumComputing/The%20Deutsch-Jozsa%20Algorithm%20in%20Yao.jl.ipynb).
