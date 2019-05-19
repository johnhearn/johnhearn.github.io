---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-julia-part-2
title: Building a QPU simulator in Julia - Part 2
description: Starting again with Julia.
date: 2019-05-07 20:42:00 +02:00
author: John Hearn
tags:
- quantum computing
- tdd
- julia

---

In the [last post] we saw how the Julia programming language has several advantages over Kotlin and Clojure for building a quantum computer simulator. This post covers how we might do that{% sidenote maths "Note: These notes go into some pretty heavy maths. For a less mathematical description of quantum computing concepts, take a look at [this article](quantum-computing-primer-part-1a)." %}. We'll start as [before] with a simple case of an 8-sided [quantum die](quantum-random-number-generator). This is the code written with the [Quko] library (from the [README](https://github.com/johnhearn/quko)):

```kotlin
val qubits = Qubits(3).hadamard(0..2)
print(qubits.measureAll().toInt())
```

Written in Julia this becomes:

```julia
qubits = hadamard(qubits(3), 1:3)
print(toInt(measureAll(qubits))
```

Some things to notice. Firstly we've moved to a functional style. As typing is optional there is no need to define the variable. Also the range specified by `1:3` is using [1-based indexing](https://craftofcoding.wordpress.com/2017/03/12/why-1-based-indexing-is-ok/).

## Measurement of Single Qubit

We'll define a test to verify the probability that our qubit is measured `false`.

```julia
repeatedly = (n, f) -> map(x -> f(), collect(1:n))
sample = (n, f) -> count(repeatedly(n, f))

@test sample(1000, () -> measure(qubit())) == 0
```

As [before], we can make that pass trivially, of course, defining a dummy qubit and just returning false from `measure` every time.

```julia
qubit = () -> nothing
measure = (qubit) -> false
```

Now, given Julia's support for matrices, let's jump straight to theory. A qubit can be represented by a **pair** of (complex) numbers, a $$\mathcal{H}_2$$ space. In the case of a qubit initialised to the $$\ket{0}$$ state that is just `[1 0]`. We saw in the [last post] how easy that is in Julia{% sidenote float32 "Julia uses 64-bit floats by default. We don't need that level of precision and 32-bit floats save memory, a simple but important consideration for QPU simulators." %}:

```julia
qubit = () -> Float32(1) * [1, 0]
```

The measurement can be represented by a matrix operator using the quadratic form $$p(\ket{0})=\braket{v}{0}\braket{0}{v}=v^{T} M_0 v$$ where $$p(\ket{0})$$ is the probability that a qubit is measured as `false` and 

$$ M_0 = \ketbra{0}{0} = \left(
  \begin{array}{c} 
  1 \\ 
  0 \\
  \end{array} 
  \right)
  \left(
  \begin{array}{c} 
  1 & 0
  \end{array} 
  \right)
  =
  \left(
  \begin{array}{c} 
  1 & 0 \\ 
  0 & 0 \\
  \end{array} 
  \right)
$$

To make this calculation we can take advantage of Julia's [adjoint](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#Base.adjoint) operator, `'`. Also this is where the random aspect of the qubit comes into play and the `rand()` function is used to determine if the measurement is indeed `false` based on the probability of it being so.

```julia
M₀=[1 0]' * [1 0]
measure = (qubit) -> rand() < abs(q' * M₀ * q)
```

```console
julia> @test sample(1_000_000, () -> measure(qubit())) == 0
Test Passed
```

## The Hadamard Gate

At the moment the qubit is always initialised to $$\ket{0}$$ so measurement will always return `false` with 100% probability. To make the measurement more meaningful we want to be able to move the state of the qubit into a 50/50 superposition (half way around the Bloch sphere) so that measurement will return `true` or `false` with equal probability, a fair coin toss. We can do that using the Hadamard operator. The Hadamard operator is defined as $$H = \frac{1}{\sqrt{2}} \left(
  \begin{array}{c} 
  1 & 1 \\
  1 & -1 \\
  \end{array} 
  \right)$$ and is similarly easy to implement with Julia's matrix syntax:

```console
julia> H = Float32(1/sqrt(2)) * [1 1; 1 -1]
2×2 Array{Float32,2}:
 0.707107   0.707107
 0.707107  -0.707107

julia> hadamard = (qubit) -> H * qubit
julia> hadamard(qubit())
2-element Array{Float32,1}:
 0.70710677
 0.70710677
```

Or even better using the piping operator:

```console
julia> qubit() |> hadamard
2-element Array{Float32,1}:
 0.70710677
 0.70710677
```

Then we can measure our qubit and it gives us one random bit each time, as can be seen by measuring multiple qubits prepared in the same way.

```console
julia> repeatedly(3, () -> qubit() |> hadamard |> measure)
10-element Array{Bool,1}:
 false
  true
 false
```

We could build our random number generator already, taking 3 independent measurements and interpreting it as binary. For example,

```julia
coinToss = () -> () -> qubit() |> hadamard |> measure
toInt = (b) -> reduce((acc, v) -> 2*acc + v ? 1 : 0, b)
```

```console
julia> toInt(repeatedly(3, coinToss))
6
julia> toInt(repeatedly(3, coinToss))
3
```

This, however, is cheating because we can only deal with one qubit at a time and it doesn't implement our original feature test. We're back to the same point as we were with the Clojure implementation but in a better position because now we can take advantage of more of Julia's built-in linear algebra support. 

## Quantum Registers

So let's make things even harder and represent qubit *registers*. Registers are *systems* of qubits in a combined state. We calculate this combined state with the [Krondecker](https://en.wikipedia.org/wiki/Kronecker_product) product, also implemented natively in Julia by the [`kron`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/index.html#Base.kron) function. Let's try a 2 qubit register:

```julia
qubits = () -> kron(qubit(), qubit())
```

Testing in the console, it just works...

```console
julia> qubits()
4-element Array{Float32,1}:
 1.0
 0.0
 0.0
 0.0
```

We can generate any size register we please, with the only constraint being available memory:

```julia
register = (n) -> foldl(kron, fill(qubit(), n))
```

This function uses the standard `fold` function to perform the `kron` operation, from left to right, over an array of `n` qubits. 

```console
julia> register(3)
8-element Array{Float32,1}:
 1.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
```

It works as expected. A 2 bit register needs an array of 4 complex numbers, a 3 bit one needs an 8 bit array, 4-bits require 16 and so on. The size of the array gets very big.

Now we can turn our attention to the quantum gates and combine them into a multiple qubit gate. Once again the Krondecker product is used and works in exactly the same way.

```julia
hadamard = (n) -> foldl(kron, fill(H, n))
```
```console
julia> hadamard(3)
8×8 Array{Float32,2}:
 0.353553   0.353553   0.353553   0.353553   0.353553   0.353553   0.353553   0.353553
 0.353553  -0.353553   0.353553  -0.353553   0.353553  -0.353553   0.353553  -0.353553
 0.353553   0.353553  -0.353553  -0.353553   0.353553   0.353553  -0.353553  -0.353553
 0.353553  -0.353553  -0.353553   0.353553   0.353553  -0.353553  -0.353553   0.353553
 0.353553   0.353553   0.353553   0.353553  -0.353553  -0.353553  -0.353553  -0.353553
 0.353553  -0.353553   0.353553  -0.353553  -0.353553   0.353553  -0.353553   0.353553
 0.353553   0.353553  -0.353553  -0.353553  -0.353553  -0.353553   0.353553   0.353553
 0.353553  -0.353553  -0.353553   0.353553  -0.353553   0.353553   0.353553  -0.353553
```

It's clear how the size of these gates gets out of hand very quickly having a size of $$2^n \times 2^n$$.

Using this gate we can apply the Hadamard operator to all the qubits at once.

```console
julia> hadamard(3) * register(3)
8-element Array{Float32,1}:
 0.35355335
 0.35355335
 0.35355335
 0.35355335
 0.35355335
 0.35355335
 0.35355335
 0.35355335
```

This is the combined state of a 3 bit quantum register with each bit in a 50/50 superposition. Not to be confused with entanglement because the bits are still independent... so far.

This is where things get a little more tricky.  To measure a single qubit we need to place the measurement operator over the qubit in the register, applying the identity operator for all other bits. This is called lifting{% sidenote lifting "At least it's called lifting in [this paper](https://arxiv.org/abs/1608.03355) which I found helpful to understand this process." %}.

We'll need the identity operator for a single qubit $$I = \left(
  \begin{array}{c} 
  1 & 0 \\
  0 & 1 \\
  \end{array} 
  \right)$$:

```julia
eye = () -> Matrix{Float32}(I, 2, 2)
```

Now we must *lift* the $$M_0$$ operator as $$I^{k-1} \times M_0 \times I^{n-k-1}$$. In Julia this can be written like this:

```julia
lift = (n, k, op) -> foldl(kron, map(it -> (it == k) ? op : eye, collect(1:n)))```

This function will combine a series of $$I$$ operators, the `op` operator over the `k`th bit and then more $$I$$ operators to the end of the register. The result is{%sidenote sparse "It can be seen here that the lifting matrix is mostly full of zeros. Hopefully we'll be able to take advantage of Julia's specialised matrix representations to optimise this." %}:

```console
julia> lift(3, 2, M₀)
8×8 Array{Float32,2}:
 1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  1.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  1.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0
```

Measurement of the kth bit is then:

```julia
measure = (n, k, qubits) -> rand() > qubits' * lift(n, k, M₀) * qubits
```

So we can measure the 2nd bit like this:

```console
julia> qubits = hadamard(3) * register(3)
...
julia> measure(3, 2, qubits)
true
```

One more important point. The measurement of each qubit is an operation which *collapses* the state of the qubit, i.e. changes its value. The measurement function must *lift* the $$M_0$$ or $$M_1$$ operation (depending on the result) over the measured qubit, apply it to the register and then renormalise it. More information about this can be found in [this paper](https://arxiv.org/abs/1608.03355).

```julia
M₁ = [0 1]' * [0 1]
measure = (n, k, qubits) -> begin
       result = rand() > qubits' * lift(n, k, M₀) * qubits
       (result, normalize(lift(n, k, (result ? M₁ : M₀)) * qubits))
end
```

To measure all the bits at once we can do something like this:

```julia
measureAll = (n, qubits) -> begin
         results = []; 
         for k in 1:n
           result, qubits = measure(n, k, qubits)
           push!(results, result)
         end
         results, qubits
       end
```

It's a bit nasty but, save for a few indices, at last we can say we have completed the first feature test. So our final solution, after extracting some constants, is:

```julia
using LinearAlgebra

ZERO = Float32(1) * [1, 0]
ONE = Float32(1) * [0, 1]

eye = Matrix{Float32}(I, 2, 2)
H = Float32(1/sqrt(2)) * [1 1; 1 -1]
M₀ = ZERO * ZERO'
M₁ = ONE * ONE'

register = (n) -> foldl(kron, fill(ZERO, n))
hadamard = (n) -> foldl(kron, fill(H, n))

lift = (n, k, op) -> foldl(kron, map(it -> (it == k) ? op : eye, collect(1:n)))

measure = (n, k, qubits) -> begin
         result = rand() > qubits' * lift(n, k, M₀) * qubits
         (result, normalize(lift(n, k, (result ? M₁ : M₀)) * qubits))
       end

measureAll = (n, qubits) -> begin
         results = [];
         for k in 1:n
           result, qubits = measure(n, k, qubits)
           push!(results, result)
         end
         results, qubits
       end

toInt = (b) -> reduce((acc, v) -> 2*acc + (v ? 1 : 0), b, init=0)

qubits = hadamard(3) * register(3)
print(toInt(measureAll(3, qubits)[1]))
```

Running it to give us a random number from 0 to 7 on the console.

Before we leave it, what's the performance of this thing in its current form? Let's see:

```julia
for n in 1:11
@time print(toInt(measureAll(n, hadamard(n) * register(n))[1]))
end
```
```console
1  0.834134 seconds (1.63 M allocations: 90.474 MiB, 2.38% gc time)
0  0.063235 seconds (15.49 k allocations: 813.162 KiB)
7  0.004201 seconds (9.11 k allocations: 281.986 KiB)
11  0.002534 seconds (27.13 k allocations: 623.813 KiB)
30  0.011686 seconds (122.15 k allocations: 2.509 MiB)
7  0.023647 seconds (634.68 k allocations: 12.326 MiB)
1  0.086709 seconds (3.05 M allocations: 58.193 MiB, 5.11% gc time)
185  0.362644 seconds (14.04 M allocations: 265.855 MiB, 1.72% gc time)
237  1.746489 seconds (63.02 M allocations: 1.163 GiB, 6.29% gc time)
504  7.655970 seconds (279.03 M allocations: 5.145 GiB, 11.96% gc time)
490 31.689085 seconds (1.29 G allocations: 23.612 GiB, 4.77% gc time)
```

At just 11 bits it's taking up huge parts of my machine and far exceeding available main memory. Now we have the machinery written in Julia we can try a number of things to improve performance:

- We're using dense matrices everywhere. We can improve that by using sparse matrices where appropriate. The lifting matrix., especially, is open for conversion to a sparse matrix representation.
- Since the vectors can become quite large it makes sense to do the multiplications in-place, breaking the immutability of the functional paradigm but improving the performance and memory usage which will be very important for larger registers. May be necessary to write our own algorithm to do that using sparse matrices and dense arrays.

Also there are a number of other improvements to consider:
- We pass around the number of bits when it could be determined implicitly from the size of the arrays.
- There is no entanglement yet in our system, for that we need to define a Conditional NOT operator and for that a more sophisticated `lift` function. 

We'll cover all that in another post.

[before]: building-a-qpu-simulator-in-clojure-part-1
[last post]: building-a-qpu-simulator-in-julia-part-1
[Quko]: https://github.com/johnhearn/quko
[Julia]: https://julialang.org/
