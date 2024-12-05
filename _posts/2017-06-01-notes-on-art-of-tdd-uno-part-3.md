---
layout: post
asset-type: notes
title: Notes on the Art of TDD - Uno (Part 3)
date: '2017-06-01T22:00:00.000+02:00'
author: John
tags:
- ood series
- tdd
modified_time: '2017-06-04T10:47:10.577+02:00'
blogger_id: tag:blogger.com,1999:blog-525051364647796957.post-8169991096469027570
blogger_orig_url: http://john-hearn.blogspot.com/2017/06/notes-on-art-of-tdd-uno-part-3.html
category: notes-on-uno
---

[Next day - continued from [here](notes-on-art-of-tdd-uno-part-2.html)]

The first test for the new requirement is straightforward, if a little contrived:

```java
@Test
public void testResetPack() throws Exception {
  Pack pack = new Pack();
  int numCardsInPack = pack.numCards();

  Pile pile = new Pile();
  pile.addCard(new WildCard());
  pile.addCard(new WildCard());
  pile.addCard(new WildCard());

  pack.resetPack(pile);

  assertThat(pack.numCards()).isEqualTo(numCardsInPack + 3);
  assertThat(pile.numCards()).isEqualTo(0);
}
```

The code is simple.

```java
public void resetPack(Pile pile) {
  this.cards.addAll(pile.cards);
  pile.cards.clear();
  this.shuffle();
}
```

But how to test the game logic. This is a recurring theme of this exercise. The functionality is easy to test while the game logic is hard. This is the test I came up with:

```java
@Test
public void testCardsFromPileAddedToPackWhenPackEmpty() throws Exception {
  MockPack pack = new MockPack(17);
  pile = new Pile();
  players = new Player[] { new Player(), new MockPlayer(null) };
  game = new UnoGame(pack, pile, players);
  game.play();
  assertThat(pack.count.get()).isGreaterThan(0);
  assertThat(players[0].numCards()).isEqualTo(0);
}

private static class MockPack extends Pack {
  AtomicInteger count = new AtomicInteger(0);

  public MockPack(int numCards) {
    cards.clear();
    for (int i = 0; i < numCards; i++) {
      cards.add(new WildCard().withColour(Colour.BLUE));
    }
  }

  @Override
  public void resetPack(Pile pile) {
    super.resetPack(pile);
    count.incrementAndGet();
  }
}
```

It sets up a game situation which should result in the pile being moved to the stack and then uses a mock Pack implementation to ensure that the `resetPack()` method is indeed called. This seems brittle and overly complex. Maybe I should have tested all the logic this way from the beginning and then maybe I could have simplified the process more. Not sure.

This is really getting close to a working Uno game now. All the card types are done and the logic is applied. A whole game can be played out. We're missing a few things like scoring and output which shouldn't be too difficult. However before doing that I've noticed we're occasionally getting the following error:

```
java.lang.IndexOutOfBoundsException: Index: 0, Size: 0
at java.util.LinkedList.checkElementIndex(LinkedList.java:555)
at java.util.LinkedList.remove(LinkedList.java:525)
at project.Pack.drawCard(Pack.java:35)
at project.UnoGame.pickupCards(UnoGame.java:89)
at project.UnoGame.nextTurn(UnoGame.java:65)
at project.UnoGame.play(UnoGame.java:36)
at project.GameTest.testGame(GameTest.java:24)
```

After some investigation it seems the above test did not catch the case where we're running out of cards in the pack while drawing because of a DrawTwo or WildFour card. In this case the `resetPack()` method should be called automatically. This has identified yet again that the tests only catch problems in the cases you have thought of, things that may have been picked up earlier by the traditional design->implement->test sequence. I think I can see how this happens. A branch in code should be tested by positive and negative tests. A second branch produces 4 possible combinations. A third branch 8 with only 6 tests. A fourth 16 with only 8 tests. You get the point. {% marginnote "testing-branches" "Edit: See James O Coplien's article [Why Most Unit Testing is a Waste](http://rbcs-us.com/documents/Why-Most-Unit-Testing-is-Waste.pdf)" %}This has important consequences for algorithm development using TDD which I haven't seen mentioned by the TDD gurus.

Anyway, to test this I'm going to fall back to the way we've been testing logic in this project, namely extracting a protected method. I don't like it but I'm not seeing the alternatives. Noticing we don't actually have a test for the `drawCard()` method on the `Pack` class (why not?), we create one first:

```java
@Test
public void testDrawCard() throws Exception {
  Pack pack = new Pack();
  while (pack.numCards() > 0) {
    assertThat(pack.drawCard()).isNotNull();
  }
  assertThat(pack.drawCard()).isNull();
}
```

Ensuring `drawCard()` no longer throws an `IndexOutOfBoundsException` when the pack is empty. Then we test a new protected method on the game logic:

```java
@Test
public void testResetPackOnDraw() throws Exception {
  MockPack pack = new MockPack(50);
  pile.addCard(pack.drawCard());
  pile.addCard(pack.drawCard());
  pile.addCard(pack.drawCard());
  game = new UnoGame(pack, pile, players);
  while (pack.numCards() > 0) {
    assertThat(game.drawCard()).isNotNull();
  }
  assertThat(pack.count.get()).isEqualTo(0);
  assertThat(game.drawCard()).isNotNull();
  assertThat(pack.count.get()).isEqualTo(1);
}
```

We've used the `MockPack` class again to verify that the resetPack() method has indeed been called. We also check that the protected method doesn't return null because the pack has been reset from the pile. The tests now pass every time. These last test cases seem very forced and they took a lot of time to develop... not only to determine what tests to write but I was even forced to debug the code to find the sources of the errors not picked up by the tests. Either TDD is very very hard or it actually has some pitfalls. Focusing on test cases can mean that if you are not careful your developer intuition is eroded for example for corner cases and error scenarios.

We'll continue in the [next part](notes-on-art-of-tdd-uno-part-4.html).