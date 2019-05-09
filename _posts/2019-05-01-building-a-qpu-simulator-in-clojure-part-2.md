---
layout: post
asset-type: notes
name: building-a-qpu-simulator-in-clojure-part-2
title: Building a QPU simulator in Clojure - Part 2
description: Adding Neanderthal and complex numbers.
date: 2019-05-01 09:52:00 +00:00
author: John Hearn
tags:
- quantum computing
- tdd
- clojure

---

In the [last post](building-a-qpu-simulator-in-clojure-part-1) we simulated a single qubit and a couple of simple gates. Using those gates we could implement a trivial coin toss function and an 8-sided die. Now we'll go on to incorporate the Neanderthal library before implementing more gates with complex matrices.

First let's make the leap to Neanderthal so that it can do our matrix manipulations for us. It turns out to be quite straight forward. The first step is to add the dependency:

```clojure
(defproject qucl "0.1.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.10.0"]
                 [uncomplicate/neanderthal "0.23.1"]]

  :exclusions [[org.jcuda/jcuda-natives :classifier "apple-x86_64"]
               [org.jcuda/jcublas-natives :classifier "apple-x86_64"]])
```

A couple of the libraries required by Neandertal don't have native builds for Mac in the standard repositories which gives us dependency errors. Since their not needed right now, we can safely exclude them.

To work with Neanderthal the Qubit will be a vector of floating point numbers `fv`, rather than a map. The choice of floats rather than doubles is deliberate, floats are faster but, more importantly, take up less memory than doubles and the exponential nature of quantum vectors means that quantum simulators tend to be memory bound.

```clojure
(defn Qubit []
  (fv 1.0 0.0))
```

For the measurement we'll just use the first entry of the vector:

```clojure
(defn- prob-zero [qubit]
  (* (entry qubit 0) (entry qubit 0)))
```

And for the gates we'll use Neanderthal's built-in matrix multiplication functions, in this case multiplying a dense matrix (created with the `fge` function) with the qubit vector using the `mv` function. For example or X gate becomes:

```clojure
(defn X [qubit]
  (mv (fge 2 2 [0 1 1 0]) qubit))
```

And the Hadamard gate is similar but scaling with the *in-place* `scal!` function:

```clojure
(defn H [qubit]
  (mv (scal! oosr2 (fge 2 2 [1 1 1 -1])) qubit))
```

With these changes the tests continue to function without change and we've been able to remove own own linear algebra implementation and replace it with Neanderthal instead. Happy with that.

The next step is to build some more gates but for that we'll need to use complex numbers. Essentially a quantum computing simulation is linear algebra using complex variables. Neanderthal is a fast and efficient linear algebra library but it uses doubles and floats as approximations of reals so we need a way to manipulate complex vectors and matrices. How can we use Neanderthal to do that? Well first note that a complex vector can be separated into real and imaginary parts. We can take a pair of matrices or vectors and store them in a simple map of real and imaginary values.

```clojure
(defn- complexify
  ([real]
   {:real real :imag (zero real)})
  ([real imag]
   {:real real :imag imag}))
```

 If we receive only one initial value then assume it's the real part and set the imaginary part to zero. Once we have the separate real and imaginary values we can multiply, for example `A` and `x` like this:

$$
A x = (A_r + A_i i)(x_r + x_i i)
= (A_r x_r - A_i x_i) + (A_r x_i + A_i x_r) i
$$

In computational terms, that's four floating point multiplications and three floating point additions. We can take advantage of Neanderthal's compound add and multiply function `axpv` as well. Let's see what that looks like in code:

```clojure
(defn- complex-mv [A x]
  (complexify (axpy -1 (mv (:imag A) (:imag x)) (mv (:real A) (:real x)))
              (axpy (mv (:real A) (:imag x)) (mv (:imag A) (:real x)))))
```

A bit complicated but there is a lot of symmetry there. We use the new `complexify` function to convert the Qubit along with the H and X operators into complex valued functions:

```clojure
(defn Qubit []
  (complexify (fv 1.0 0.0)))

(defn X [qubit]
  (complex-mv (complexify (fge 2 2 [0 1 1 0])) qubit))

(defn H [qubit]
  (complex-mv (complexify (scal! oosr2 (fge 2 2 [1 1 1 -1]))) qubit))
```

Also the probability calculation must be adapted to calculate the absolute value of a complex number:

```clojure
(defn- sqr [x] (* x x))
(defn- prob-zero [qubit]
  (+ (sqr (entry (:real qubit) 0)) (sqr (entry (:imag qubit) 0))))
```

Our tests are passing again using the new complex implementation. So far so good. We're now in a position to implement some other gates. But we have a problem. Neanderthal doesn't have a mechanism for performing the Krondecker product and we'll need that for creating the composite operators. Not sure what to do about that so I'm going to leave it there for now until I come up with a better plan ;)


[Quko]: https://github.com/johnhearn/quko