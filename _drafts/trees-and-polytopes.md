---
layout: post
asset-type: post
name: trees-and-polytopes
description: Some notes about the similarities between the tensor product and cross-polytopes.

---

[Kronecker products](https://en.wikipedia.org/wiki/Kronecker_product) of block matrices naturally form a tree structure where each element in the result is the product of the nodes of the tree from root to branch. Take, for example the simplest non-trivial case.

$$
\left( \begin{array}{c}
    a \\
    b
\end{array} \right)
\bigotimes
\left( \begin{array}{c}
    c \\
    d
\end{array} \right)
=
\left( \begin{array}{c}
    a \left( \begin{array}{c}
             c \\
             d
      \end{array} \right) \\
    b \left( \begin{array}{c}
             c \\
             d
      \end{array} \right)
\end{array} \right)
=
\left( \begin{array}{c}
    ac \\
    ad \\
    bc \\
    bd
\end{array} \right)
$$

The product is non-commutative however in the case of real or complex elements the result is *permutation equivalent*, that is, since the order of multiplication of each element ($$ac=ca$$) is not important, the resulting vector contains the same elements in a different order.

This structure is isomorphic to the family of [cross-polytope](https://en.wikipedia.org/wiki/Cross-polytope)s. Here is the skeletal graph of the 4 element cross-polytope (a square).

{% graphviz %}
digraph "4-element tree" {
  a->c
  c->a
  
  a->d
  d->a
  
  b->c
  c->b

  b->d
  d->b
}
{% endgraphviz %}

Likewise the three element product (an octahedron):

$$
\left( \begin{array}{c}
    a \\
    b
\end{array} \right)
\bigotimes
\left( \begin{array}{c}
    c \\
    d
\end{array} \right)
\bigotimes
\left( \begin{array}{c}
    e \\
    f
\end{array} \right)
=
\left( \begin{array}{c}
    ace \\
    acf \\
    ade \\
    adf \\
    bce \\
    bcf \\
    bde \\
    bdf
\end{array} \right)
$$

{% graphviz %}
digraph G {
  a->c
  c->e
  e->a
  a->c
  c->f
  f->a
  a->d
  d->e
  e->a
  a->d
  d->f
  f->a
  b->c
  c->e
  e->b
  b->c
  c->f
  f->b
  b->d
  d->e
  e->b
  b->d
  d->f
  f->b
}
{% endgraphviz %}

And for good measure this is the graph for the 4 element product (the 16-cell):

{% graphviz %}
digraph G {
  a->c
  c->e
  e->g
  g->i
  i->a
  a->c
  c->e
  e->g
  g->j
  j->a
  a->c
  c->e
  e->h
  h->i
  i->a
  a->c
  c->e
  e->h
  h->j
  j->a
  a->c
  c->f
  f->g
  g->i
  i->a
  a->c
  c->f
  f->g
  g->j
  j->a
  a->c
  c->f
  f->h
  h->i
  i->a
  a->c
  c->f
  f->h
  h->j
  j->a
  a->d
  d->e
  e->g
  g->i
  i->a
  a->d
  d->e
  e->g
  g->j
  j->a
  a->d
  d->e
  e->h
  h->i
  i->a
  a->d
  d->e
  e->h
  h->j
  j->a
  a->d
  d->f
  f->g
  g->i
  i->a
  a->d
  d->f
  f->g
  g->j
  j->a
  a->d
  d->f
  f->h
  h->i
  i->a
  a->d
  d->f
  f->h
  h->j
  j->a
  b->c
  c->e
  e->g
  g->i
  i->b
  b->c
  c->e
  e->g
  g->j
  j->b
  b->c
  c->e
  e->h
  h->i
  i->b
  b->c
  c->e
  e->h
  h->j
  j->b
  b->c
  c->f
  f->g
  g->i
  i->b
  b->c
  c->f
  f->g
  g->j
  j->b
  b->c
  c->f
  f->h
  h->i
  i->b
  b->c
  c->f
  f->h
  h->j
  j->b
  b->d
  d->e
  e->g
  g->i
  i->b
  b->d
  d->e
  e->g
  g->j
  j->b
  b->d
  d->e
  e->h
  h->i
  i->b
  b->d
  d->e
  e->h
  h->j
  j->b
  b->d
  d->f
  f->g
  g->i
  i->b
  b->d
  d->f
  f->g
  g->j
  j->b
  b->d
  d->f
  f->h
  h->i
  i->b
  b->d
  d->f
  f->h
  h->j
  j->b
}{% endgraphviz %}

### I'm wondering if this fact could be used to generate more efficient data types for the tensor producto of sparse matrices which are found in quantum computing simulators.

Or maybe not :)

----

### Nasty code for generating the graphs

```java
import java.util.List;

import static java.util.Arrays.asList;

class Scratch {
    public static void main(String[] args) {
        List<String> lhs = asList("a", "b");
        List<String> mid = asList("c", "d");
        List<String> rhs = asList("e", "f");
//        List<String> kin = asList("g", "h");
//        List<String> nom = asList("i", "j");
        for (String l : lhs) {
            for (String m : mid) {
                for (String r : rhs) {
  //                  for (String k : kin) {
 //                       for (String n : nom) {
                            System.out.println("  " + l + "->" + m);
                            System.out.println("  " + m + "->" + r);
   //                         System.out.println("  " + r + "->" + l);
   //                         System.out.println("  " + k + "->" + n);
   //                         System.out.println("  " + n + "->" + l);
                        }
                    }
                }
//            }
//        }
    }
}
```