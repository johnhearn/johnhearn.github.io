---
layout: post
asset-type: notes
name: using-julia-in-jupyter
title: Using Julia From Jupyter 
description: How to install Jupyter on Mac using Homebrew and configure it to use the Julia kernel.
date: '2019-05-05T17:30:00.000+00:00'
author: John
tags:
- julia
- jupyter

---

For Jupyter you want Python 3.7. Mac comes with 2.7 by default. To switch environments install Anaconda and then Jupyter itself:

```console
> brew cask install anaconda
...
> brew postinstall python3
...
> brew install jupyter
...
```

To use Julia inside Jupyter you need to have Julia itself installed locally, if you don't then install it with Homebrew:

```console
> brew cask install julia
...
```

To link it up then go into the Julia REPL `julia` and then import the `IJulia` package:

```julia
julia> import Pkg; Pkg.add("IJulia")
```

Then should then be able to run Jupyter `jupyter notebook` and Julia will be amongst the options when creating a new notebook.
