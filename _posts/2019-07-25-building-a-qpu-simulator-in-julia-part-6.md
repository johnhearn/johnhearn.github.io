---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-julia-part-6
title: Building a QPU simulator in Julia - Part 6
description: Building a QFT gate.
date: 2019-07-25 20:50:00 +02:00
author: John Hearn
tags:
- quantum computing
- julia

---

The [Quantum Fourier Transform](https://en.wikipedia.org/wiki/Quantum_Fourier_transform) (QFT) is an important quantum operation and an essential part of the period finding step needed for [Shor's algorithm](https://quantum-algorithms.herokuapp.com/299/paper/node1.html). It can be built as a quantum circuit but it's very easy to build its unitary matrix directly, the details are in the Wikipedia article. In Julia, this was even easier than I expected. Once we have calculated a couple of constants, we can use a 2-d `for` comprehension to create the individual elements of the array in a single line.

```julia
function qft(n)
   N = 2^n
   ω = exp(2 * π * im / N)
   a = 1 / sqrt(N)
   [a * ω^(i*j) for i in 0:N-1, j in 0:N-1]
end
```

Here $n$ is the number of bits and $N$ the size of the matrix, which as we know grows exponentially with the number of bits. $ω$ is the first complex $N^{th}$ root of unity and $a$ the normalising factor. The comprehension runs over both axis $i$ and $j$ computing the element at each position.

We can test this against the example from the Wikipedia article:

```julia
@test qft(2) ≈ 0.5 * [1 1 1 1; 1 im -1 -im; 1 -1 1 -1; 1 -im -1 im]
```

In the above it's going to generate complex numbers with Float64 precision. For our quantum gates this level of precision is not necessary and uses more memory. A few tweaks to the function will use Float32 instead.

```julia
function qft(n)
   N = 2^n
   ω = exp(2f0 * π * im / N)
   a = 1f0 / sqrt(Float32(N))
   [a * ω^(i*j) for i in 0:N-1, j in 0:N-1]
end
```

And test that it does indeed generate the correct type.

```julia
@test typeof(qft(2)) == Array{Complex{Float32},2}
```

What about the performance? Let's generate the QFT for different numbers of bits.

```console
> @time qft(11)
0.384501 seconds (6 allocations: 32.000 MiB, 11.74% gc time)
2048×2048 Array{Complex{Float32},2}

> @time qft(12)
1.469458 seconds (6 allocations: 128.000 MiB, 3.34% gc time)
4096×4096 Array{Complex{Float32},2}

> @time qft(13)
6.037579 seconds (6 allocations: 512.000 MiB, 0.74% gc time)
8192×8192 Array{Complex{Float32},2}

> @time qft(14)
25.163830 seconds (6 allocations: 2.000 GiB, 0.20% gc time)
16384×16384 Array{Complex{Float32},2}
```

The exponential increase in time and space is evident and we quickly reach practical limits. The array is dense because the values are always non-zero but since the calculation time is relatively small there could be considerable advantage using a [`ComputedArray`](https://github.com/traktofon/ComputedArrays.jl) instead of a normal array in this case.