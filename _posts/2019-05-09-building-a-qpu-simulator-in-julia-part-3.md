---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-julia-part-3
title: Building a QPU simulator in Julia - Part 3
description: Improving performance.
date: 2019-05-24 08:22:00 +02:00
author: John Hearn
tags:
- quantum computing
- julia

---

In the [last post] we were able to build a functional quantum register and used it to create a simple circuit for a [quantum random number generator](quantum-random-number-generator). It worked directly with registers up to about 11 bits when the amount of memory required to represent the operations on the register surpassed the available resources.

This short post is to see if we can improve the simple functions we wrote to increase the performance.

The first obvious thing to try is to use sparse matrices instead of dense ones. This is especially important when lifting the operators over large registers because the dense matrices are full of zeros. For example take a hadamard operator lift into the 2rd position of a 3-bit register. The lifted matrix becomes:

```console
julia> lift(3, 2, H)
8×8 Array{Float32,2}:
 0.707107  0.0        0.707107   0.0       0.0       0.0        0.0        0.0     
 0.0       0.707107   0.0        0.707107  0.0       0.0        0.0        0.0     
 0.707107  0.0       -0.707107  -0.0       0.0       0.0       -0.0       -0.0     
 0.0       0.707107  -0.0       -0.707107  0.0       0.0       -0.0       -0.0     
 0.0       0.0        0.0        0.0       0.707107  0.0        0.707107   0.0     
 0.0       0.0        0.0        0.0       0.0       0.707107   0.0        0.707107
 0.0       0.0       -0.0       -0.0       0.707107  0.0       -0.707107  -0.0     
 0.0       0.0       -0.0       -0.0       0.0       0.707107  -0.0       -0.707107
```

This matrix has a high density of zeros, something which indicates that a sparce representation may be better. Luckily [Julia] includes support for sparce matrices as part of the `SparseArrays` package and then we can simply start creating sparse matrices with a couple of simple changes:

```julia
using SparseArrays

ZERO = sparsevec([1], [1f0], 2)
ONE = sparsevec([2], [1f0], 2)

eye = sparse(I, 2, 2)
```

```console
julia> lift(3, 2, H)
8×8 SparseMatrixCSC{Float32,Int64} with 16 stored entries:
  [1, 1]  =  0.707107
  [3, 1]  =  0.707107
  [2, 2]  =  0.707107
  [4, 2]  =  0.707107
  [1, 3]  =  0.707107
  [3, 3]  =  -0.707107
  [2, 4]  =  0.707107
  [4, 4]  =  -0.707107
  [5, 5]  =  0.707107
  [7, 5]  =  0.707107
  [6, 6]  =  0.707107
  [8, 6]  =  0.707107
  [5, 7]  =  0.707107
  [7, 7]  =  -0.707107
  [6, 8]  =  0.707107
  [8, 8]  =  -0.707107
```

We have reduced the memory footprint of the matrix by a factor of 4. In fact the saving is exponential: a $$2^n \times 2^n$$ array becomes a sparse representation with $$2^{n+1}$$ entries. 

Trying the same benchmark again gives us much better results:

```julia
for n in 1:11
@time print(toInt(measureAll(n, hadamard(n) * register(n))[1]))
end
```
```console
0  0.000075 seconds (23 allocations: 1.047 KiB)
3  0.000034 seconds (41 allocations: 1.969 KiB)
0  0.000019 seconds (51 allocations: 3.016 KiB)
15  0.000029 seconds (73 allocations: 5.516 KiB)
12  0.000030 seconds (84 allocations: 11.422 KiB)
46  0.000038 seconds (102 allocations: 31.031 KiB)
62  0.000103 seconds (119 allocations: 102.750 KiB)
143  0.000190 seconds (134 allocations: 374.313 KiB)
301  0.000605 seconds (150 allocations: 1.396 MiB)
130  0.002381 seconds (159 allocations: 5.463 MiB)
666  0.016114 seconds (202 allocations: 21.679 MiB)
```

Lets see how far we can go...

```julia
for n in 12:16
@time print(toInt(measureAll(n, hadamard(n) * register(n))[1]))
end
```
```console
1131  0.064576 seconds (199 allocations: 85.922 MiB)
430  0.296749 seconds (252 allocations: 342.593 MiB)
12847  1.547630 seconds (285 allocations: 1.336 GiB, 32.59% gc time)
24906  4.267627 seconds (317 allocations: 5.340 GiB, 4.51% gc time)
63277 39.087846 seconds (787 allocations: 21.372 GiB, 6.12% gc time)
```

It turns out that we've improved the performance by a factor of about 32! Not a bad for a 3 line change :)

There are more things to do like in-place multiplications but I'd like to implement some of the standard algorithms first to compare performance in more varied circumstances. That'll be for next time.


[before]: building-a-qpu-simulator-in-clojure-part-2
[last post]: building-a-qpu-simulator-in-julia-part-2
[Quko]: https://github.com/johnhearn/quko
[Julia]: https://julialang.org/
