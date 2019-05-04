---
layout: post
asset-type: notes
name: cobol-for-fun-and-profit
title: COBOL for Fun and Profit 
description: Random question - Can we compile and run COBOL on a Mac? Yes, of course.
date: '2019-05-03T22:30:00.000+00:00'
author: John
tags:
- cobol

---

I'm lucky enough to have worked in many different areas of the IT industry and several times I've crossed paths with COBOL both in the public and the financial sectors. There is no doubt that, in spite of the total absence of COBOL from Stack Overflow’s annual [Developer Survey](https://insights.stackoverflow.com/survey/2019#technology-_-programming-scripting-and-markup-languages), it's still very much alive, and it's behind a [staggering amount](http://fingfx.thomsonreuters.com/gfx/rngs/USA-BANKS-COBOL/010040KH18J/index.html) of the systems that our society relies on - banking, insurance and central government, to name a few.

After seeing [an article](https://increment.com/programming-languages/cobol-all-the-way-down/) come up again on the subject it got me thinking about its title caption: *how long can it be maintained?* Or, more concretely, *can I compile and run a COBOL program on my laptop?* I'd only ever see it running on Mainframes behind green-screen terminals and choose-your-own-adventure-style [TSO](https://www.ibm.com/support/knowledgecenter/zosbasics/com.ibm.zos.zconcepts/zconc_whatistso.htm) screens. Well, it turns out the answer is YES, and in fact it's very simple. This is how I did it.

## GnuCOBOL

[GnuCOBOL](https://sourceforge.net/projects/open-cobol/) compiles COBOL to executable binaries. It actually does this by transpiling to C but that doesn't really concern me.

First we need to install the compiler. You can just do:

```console
> brew install gnu-cobol
```

Seriously, it's that easy.

Now, to edit our COBOL programs do we have to resort to some archaic editor? Well, not unless you think VS Code is archaic. It has a 
[COBOL Plugin](https://marketplace.visualstudio.com/items?itemName=bitlang.cobol) with syntax highlighting and autocomplete. 

![COBOL in VS Code](/assets/images/vscode-cobol.png)


This is a basic "Hello World!" program for COBOL taken from the article:

<pre style="font-family:IBM3720;">
000100 IDENTIFICATION DIVISION.
000200 PROGRAM-ID. HELLO-WORLD.
000300 PROCEDURE DIVISION.
000400      DISPLAY 'Hello, world!'.
000500      STOP RUN.

</pre>

We can now compile it to a executable binary and run it directly:
```console
> cobc -x hello.cob
> ./hello
Hello, world!
```

Mission completed. Really much simpler that I had expected.

So, if we can take COBOL and compile it to native binaries then couldn't we take, for example, existing CICS transactions written for standard mainframes and deploy them as services, for example, in a [serverless](serverless-is-the-new-mainframe) environment?

So in answer to the question: *how long can it be maintained?*, based on what I've seen the answer is probably, for better or worse, *indefinitely*.