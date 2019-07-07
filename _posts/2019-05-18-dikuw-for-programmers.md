---
layout: post
asset-type: article
name: dikuw-programmer
title: DIKUW for Programmers
description: An explanation for programmers. 
date: '2019-07-07T18:30:00.000+00:00'
author: John
tags:
- semiotics

---

One of the most interesting models that I've seen in recent months is from a talk on [Systems Thinking](https://youtu.be/EbLh7rZ3rhU) by [Dr. Russell Ackoff](https://en.wikipedia.org/wiki/Russell_L._Ackoff). It's variously called the [DIKW Pyramid](https://en.wikipedia.org/wiki/DIKW_pyramid) (a mneumonic for **D**ata, **I**nformation, **K**nowledge, **W**isdom) or the Information Chain, amongst many other names. Dr. Ackoff also includes a category called “**U**nderstanding” which is avoided under some philosophical treatments but I'll include it because I think it provides valuable insight. Hence and henceforth I'll call it the **DIKUW** model. 

It's one of those models which is hard to describe but easy to grasp. In a nutshell it's this:

Data⇒Information⇒Knowledge⇒Understanding⇒Wisdom

How each of these layers is interpreted varies. I’m going to try and approach it from three angles: as a programmer with programming constructs, with de Bono’s Mechanics of Mind model and, finally, from an AI perspective. 

This first post treats it as a programmer.

## Data
Imagine a random area of a memory chip full of transistors, each either on or off. One might suppose that those states mean something to someone but without any context it remains data and, actually,  **does not provide information at all**. 

That may seem counter intuitive because we are used to seeing data as information but, thinking about it, it can't be. First, we don't even know if it is a complete representation of anything. It's just a state with no context. It might as well, in fact, be random{% sidenote extraction "We may be able to apply techniques from the higher levels to extract more data from the data: average, variance, repeating patterns, etc. but until we apply the higher levels the data remains data." %}.

Often, as programmers we confuse data with information and pay the price with bugs and errors, as we'll see in a moment.

## Information
Let's say we have observed the state of our transistors somehow and we know which states represent either 0s or 1s, and we know it's an 8-bit representation. Then our random piece of RAM might look like this:

```
01101100 01101001 01100110 01100101 11100010 10000110 10010000 01111011 
11100010 10000110 10010001 00110001 00100000 11100010 10001101 10110101 
11100010 10001000 10101000 00101110 11100010 10001000 10100111 00110011 
00100000 00110100 00111101 00101011 00101111 00101100 11000010 10101111 
00110001 00100000 00110000 00100000 00110001 11100010 10001000 10011000 
00101110 11100010 10001010 10010110 11000010 10101111 00110001 00100000 
00110000 00100000 00110001 11100010 10001000 10011000 00101110 11100010 
10001100 10111101 11100010 10001010 10000010 11100010 10001101 10110101 
01111101 00001101 00001010
```

So we have some information. Hurray! Or do we? Actually no. We're still missing context. Is it part of the Chemical Brothers’ new album or an amusing cat video? 

Let's say someone tells me it's text. OK, great, no problem. *Looks online for binary text converter.*  This means we really do have some information, right?

```
lifeâ{â1 âµâ¨.â§3 4=+/,Â¯1 0 1â.âÂ¯1 0 1â.â½ââµ}
```

Ups, something is still wrong. Nobody told us the encoding. This is a common programming error and due to a confusion over data and information. Let’s try with UTF-8 instead of ASCII.

```
life←{↑1 ⍵∨.∧3 4=+/,¯1 0 1∘.⊖¯1 0 1∘.⌽⊂⍵}
```

Well, the encoding is now correct and **we now finally have some information** (yeah!). However, it's still gobbledygook, at least to me. Even so, just to get this far we needed to know: 
1. *how* to observe some state (transistors on or off, in this case)
2. *how* to read that state (0s or 1s)
3. *what* it represents (image, text, audio, etc.)
4. *how* it's represented, the format (UTF-8, ASCII, etc.)

The good news is that information, like energy, can be manipulated and changed in form. We could convert it to base-7 or EBCIDIC, if we wanted, and it wouldn't lose it's content, **as long as we remember the context**, the meta-data if you like, our information is safe. But what do we do with it?

## Knowledge

We still have a problem. **We have no idea what the information means**. It looks like we have some symbols and someone probably knows what those symbols mean but I’m going to guess that most people don't. This is beyond encoding and into the area of semiotics and language. The symbols are *signifiers*.

Now, let me tell you, that is actually a piece APL code. If you know something about APL maybe you can follow what it's doing. If not, then I can point you towards the [APL wiki](https://aplwiki.com/) or the [Wikipedia](https://en.wikipedia.org/wiki/APL_(programming_language)) entry and maybe after (considerable) study you might be able to follow what it's doing. You could even [watch the video](https://www.youtube.com/watch?v=a9xAKttWgP4). If you can then hat's off to you sir! I personally have no idea.

As it is given, this is a recipe which solves a problem. But then we might ask ourselves: what problem?

## Understanding

Even when we know what the program *does* we might ask ourselves: why did someone write this code in the first place? What's its purpose? There are no comments, the variables are greek (literally). The only clue is the name of the function....

In actual fact it is a [famous one-liner](https://en.wikipedia.org/wiki/APL_(programming_language)#Game_of_Life) for [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life). If you don't know what the Game of Life is, it's a famous programming toy from computer science which turns out to be in a class of systems which are Turing complete, that is universal computing machines. The person who wrote the code probably knew that. 

They also knew intimately *how* to solve the problem with the given language. That require a deeper level of reasoning than merely learning the language. It means many hours of experimentation and practice. That is why we do katas and continuous practice to hone these skills.

Understanding why and how is very different from following the rules. 

## Wisdom

OK, so we understand universal computation and the game of life, the APL language, the text encodings, the bytes and the transistors. We might understand the concepts but how do we know when and if to apply them? When would I consider APL over some other language? When should I use a programming language at all or and when should I be playing with my children?

You might have noticed that the ideas become more abstract and general as we move along the chain. This last level is the most difficult of all and the subject of most debate. If understanding requires reflection then this require still more. 


This has been just one trivial example of the many levels of knowledge or understanding behind anything we do. We are knowledge workers, using information everyday. I wonder sometimes if we really stop to really understand some of the things we do (he says, copy/pasting from Wikipedia) or whether we are content with *just* knowledge. 

(That's the first part. The next part will deal with applying mental models to the different stages to understand them better in general.)



