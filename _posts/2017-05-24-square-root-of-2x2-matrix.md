---
layout: post
asset-type: notes
name: square-root-of-2x2-matrix
title: Square root of 2x2 matrix using basic algebra
date: 2017-05-24 08:22:00 +02:00
author: John Hearn
tags:
- maths

---

We want to find some matrix $B$ where $ B = \sqrt{A} $ or, equivalently, $ A = B^2 $. We take

$$ A = \begin{pmatrix}
  a & b \\
  c & d
 \end{pmatrix} $$

$$ B = \begin{pmatrix}
  a' & b' \\
  c' & d'
 \end{pmatrix} $$

Expand $B$ and equate terms.


```python
from sympy import *
init_printing()
A,a,b,c,d,e,f,g,h = symbols('A a b c d a\' b\' c\' d\'')

A = Matrix([[a,b], [c,d]])
B = Matrix([[e,f], [g,h]])

e1 = Eq(A,B**2)
e1
```




$$\left[\begin{matrix}a & b\\c & d\end{matrix}\right] = \left[\begin{matrix}a'^{2} + b' c' & a' b' + b' d'\\a' c' + c' d' & b' c' + d'^{2}\end{matrix}\right]$$




```python
solve(e1, (a,b,c,d))
```




$$\left \{ a : a'^{2} + b' c', \quad b : b' \left(a' + d'\right), \quad c : c' \left(a' + d'\right), \quad d : b' c' + d'^{2}\right \}$$



We can calculate the determinant $A$ and $B^2$ (confirming that $det(B^2) = det(B)^2$)


```python
Eq(A.det(), factor((B**2).det()))
```




$$a d - b c = \left(a' d' - b' c'\right)^{2}$$



We can also calculate the trace of $A$ and $B^2$ $$ trace(A) = trace(B^2)$$


```python
Eq(A.trace(), (B**2).trace())
```




$$a + d = a'^{2} + 2 b' c' + d'^{2}$$



But from the equation for the determinant we know that $$ ad-bc=(a'd'-b'c')^2 $$ or $$b'c' = a'd'-\sqrt{ad-bc}$$ so $$ a+d = a'^2 + 2a'd' \pm 2\sqrt{ad-bc} +d'^2$$ $$a+d = (a'+d')^2 \pm 2\sqrt{ad-bc}$$ so $$ trace(B) = a'+d' = \pm \sqrt{a+d \pm 2\sqrt{ad-bc}} = \pm \sqrt{trace(A) \pm 2\sqrt{det(A)}}$$

Giving 4 solutions. Using these two relations we can calculate the expressions for $a'$,$b'$, $c'$ and $d'$ in terms of $a$, $b$, $c$ and $d$. For example, $$b=b'(a'+d')$$ $$b=b'(\pm \sqrt{a+d \pm 2\sqrt{ad-bc}})$$ $$b'=\pm \frac{b}{\sqrt{a+d \pm 2\sqrt{ad-bc}}}$$ etc...
