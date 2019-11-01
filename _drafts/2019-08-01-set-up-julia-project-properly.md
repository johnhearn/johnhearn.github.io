---
layout: post
asset-type: notes
name: set-up-julia-project-properly
title: Setup a Julia Project Properly
description: How to create a project with standard structure, tests and documentation.
date: 2019-08-01 09:25:00 +01:00
author: John Hearn
tags:
- julia

---

I'm realising that it's time to get a bit serious with Julia. The REPL is great but at a certain point you want to be able to run the tests easily, generate documentation, etc. etc.

There is a project called [PkgTemplates.jl](https://invenia.github.io/PkgTemplates.jl/stable/) which can help us. From the docs:

```julia
pkg> add PkgTemplates
...
julia> using PkgTemplates
...

```

