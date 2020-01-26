---
layout: post
asset-type: notes
name: grovers-search-algorithm
title: Grover's Search Algorithm
description: At last, a potentially useful quantum algorithm.
date: 2018-10-03 07:12:00 +00:00
author: John Hearn
tags:
- quantum computing

---

Grover's algorithm is actually useful{% marginnote useful "Useful, at least, if we had more real qubits available for processing. That is to say reaching quantum supremacy. All of these examples only make sense when scaled to hundreds of qubits. We currently have just a few dozen at most, not counting for error correction. " %}. It can quickly find configurations of bits matching some predefined criteria. Let's take an absurdly simple example and find the bit sequence matching a given number.

```kotlin
assertEquals(0b1011, groversSearch(4) {it == 0b1011})
```

The algorithm itself starts in a similar way to Deutsch's algorithm, namely that it takes n bits and an additional _ancillary_ bit and performs a hadamard operation on all of them. Intuitively this prepares the bits by putting them in an unbiased superposition, that is, so to speak, half `1` and half `0`.

In quko this looks like before:

```kotlin
val phi = Qubits(n, random).hadamard(0 until n)
```

The next step, also mirroring Deutsch's algorithm, is to apply the oracle, $$U_f$$, followed by another hadamard operation to the first n bits. Next we apply a new gate which is specially prepared for this circuit and we follow that by another hadamard gate. The last three gates are repeated several times to refine the result. The whole process is summarised this this diagram:

![grovers-circuit](/assets/images/quantum-computing/grovers-circuit.png)

In quko code this looks like this:

```kotlin
repeat(iterations) {
    phi.apply(0, oracle).hadamard(0 until n).apply(0, special).hadamard(0 until n)
}
```

where `iterations` is calculated as $$ \sqrt{2^n} $$. The `special` operator is calculated from the formula $$ 2\vert 0^n \rangle \langle 0^n \vert -I_n $$ first by expanding $$ \vert 0^n \rangle $$ (`zeron`) and then performing the outer product on itself (`outer`).

```kotlin
private fun diffusion(n: Int): ComplexMatrix {
    val zeron = (0 until n-1).fold(ZERO) { acc, _ -> acc kronecker ZERO }
    val outer = zeron outer zeron
    return 2.0 * outer - identity(pow2(n))
}
```

Finally we measure the result:

```kotlin
phi.measureAll().toInt()
```

