---
layout: post
asset-type: notes
title: Comparing Clojure to Kotlin
description: Take an interesting Clojure example and convert it to Kotlin.
date: 2018-12-16 19:22:00 +02:00
author: John Hearn

---

One way to learn a new language is to compare it to one you already know. Here I'm taking a program written in Clojure{% sidenote credit "The code is taken from my colleague [Richard Wild](https://codurance.com/publications/author/richard-wild/)'s excellent series of articles on [Functional Programming](https://codurance.com/2018/11/02/the-functional-style-part-6/)." %} and comparing it with similar code in Kotlin. The objective is two-fold, firstly to help me learn Clojure and secondly to see the similarities and differences between these two languages. In the following I'll assume some minimum knowledge of both.

To warm up lets compare these two different ways of defining a function in Clojure:

```clojure
(defn greet [name] (str "Hello, " name))

(def greet (fn [name] (str "Hello, " name)))
```

With the Kotlin equivalent:

```kotlin
fun greet(name: String) = "Hello, " + name

val greet = { name: String -> "Hello, " + name }
```

The syntax is quite different, of course, and Kotlin requires typed parameters where Clojure is dynamically typed. This can be a blessing and a curse but that's a discussion for another day. Idiomatic Kotlin would also use built-in string templates instead of concatenation but the similarities nonetheless stand out.

Let's get into the example. First define the neighbour offsets. In Clojure vector instantiation is quite neat (this is formatted manually to show the pattern).

```clojure
(def neighbours
  [[-1,  1] [0,  1] [1,  1]
   [-1,  0]         [1,  0]
   [-1, -1] [0, -1] [1, -1]])

(defn neighbours-of [x y]
  (set (map (fn [[x-offs y-offs]] [(+ x-offs x) (+ y-offs y)])
            neighbours)))

(defn generate-cell [neighbours y x]
  (if (contains? neighbours [x y]) 1 0))
```

In Kotlin to do the same is slightly more verbose{% sidenote less-verbose-than-java "But not as verbose a Java :)" %}. We can use `Pair`s (tuples) and `typealias`es here to improve the readability.

```kotlin
typealias Cell = Pair<Int, Int>
typealias Cells = Collection<Cell>

var neighbours =
        setOf(Cell(-1,  1), Cell(0,  1), Cell(1,  1),
              Cell(-1,  0),              Cell(1,  0),
              Cell(-1, -1), Cell(0, -1), Cell(1, -1))

fun neighboursOf(x: Int, y: Int) =
        neighbours.map { (xOff, yOff) -> Cell(xOff + x, yOff + y) }

fun generateCell(neighbours: Cells, y: Int, x: Int) =
        if (neighbours.contains(Cell(x, y))) 1 else 0
```

The thing to note is the use of the `map` function in both implementations. The parameters are effectively reversed. We'll see some implications of this later. Next we'll see some currying (the focus of the article):

```clojure
(defn generate-line [neighbours width y]
  (map (partial generate-cell neighbours y)
       (range 0 width)))

(defn generate-board [dimensions neighbours]
  (mapcat (partial generate-line neighbours (dimensions :w))
          (range 0 (dimensions :h))))
```

And in Kotlin:

```kotlin
fun generateLine(neighbours: Cells, width: Int, y: Int) =
        (0 until width).map { x -> generateCell(neighbours, y, x) }

fun generateBoard(h: Int, w:Int, neighbours: Cells ) =
        (0 until h).flatMap { y -> generateLine(neighbours, w, y) }
```

Things to note: 
- The `partial` function in Clojure translates naturally to lambda expressions in Kotlin.
- While the `map` function is the same, `mapcat` becomes `flatMap` in Kotlin.
- It seemed easier in Kotlin to pass `h` and `w` as simple parameters rather that inside map. I wonder what the reasoning behind this is and whether it's a common style in Clojure.
- We can use the range operators directly in Kotlin. I actually prefer `range` as a function too but it's less idiomatic in Kotlin.

The next bit is much the same:

```clojure
(defn mine? [cell]
  (= \* cell))

(defn board-for-cell [dimensions y x cell]
  (generate-board dimensions (if (mine? cell) (neighbours-of x y))))

(defn boards-for-line [dimensions line y]
  (map (partial board-for-cell dimensions y)
       (range 0 (dimensions :w))
       line))
```

Compared to the Kotlin version:

```kotlin
fun isMine(cell: Char) =
        '*' == cell

fun boardForCell(h:Int, w:Int, y:Int, x:Int, cell:Char) =
        generateBoard(h, w, if(isMine(cell)) neighboursOf(x,y) else emptyList())

fun boardsForLine(h:Int, w:Int, line:CharSequence, y:Int) =
        (0 until w).map { x -> boardForCell(h, w, y, x, line[x]) }
```

Here we can again see the difference between the `map` functions mentioned earlier. Clojure allows multiple ranges for the map operation, essentially `zip`ing them together for you. It's an interesting idea. Note that Kotlin also *requires* that `boardForCell()` return a result where Closure does not, defaulting to `nil`. Kotlin spurns `null`s and in any case I prefer this approach.

Now the fun part.

```clojure
(defn sum-up [& vals]
  (reduce + vals))

(defn draw [input-board]
  (let [lines (str/split-lines input-board),
        dimensions {:h (count lines), :w (count (first lines))}]
    (->> (mapcat (partial boards-for-line dimensions)
                 lines
                 (range 0 (dimensions :h)))
         (apply map sum-up))))
```

This combines several concepts that were new to me, `->>` and `apply` together with the tricky (for me) `map` function and some magic with the varadic arguments. It took a while to understand what was going on here and in fact my first couple of naïve attempts didn't work at all. Since the aim was to get as close to the Clojure code as possible this is what I finally came up with:

```kotlin
fun sumUp(vararg vals: List<Int>) =
        vals.reduce { acc, v -> acc.zip(v) { a, b -> a + b } }

fun draw(inputBoard: CharSequence): List<Int> {
    val lines = inputBoard.split("\n")
    val h = lines.size
    val w = lines.first().length
    val boards = (0 until h).flatMap { y -> boardsForLine(h, w, lines[y], y) }
    return sumUp(*boards.toTypedArray())
}
```

Things to note:
- Spreading of varadic arguments (with the `*` operator) only works for arrays in Kotlin so I had to convert the list to a typed array. In Clojure it seems that it's very easy to spread varadic arguments and there is a *big* difference between spreading a list and taking a single `List` argument although it appears very similar.
- It doesn't help that there are no types on the Clojure version of the `sumUp()` method. I have found that I lean heavily on strong typing but I'll struggle on :)
- There is something attractive about that Clojure code, as compared to the Kotlin version, that I'm not sure I'm fully appreciating yet. However if we don't make the `sumUp` function variadic (and make it an extension function instead) then the implementation becomes simpler and matches the Clojure version a little more closely.

```kotlin
fun List<List<Int>>.sumUp() =
        this.reduce { acc, v -> acc.zip(v) { a, b -> a + b } }

fun draw(inputBoard: CharSequence): String {
    val lines = inputBoard.split("\n")
    val h = lines.size
    val w = lines.first().length
    return (0 until h).flatMap { y -> boardsForLine(h, w, lines[y], y) }
            .sumUp()
```

The rest of the exercise consists of manipulating and merging the output to give the final result:

```clojure
(defn cell-as-text [cell-value]
  (if (zero? cell-value) \space (str cell-value)))

(defn overlay-cell [top bottom]
  (if (mine? top) top bottom))

(defn overlay-boards [top bottom]
  (reduce str (map overlay-cell top bottom)))

(defn draw [input-board]
  (let [lines (str/split-lines input-board),
        dimensions {:h (count lines), :w (count (first lines))}]
    (->> (mapcat (partial boards-for-line dimensions)
                 lines
                 (range 0 (dimensions :h)))
         (apply map sum-up)
         (map cell-as-text)
         (partition (dimensions :w))
         (map (partial reduce str))
         (interpose \newline)
         (reduce str)
         (overlay-boards input-board))))
```

Translated directly to Kotlin's built-in functions it looks something like this:

```kotlin
fun cellAsText(cellValue: Int) =
    if (cellValue == 0) " " else cellValue.toString()

fun overlayCell(top: Char, bottom: Char) =
    if (isMine(top)) top else bottom

fun draw(inputBoard: CharSequence): String {
    val lines = inputBoard.split("\n")
    val h = lines.size
    val w = lines.first().length
    return sumUp((0 until h).flatMap { y -> boardsForLine(h, w, lines[y], y) })
            .map(::cellAsText)
            .chunked(w)
            .map { it -> it.joinToString("") }
            .joinToString("\n")
            .zip(inputBoard)
            .map { (a,b) -> overlayCell(b, a) }
            .joinToString("")
}
```

Here Clojure's `partition` function is replaced by Kotlin's `chunked` function and `str` with string functions like `joinToString`. Once again Clojure's multi-argument `map` function does not have a direct translation in Kotlin so we use `zip` to merge the result with the initial board to generate the final results. To get something more closely resembling thr Clojure code we can take advantage of Kotlin's extension methods. We'll need to create some helper methods.

```kotlin
fun str(a: CharSequence, b: CharSequence) = listOf(a, b).joinToString("")

fun List<CharSequence>.interpose(sep: CharSequence) =
        this.flatMap { it -> listOf(sep, it) }.drop(1)
````

An then use them to build the data pipeline:

```kotlin
fun CharSequence.overlayBoards(other: CharSequence) =
        other.zip(this, ::overlayCell).joinToString("")

fun draw(inputBoard: CharSequence): String {
    val lines = inputBoard.split("\n")
    val h = lines.size
    val w = lines.first().length

    return (0 until h).flatMap { y -> boardsForLine(h, w, lines[y], y) }
            .sumUp()
            .map(::cellAsText)
            .chunked(w)
            .map { it -> it.reduce(::str) }
            .interpose("\n")
            .reduce(::str)
            .overlayBoards(inputBoard)
}
```

Using extension methods has allowed us to put the other functions like `interpose` and `overlayBoards` into the pipeline giving us an effect similar to Clojure's thread-last operator. 

We can check the output by calling the `draw` function from `main`:

```kotlin
fun main(args: Array<String>) {
    println(draw("*   \n *  \n  * \n   *"))
}
```

And it does indeed, in case you're wondering, give us the results we expect.

```
*21 
2*21
12*2
 12*
```

### Conclusion

I was impressed by Clojure's ability to simplify complex pipelines using the thread-last `->>` operator. I needed to resort to extension methods to get the same effect in Kotlin. It's a powerful thing and now I'm wondering why I haven't seen it before. Maybe it's only possible because of Clojure's dynamic typing. The way the `map` operation is implemented is also very useful as compared to similar approaches in other languages. 

I'm starting to get the gist of Clojure's syntax (if only scratching the surface of it runtime). This exercise has helped really understand some non-trivial Clojure code. Next step will be to convert some existing functional style Kotlin to Clojure. That's for another day.