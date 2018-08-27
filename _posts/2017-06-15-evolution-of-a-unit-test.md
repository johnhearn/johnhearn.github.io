---
layout: post
asset-type: post
name: evolution-of-unit-test
title: Evolution of a Unit Test
description: Example of the evolution of a real unit testing over the course of a morning
date: 2017-06-15 09:18:00 +00:00
author: John Hearn
tags:
- tdd

---

Continuing the series of notes taken by a TDD apprentice. This post covers a day in the life of a unit test. In this case it happens to be a GUI unit test but it applies broadly, I think.

## It started with a test... 

The application is a JavaFX GUI for loading and modifying resource bundle property files. We decided that the first test to drive the development will display an unadorned window with a button to load a resource bundle. Applying Uncle Bob's [Three Rules of TDD](http://butunclebob.com/ArticleS.UncleBob.TheThreeRulesOfTdd) our first unit test looks like this...

```java
 @Test
 public void should_call_load_bundle() {
  clickOn("#loadBundle");
  verify(bundleLoader, times(1)).loadBundle();
 }
```

This just ensures that the method `bundleLoader#loadBundle()` is called when we press the button. We've used [TextFX](https://github.com/TestFX/TestFX) to drive the GUI and [Mockito](http://site.mockito.org/) to create a stub for a "bundle loader" interface (which still does not exist) and we make sure it is called exactly once when the `#loadBundle` button is pressed. This test doesn't just fail, it doesn't even compile (This is TDD!) so we bootstrapped the JavaFX application and painted an empty screen with a button. We also generated a BundleLoader interface (and I mean generated because the IDE quick-fixes practically did it for us), wrote some code (lambdas are cool) and, voila, green bar. This is what TDD is supposed to feel like.

Next we wanted to allow the user to select a file to load. We clearly couldn't open a file selection dialog box in a unit test so we cleverly encapsulated the file selection behaviour behind an interface, mocked it and passed the selected file to the bundle loader. Sound good?

```java
 @Test
 public void should_call_load_bundle() {
  clickOn("#loadBundle");
  verify(fileSelector, times(1)).selectFile();
  verify(bundleLoader, times(1)).loadBundle("filename");
  verifyThat("#text", hasText("Loaded"));
 }
```

We did some coding and made that go green but we started realising that this was beginning to smell bad. Why? Well first we noticed that we have have significantly increased coupling, not just in one but in two ways:

We've coupled ourselves to a second interface (the `fileSelector`) for very little gain.
We've broadened the `BundleLoader` interface (adding a new parameter), increasing coupling that way too (see this blog post)
Maybe `fileSelector` would be better passed in as a dependency to the bundle loader? Let's see. The test becomes...

```java
 @Test
 public void should_call_load_bundle() {
  clickOn("#loadBundle");
  verify(bundleLoader, times(1)).loadBundle();
  verifyThat("#table", hasText("Loaded"));
 }
```

Better, we've reduced the coupling again and the test is clean. Now we have a working button but there's another problem... it doesn't do anything useful. We realised that we've tested a nonsensical outcome too. We don't really want to see a "Loaded" message. We want to see a loaded bundle in a table!

```java
 @Test
 public void should_call_load_bundle() throws IOException {
  clickOn("#loadBundle");
  verify(bundleLoader, times(1)).loadBundle();
  verifyThat("#table", hasItems(1));
 }
```

That's better and involved the carefree deletion of useless code{% marginnote "branchpoints" "Note to self: testing tends to be concise and trouble free when there are few branch points in the code, as is the case here. Branch point introduce complexity and complicate the testing." %}. There's more stuff going on like building the test data for the mock/stub and we're not testing `BundleLoader` at all. Nonetheless we've written an impressive amount of tested GUI with these 3 lines of test code and we haven't even run the app yet.

Temptation overwhelms us as we generate a `BundleLoader` implementation with test data (remember we're decoupled from the FileSelector interface now, proof that the design is less coupled), run the app and amazingly it works first time!

Back now to TDD.

Our GUI won't just be a table but also have a textarea to hold the key. How to we test that? Easy:

```java
 @Test
 public void should_display_translations() throws IOException {
  clickOn("#loadBundle");
  TableView<KeyColumnModel> table = lookup("#table").queryFirst();
  verifyThat(table, hasItems(1));
  table.getSelectionModel().selectFirst();
  verifyThat("#key", hasText("category.key1"));
}
```

That's starting to smell bad again. To make the test make sense we had to induce behaviour from the test, namely selecting the first row. Actually this identifies a problem with the GUI itself because the initial state was undefined. Realising this we simplify the test again and move the default selection into the GUI code.

```java
 @Test
 public void should_display_table_and_first_translation() throws IOException {
  clickOn("#loadBundle");
  verify(bundleLoader, times(1)).loadBundle();
  verifyThat("#table", hasItems(1));
  verifyThat("#key", hasText("category.key1"));
 }
```

This test seems obvious now, and that's a very positive sign, but we've seen how hard simplicity can sometimes be. Now, with only 4 lines of clean test code we have a working (stubbed) GUI. It's easy now to add the final remaining functionality, the text values for the different languages in the bundle. It's nearly the same as the previous case.

```java
 @Test
 public void should_display_table_and_first_translation() throws IOException {
  clickOn("#loadBundle");
  verify(bundleLoader, times(1)).loadBundle();
  verifyThat("#table", hasItems(1));
  verifyThat("#key", hasText("category.key1"));
  verifyThat("#ta_", hasText("clave de prueba"));
  verifyThat("#ta_en", hasText("test key"));
  verifyThat("#ta_ca", hasText("clau de prova"));
 }
```

That is now the whole GUI happy path tested for this first TDD iteration. A couple of key takeaways.

1. From the evolution of the test we can see that **striving to simplify the test has resulted in better design decisions and cleaner code**. The application even worked first time! We are still missing corner case testing (IOExceptions should be handled elegantly) but a big chunk of the functionality has been driven out and tested.

2. The resulting **test is fairly resistant to refactoring**. We might decide to split the GUI up into composite controls and refactor the internals of the BundleLoader but that will have little or no effect on the test.

3. A corollary of the previous point is that this is a unit test that spans more than one class. The unit being the GUI behaviour. **The unit of testing is a behaviour, NOT a class** (as I once erroneously believed).

4. Talking of refactoring, the app was improved by **worry-free, aggressive refactoring** during the development, something which could be done without the fear of breaking the code.

5. The resulting test is small and easy to read while covering large swathes of the GUI. It surprised even us the **excellent coverage achieved by a small, well designed test.**

Several TDD skills honed today. These are my notes from a real project. I post them in the hope that someone might find them useful.
