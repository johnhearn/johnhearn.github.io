---
layout: post
asset-type: notes
name: building-a-quantum-simulator-from-scratch-part-1
title: Building a QPU simulator in Clojure - Part 1
description: First steps in building a quantum CPU simulator with Clojure and TDD.
date: 2019-01-27 16:52:00 +00:00
author: John Hearn
tags:
- quantum computing
- tdd

---

 [Last year](quantum-computing-primer-part-1a) I started looking into quantum computing{% sidenote physics "If you happen to be a physics graduate and a programmer (there are more of us than you might think) then I guess it's natural that you'll eventually look into quantum computing at some point." %} and the result was [Quko], a naïve quantum computer simulator written in Kotlin. If there's one thing I learned from that project it's that there is no better way to learn how something works than by writing a simulator for it: it turned out that things that I thought I understood in fact I didn't until getting in to the nitty-gritty.

Quko worked out pretty well and I was able to repeat some of the standard results with a small number of qubits. A naïve implementation will never be particularly efficient but I didn't really care as that wasn't the goal. Not long ago, however, I stumbled upon a Clojure library called [Neanderthal](https://neanderthal.uncomplicate.org/){% sidenote clojureaitalk "From [this](https://www.youtube.com/watch?v=um2uq5oURT8) talk where they're using Neanderthal for processing large neural networks." %} for doing high performance mathsy stuff and after playing with it for a while I was impressed by how easy it was to get started{% sidenote naming "although not so much with its naming conventions :/" %}. Since I'm also learning Clojure I thought I'd rewrite Quko in Clojure to practice the language and get a more powerful simulator to boot. This blog series will be my way of remembering what I did, the mistakes and the successes along the way. 

We'll start with a simple case of an 8-sided [quantum die](quantum-random-number-generator). This is the code written with the Quko library (from the [README](https://github.com/johnhearn/quko)):

```kotlin
val qubits = Qubits(3).hadamard(0..2)
print(qubits.measureAll().toInt())
```

Written in Clojure this becomes{% sidenote h "Note I've changed the name of the Hadamard operator to H which is acceptable in Clojure and more consistent with the QC literature." %}:

```clojure
(def qubits (H (Qubits 3) (range 0 2)))
(print (to-int (measure-all qubits)))
```

Obviously this doesn't compile because we've not written any code yet (see appendix) so lets start building out the implementation with unit tests. In fact we will start with a very simple test for a single qubit which ensures that its default value is 100% `true`. Remember qubits are probabilistic animals but we don't want to expose the underlying implementation to the outside world. For that reason in the test we'll take a count of multiple samples and compare the result with what's expected rather than interrogating the qubit's internals directly.

```clojure
(ns qucl.qubits_test
  (:require [clojure.test :refer :all]
            [qucl.qubits :refer :all]))

(defn sample [source-function num-samples]
  (count (filter true? (repeatedly num-samples source-function))))

(deftest measure-should
  (is (= 0 (sample-qubit #(measure (Qubit)) 100)))
```

We can make that pass trivially, of course, just returning `0` from `measure`. 

```clojure
(defn Qubit [])

(defn measure [qubit] false)
```

Next we'll triangulate to get some more behaviour. The simplest way to do that is to apply a `not` or `X` operation{% sidenote not-gate "The so called [Pauli-X gate](https://en.wikipedia.org/wiki/Quantum_logic_gate#Pauli-X_gate)." %} and expect the opposite result. 

```clojure
  (is (= 100 (sample-qubit #(measure (X (Qubit))) 100))))
```

The easiest way to make this pass is to make `Qubit` have a binary value and negate it.

```clojure
(defn Qubit [] false)

(defn X [qubit]
  (not qubit)

(defn measure [qubit]
  qubit)
```

The tests pass. One nice thing about Clojure is that we can also take advantage of the REPL to try our code. In this case we get the answers we expect.

```clojure
(measure (Qubit))
=> 0
(measure (X (Qubit)))
=> 1
(measure (X (X (Qubit))))
=> 0
```

Now we have our tests passing we can introduce some theory. The qubit is a structure with two (possibly complex) variables{% sidenote hilbert "A so called Hilbert space, $$ \\mathcal{H}_2 $$." %}, the absolute values of which are the probabilities of measuring `0` or `1` respectively. For the moment the variable will only need real values and is represented by two real numbers `:0` and `:1`. This could be considered a vector with named indices. The `X` operation swaps the variables so the probability of measuring `0` becomes the probability of measuring `1` and vice-versa. 

```clojure
(defn Qubit []
  {:0 1.0 :1 0.0})

(defn X [qubit]
  {:0 (:1 qubit) :1 (:0 qubit)})
```

The measurement will now be a random process which picks `0` or `1` with the appropriate frequency. The probability of measuring a `0` is `|:0|`$$ ^2 $$.

```clojure
(defn- prob-zero [qubit]
  (* (:0 qubit) (:0 qubit)))

(defn measure [qubit]
  (if (<= (rand) (prob-zero qubit)) false true))
```

The implementation of `X` is a degenerate case of a more general fact. One of the central tenets of quantum operators or *gates* is that they can be represented by matrix multiplication{% sidenote representation "As can any operator according to [representation theory](wiki)." %}. Let's do it that way so that we can slot in other gates much more easily. We define a matrix which inverts the two numbers:

$$
X = \left( \begin{array}{c}
      0 & 1 \\
      1 & 0 \\
    \end{array} \right)
$$

And a test to ensure that our code does indeed invert the entries:

```clojure
(def X {:00 0 :01 1 :10 1 :11 0})

(deftest matrix-mult-test
  (is (= (matrix-mult X {:0 0 :1 1})
         {:0 1 :1 0})))
```

An implementation of that using the normal rules of matrix multiplication would be:

```clojure
(defn matrix-mult [A x]
  {
    (+ (* (:00 A) (:0 x)) (* (:01 A) (:1 x)))
    (+ (* (:10 A) (:0 x)) (* (:11 A) (:1 x)))
  })
```

Now we can reimplement the `X` function using our matrix:

```clojure
(defn X [qubit]
  (matrix-mult {:00 0 :01 1 :10 1 :11 0} qubit))
```

Great. The tests are still passing and we are now in a position to add new gates, for example the very useful [Hadamard](https://en.wikipedia.org/wiki/Quantum_logic_gate#Hadamard_(H)_gate) (H) gate that we need for the die. The Hadamard gate takes the qubit to the equator of the Bloch Sphere and, since it's unitary, applying it twice takes us back to the start. We can capture that in a test{% sidenote testing-internal-state "Strictly speaking this is not a very good test. There are an infinite number of ways to make this it pass but it's good enough for now." %}:

```clojure
(deftest measure-should
  (is (= 50 (sample 100 #(measure (H (Qubit))))))
  (is (= 0 (sample 100 #(measure (H (H (Qubit))))))))
```

In this case the matrix for the transformation (still real numbers) is:

$$
H = \frac{1}{\sqrt{2}} 
    \left( \begin{array}{c}
      1 & 1 \\
      1 & -1 \\
    \end{array} \right)
$$

We can implement it, for example, in this way.

```clojure
(def ^:const oosr2 (/ 1 (Math/sqrt 2)))
(defn H [qubit]
  (matrix-mult {:00 oosr2 :01 oosr2 :10 oosr2 :11 (- oosr2)} qubit))
```

OK, so we have built our Qubit and a couple of gates, X and H, to manipulate it. With this code we've advanced quite a bit and can already simulate a quantum coin toss. In the REPL we can do:

```clojure
(defn coin-toss [] 
  (measure (H (Qubit))))
=> #'qucl.qubits/coin-toss
(coin-toss)
=> true
(repeatedly 10 coin-toss)
=> (false false false false true true true true false false)
```

Going back to the original feature test, we can also now simulate an 8-sided die simply by tossing a coin 3 times and interpreting the result as binary. We could do this in the REPL:

```clojure
(defn to-int [& b]
  (reduce (fn [acc v] (+ (* 2 acc) (if v 1 0)))
          0
          b))
=> #'qucl.qubits/to-int
(apply to-int (repeatedly 3 coin-toss))
=> 7
(apply to-int (repeatedly 3 coin-toss))
=> 3
```

Not a bad start but there's still a lot to do. To implement our feature test completely we need to be able to combine Qubits. We've some way to go and the next steps will be to introduce Neanderthal and complex numbers but I'll leave that for [next time](building-a-qpu-simulator-in-clojure-part-2).

<br>

----

## Appendix

To make the our feature test compile we can use stub implementations which just throw exceptions, for example:

```clojure
(defn to-int [qubits]
  (throw (UnsupportedOperationException)))
```

This isn't as necessary in Clojure as other JVM based languages because we tend to use the REPL to run just the parts that we need. I don't have a strong opinions about the best workflow for TDD in Clojure yet, I guess it's personal and may depend on your preferred tooling.

[Quko]: https://github.com/johnhearn/quko