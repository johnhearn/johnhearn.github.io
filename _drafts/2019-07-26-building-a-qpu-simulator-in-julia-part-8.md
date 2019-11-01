---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-julia-part-8
title: Building a QPU simulator in Julia - Part 8
description: Using Julia to build the quantum part of Shor's Algorithm.
date: 2019-07-27 21:40:00 +02:00
author: John Hearn
tags:
- quantum computing
- julia

---

In the [last post](building-a-qpu-simulator-in-julia-part-7) we implemented a classical version of Shor's Algorithm. To prove that it works we used a brute force search to find the period of our modular power sequence knowing that that approach would not be feasible for large numbers. In this post we use [Quju] to find the period by simulating quantum superposition and, given a big enough quantum computer, this method would be efficient enough to find the period even for very large numbers, and hence the factors.

This is not going to be trivial as the quantum algorithm itself if complicated. Remember that it's exponentially difficult to simulate quantum computations on a classical computer so we'll attempt to factor the simplest possible number ($N=3\times5=15$) so that our simple simulator can handle the number of required bits.

The first step is to find a number $Q=2^q$ such that $N^2 < Q < 2N^2$. Using some simple algebra, and making sure to remain in the integers, this works out in Julia as:

```julia
q = Int(ceil(2*log(N)/log(2)))
Q = 2^q
@test N^2 < Q < 2N^2
```

The circuit for the algorithm operates on a register which in turn has two sub-registers, the first holds numbers from 0 to Q-1 and the second can hold numbers from 0 to N-1. That means that the first sub-register has $q$ bits and the second has $n$, where $n=\lceil log_{2}(N) \rceil$. In Julia: 

```julia
n = Int(ceil(log(N)/log(2)))
```

For our simple case $q=8$ and $n=3$ so we'll need 12 (8+4) bits in total.

```julia
@test (q, n) = (8, 4)
```

Just as in the classical case, the full algorithm chooses a random number and retries if some conditions don't hold but to avoid having to do all that, and to keep things easy to test, we'll choose 13 as the value for $a${% sidenote period "The period we're going to expect is then 4 because, by the number theory behind the algorithm, $13^4 = 28561 = 1904 × 15 + 1$, that is $13^4 = 1 \mod 15$. Of course we wouldn't normally know that beforehand!" %}.

```julia
@test period(15, 13) == 4
```

With these initial values we construct a register with the required number of bits. We can do this with a little helper function from Quju.

```julia
qubits = register((ZERO,q), (ONE,n))
```

This is equivalent to a 12 bit register initialised to $\ket{0}$ in the first 8 bits and $\ket{1}$ in the last 4 bits.

```julia
@test qubits == ZERO⊗ZERO⊗ZERO⊗ZERO⊗ZERO⊗ZERO⊗ZERO⊗ZERO⊗ONE⊗ONE⊗ONE⊗ONE
```

The circuit for Shor's algorithm stars by putting the first 8 bits in superposition using the Hadamard operator. This we can do with the `gate` helper which returns a function that we can apply to the register.

```julia
initialise = gate((H,3),(eye,2))
```

The oracle gate is the next section of the circuit (this is wrong):

```julia
U = oracle(q, n, (x, y) -> Int(y*(a^x) % 2^n))
```

Finally the QFT:

```julia
invqft = gate((qft´(q),1), (eye, n))
```

Then we measure the first $q$ bits and see what we get:

```julia
measure!(1:q)
```

Putting it all together:

```julia
result = register((ZERO,q), (ONE,n)) |>
         initialise |>
         U |>
         invqft |>
         measure!(1:q) |>
         toInt
```

