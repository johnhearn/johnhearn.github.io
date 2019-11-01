---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-julia-part-7
title: Building a QPU simulator in Julia - Part 7
description: Using Julia to build the classical part of Shor's Algorithm.
date: 2019-07-26 11:50:00 +02:00
author: John Hearn
tags:
- quantum computing
- julia

---

Unlike Deutsch's algorithm, which merely shows the possibility of quantum speed-up but isn't of any practical use, [Shor's algorithm](https://quantum-algorithms.herokuapp.com/299/paper/node1.html) has considerable practical applications. Indeed it excites many people because it could potentially be used to break much of the secure online communications which are used today.

Using tools from number theory, the algorithm consists of a procedure which transforms the problem of prime factorings into a problem of period finding. The advantage of this is that the period finding part, which is exponentially hard on classical computers, can be implemented efficiently (i.e. in polynomial time) with a quantum computer.

The details of the algorithm can be found across the internet. Here's a [video of a talk](https://www.youtube.com/watch?v=8EcLYB6VD4s) by James Birnie but I recommend you to also look for your own research material. There's some non-trivial maths going on and it's not easy to understand all of the different elements involved in the algorithm. It helps to read multiple different tutorials and explanations.

Anyway, for the moment, let's just implement the classical parts in Julia. It turns out to be quite simple. These are the steps:

- Step 1: choose a random number 1 < a < N
- Step 2: find r, the period of $a^x (mod N)$ with respect to x
- Step 3: check that r is even and $a^{r/2}+1 \neq 0 (mod N)$
- Step 4: calculate the factors (p,q) as
    $p = gcd(a^{r/2}-1, N)$
    $q = gcd(a^{r/2}+1, N)$


Obviously before we can do anything we need a number to factor. Let's use 37 * 41 = 1517.

```julia
# Number to factor, a multiple of two prime factors > 2
N = 1517
```

The first step is to choose a random number $a < N$. Also we don't want to use the degenerate case of $1$.

```julia
a = BigInt(rand(2:N))
```

We use Julia's arbitrary precision integers (`BigInt`s) because the exponents get very big very quickly and even 64 bit integers will likely overflow.

The next step is to find the period, say $r$, of $a^x mod N$ with respect to $x$. This is the operation that will be done with a quantum computation. For now we'll do it with a brute force approach but remember that this would be prohibitively time-consuming when the number to factor is large.

```julia
r = 1
while a^r % N != 1 && r < N
    global r
    r = r + 1
end
```

After running the above code let's look at the results:

```julia
> @show N, a, r
(N, a, r) = (1517, 1371, 180)
```

So we have our period, 180. Lucky we used arbitrary precision integers, $1371^{180}$ is a very, very big number!

Next, for the calculation to work we need to check that the period is even and that: $a^{r/2}+1 \neq 0 (mod N)$. If it isn't then we just try again with another value for $a$.

```julia
if r % 2 == 0 && a^(r>>1) % N != 0
   ...
end
```

Finally we calculate the factors, $p$ and $q$. Julia gives us an implementation of the greatest common divisor algorithm as part of its base functions, so no need to worry about that. The factors are $p=gcd(a^{r/2}-1, N)$ and $q=gcd(a^{r/2}+1, N)$. To keep the types as integers we can use the bit shift operator rather then dividing by 2. In Julia this is simply:

```julia
    p = gcd(a^(r>>1)-1, N)
    q = gcd(a^(r>>1)+1, N)
```

So what's the result?

```julia
> @show p, q
(p, q) = (41, 37)
```

Which are the numbers we first thought of!

Right, that's the easy part and with Julia it was very straightforward due to the native arbitrary precision integers and exponent operators. The hard part is the actual quantum algorithm which we'll come back to in a later post.

So here's the classical algorithm ion it's entirety. There are some edge case that are not being checked but this is basically it.

```julia
# Number to factor, a multiple of two prime factors > 2
N = 1517

# Step 1: choose a random number 1 < a < N
a = BigInt(rand(2:N))

# Step 2: find r, the period of a^x mod N
r = 1

while a^r % N != 1 && r < N
    global r
    r = r + 1
end

@show N, a, r

# Step 3: check that r is even and a^(r/2)+1 != 0 mod N
if r % 2 == 0 && a^(r>>1) % N != 0

    # Step 4: calculate the factors
    p = gcd(a^(r>>1)-1, N)
    q = gcd(a^(r>>1)+1, N)

    @show p, q
end
```
