---
layout: post
asset-type: notes
title: Notes on the Art of TDD - Uno (Part 2)
date: '2017-05-23T16:06:00.000+02:00'
author: John
tags:
- ood series
- tdd
modified_time: '2017-05-23T16:06:53.685+02:00'
blogger_id: tag:blogger.com,1999:blog-525051364647796957.post-8899773812787321398
blogger_orig_url: http://john-hearn.blogspot.com/2017/05/notes-on-art-of-tdd-uno-part-2.html
category: notes-on-tdd
---

[Next day - this continues from a [previous post](notes-on-art-of-tdd-uno-part-1.html)]

OK. Having mulled over the problem from yesterday I have realised that there are other weaknesses in the current tests. For example I could change the number of cards dealt to each player to 5 and the tests would still pass (and they did). Dealing exactly 7 cards was a requirement of the original test case and we didn't test for it. I guess that's teaching us something. Test ALL requirements not just the validity of the final result. Let's go back a step and start testing the requirements more carefully. I removed the code written in the last step yesterday and wrote a new test for the `deal()` method.

```java
@Test
public void testDeal() {
  UnoGame game = new UnoGame(PLAYERS);
  int cards = game.getPack().numCards();
  game.deal();
  for (Player player : game.players()) {
    assertThat(player.numCards()).isEqualTo(7);
  }
  assertThat(game.getPile().numCards()).isEqualTo(1);
  assertThat(game.getPack().numCards()).isEqualTo(cards - 7*PLAYERS - 1);
  assertThat(countTotalCards(game)).isEqualTo(cards);
}
```

That does not compile because `deal()` is private (remember we made that decision early on). I'm going to make it protected. That change makes the test run with no more code added. If I change it to deal only 5 cards each, the test fails. Correct. Thats improved the tests at the cost of broadening the protected interface of the game. That seems to be a direct negative consequence of the TDD method but maybe I'm doing it wrong or maybe it's a price worth paying?

Now commit those changes and move on to add unit tests more systematically following the requirements we lay out.

> Given [a card], the player plays a card if they match the top card either by the number or color

Right, let's write a test which fails for the case mentioned above. We can set up a player with a particular hand and a top card to play on. The `play()` method already exists but at the moment always plays any card. The [negative] logic is that is they have no matching card then they have to pass. We can represent a pass as returning null.

```java
@Test
public void testPlayerPlaysValidCard() {
  Player player = new Player();
  player.giveCard(new Card(6, Colour.RED));
  player.giveCard(new Card(6, Colour.GREEN));

  Card topCard = new Card(5, Colour.BLUE);

  Card playCard = player.playCard(topCard);
  assertThat(playCard).isNull();
}
```

Great that will fail but it's too easy to fix: just return null always, it's nonsensical. We need to test the positive logic too.

```java
@Test
public void testPlayerPlaysPlayableCard() {
  Player player = new Player();
  player.giveCard(new Card(6, Colour.RED));
  player.giveCard(new Card(5, Colour.GREEN));

  Card topCard = new Card(5, Colour.BLUE);

  Card playCard = player.playCard(topCard);
  assertThat(playCard).isEqualTo(new Card(5, Colour.GREEN));

  playCard = player.playCard(topCard);
  assertThat(playCard).isNull();
}
```

That'll be harder to fix and will give a useful result. My only doubt is whether it should be 2 separate tests. Let's leave it for now and make it pass. This is to code I added.

```java
public Card playCard(Card topCard) {
  Iterator iter = cards.iterator();
  while (iter.hasNext()) {
    Card next = iter.next();
    if (next.canBePlayedOn(topCard)) {
      iter.remove();
      return next;
    }
  }
  return null;
}
```

This code fixes the test but I've just realised that we don't have a test for the final state, namely one less card once it's been played. Add a new assertion for that particular case.

```java
@Test
public void testPlayerPlaysPlayable() {
  Player player = new Player();
  player.giveCard(new Card(6, Colour.RED));
  player.giveCard(new Card(5, Colour.GREEN));

  Card topCard = new Card(5, Colour.BLUE);

  Card playCard = player.playCard(topCard);
  assertThat(playCard).isEqualTo(new Card(5, Colour.GREEN));
  assertThat(player.numCards()).isEqualTo(1);

  playCard = player.playCard(topCard);
  assertThat(playCard).isNull();
  assertThat(player.numCards()).isEqualTo(1);
}
```

That's getting long so I refactor into 2 tests. I also refactor the tests into another test class and generate the common test data in a `@Before` method. That's much cleaner. Yes, we can refactor tests too!

Now we have another problem. We've broken the game!! Now that players return null to pass we are adding null values to the pile. We add a null check but now we have a more serious problem in that if everyone passes then the game never ends. At the same time I'm realising that the original test case is really becoming an integration test. There should be unit tests covering each piece of new logic. This latest problem needs to be tested by inducing a stalemate. We can't do that while all the internal dependencies are encapsulated in the UnoGame. I'm going to write a new test that creates a suitable test case.

```java
@Test
public void testStalemate() {
  Player passingPlayer = mock(Player.class);
  when(passingPlayer.playCard(any())).thenReturn(null);

  UnoGame game = new UnoGame(passingPlayer, passingPlayer);
  Player winner = game.play();
  assertThat(winner).isNull();
}
```

I've used *Mockito* mostly by habit. An alternative way of doing this is by overriding the `Player` class itself. Maybe it'll be simpler.

```java
private static class PassingPlayer extends Player {
  @Override
  public Card playCard(Card topCard) {
    return null;
  }
}

@Test
public void testStalemate() {
  UnoGame game = new UnoGame(new PassingPlayer());
  Player winner = game.play();
  assertThat(winner).isNull();
}
```

Much better. The major change here is that we need to be able to pass player instances to the game. This is actually something required later to set up a game with different player strategies, a good sign. A stalemate is signaled by a null winner.

This test does indeed get us into an infinite loop. We fix it by ensuring that if a whole round is passed then the game ends. I've done that with a do-while loop and a pass counter. Green bar again!

{% marginnote "wrong-logic" "This logic is actually wrong. A stalemate happens when the pack no longer has any cards. That was a problem with my knowledge of the game, not of the method, although TDD can sometimes take your eye off that kind thing. One of the reasons TDD is often associated with pair programming." %}

So on the the next test. We're starting to get into the real game now.

> ...the player plays a card if they [can] **_otherwise they pick up a card from the pack_**.

First write a test for that.

```java
@Test
public void testPickupOnPass() {
  UnoGame game = new UnoGame();
  int cardsInPack = game.getPack().numCards();
  game.nextTurn(new PassingPlayer());
  assertThat(game.getPack().numCards()).isEqualTo(cardsInPack-1);
}
```

To write the test I need to be able to isolate a single player's turn so I've introduced the `nextTurn()` method which will be protected like `deal()`.

```java
public boolean nextTurn(Player player) {
  Card card = player.playCard(pile.topCard());
  if (card != null) {
    pile.addCard(card);
  } else {
    pack.takeCard();
  }
  return card == null;
}
```

The `play()` method also changes slightly to accommodate the refactoring of the `nextTurn()` method. That works but the "acceptance" test now fails. What happened? We actually broke the logic with the last change the test and didn't realise because the test was not complete. Picking up a card means also adding it to the players hand.

```java
@Test
public void testPickupOnPass() {
  UnoGame game = new UnoGame();
  game.deal();
  int cardsInPack = game.getPack().numCards();
  PassingPlayer player = new PassingPlayer();
  game.nextTurn(player);
  assertThat(game.getPack().numCards()).isEqualTo(cardsInPack-1);
  assertThat(player.numCards()).isEqualTo(1);      // Card should be added to player's hand
}
```

This test is a little unwieldy. Can we get rid of the call to the `deal()` method. It's only needed to set up the first card in the pile. We can extract the context provided by `deal()` and set up the pile as we wish.

```java
@Test
public void testPickupOnPass() {
  Pack pack = new Pack();
  Pile pile = new Pile();
  pile.addCard(pack.takeCard());
  PassingPlayer player = new PassingPlayer();
  UnoGame game = new UnoGame(pack, pile, player);
  game.nextTurn(player);
  assertThat(pack.numCards()).isEqualTo(34);
  assertThat(pile.numCards()).isEqualTo(1);
  assertThat(player.numCards()).isEqualTo(1);
}
```

This test detects the problem. It also bypasses ugly `game.getPack()` accessor. I fix the code.

```java
public boolean nextTurn(Player player) {
  Card card = player.playCard(pile.topCard());
  if (card != null) {
    pile.addCard(card);
  } else {
    player.giveCard(pack.takeCard());   // Card is added to player's hand
  }
  return card == null;
}
```

This is now a more general mechanism for testing the game logic which is the problem facing us earlier. I suspect that extracting context objects (aka dependencies) will become a general principle to solve these situations. Commit and onto next test. 

> You can also play a Wild card

A wild card can be played on any top card and the new colour must be stated. The logic about what card can be played is in the Card class. We can create a new type of Card, WildCard, which supplies the required behaviour.

```java
@Test
public void testWildCardLogic() {
  WildCard wildcard = new WildCard();
  Pack pack = new Pack();
  while (pack.numCards() > 0) {
    assertThat(wildcard.canBePlayedOn(pack.takeCard())).isTrue();
  }
}
```

Easy to implement. Now add some more logic. When playing a wild card the player needs to select a colour. This logic then needs to go into the Player class (the player selects the colour, not the card or the game).

```java
@Test
public void testSetColourWhenPlayingWildCard() {
  Player player = new Player();
  player.giveCard(new WildCard());
  assertThat(player.playCard(new Card(3, Colour.BLUE)).colour).isNotNull();
}
```

The player logic is getting a bit nasty but that's OK because the player logic will be entirely replaced with better algorithms later on. For now we just want to define the contract of the player, which we have done. We'll update the Pack class to include these new types of cards. The game play will be more varied but the tests have not changed. The tests in general are proving quite resilient. Commit and carry on...

> Reverse – If going clockwise, switch to counterclockwise or vice versa.

Since we're going to be dealing with multiple new card tests I first extract them to a new test class and commit. The tests for this new card are similar to the wild card. `CardTest#testReverseCardLogic()` and incrementing the number of cards in the pack. The interesting case is changing direction. Until now all play has been in player order. I go with the same approach as before and extract that piece of logic to a new protected method. The same caveats apply as before. Now we have a new test for that new method, `game#nextPlayer()`:

```java
@Test
public void testNextPlayerLogic() {
  UnoGame game = new UnoGame(new Player(), new Player(), new Player());
  assertThat(game.nextPlayer(0, new Card(3, Colour.BLUE))).isEqualTo(1);
  assertThat(game.nextPlayer(1, new Card(3, Colour.BLUE))).isEqualTo(2);
  assertThat(game.nextPlayer(2, new Card(3, Colour.BLUE))).isEqualTo(0);
}
```

We refactor and rerun the tests. All green. 

```java
protected int nextPlayer(int i, Card topCard) {
  return (i + 1) % players.length;
}
```

Now it should be straightforward to handle reversing. The test case is:

```java
@Test
public void testNextPlayerReverseLogic() {
  UnoGame game = new UnoGame(new Player(), new Player(), new Player());
  assertThat(game.nextPlayer(0, new ReverseCard(Colour.BLUE))).isEqualTo(2);
  assertThat(game.nextPlayer(2, new Card(3, Colour.BLUE))).isEqualTo(1);
  assertThat(game.nextPlayer(1, new ReverseCard(Colour.BLUE))).isEqualTo(2);
  assertThat(game.nextPlayer(2, new Card(3, Colour.BLUE))).isEqualTo(0);
}
```

That fails, of course so we can implement it in the new method.

```java
private boolean forwards = true;

protected int nextPlayer(int i, Card topCard) {
  if (topCard instanceof ReverseCard) {
    forwards = !forwards;
  }

  if (!forwards) {
    return (i + players.length - 1) % players.length;
  }

  return (i + 1) % players.length;
}
```

I had a problem with this. The card passed to `nextPlayer()` method should be the card played by the last player, not the top card on the pile because a reverse and then a pass should NOT be another reverse. Not sure how to test that case, short of setting up a mini-game and checking the result. Another observation from the last change: a suspicious "_instanceof_", very often a sign of poor OO, often meaning that the behaviour should really be in the referenced object. That actually makes sense here. Let's move the logic into the Card hierarchy. We give the `Card` class a `nextStep()` function.

```java
@Test
public void testCardStep() {
  Card reverseCard = new Card(1, Colour.BLUE);
  assertThat(reverseCard.nextStep(+1)).isEqualTo(+1);
  assertThat(reverseCard.nextStep(-1)).isEqualTo(-1);
}

@Test
public void testReverseCardStep() {
  ReverseCard reverseCard = new ReverseCard(Colour.BLUE);
  assertThat(reverseCard.nextStep(+1)).isEqualTo(-1);
  assertThat(reverseCard.nextStep(-1)).isEqualTo(+1);
}
```

The existing tests for the `nextPlayer()` method complement these tests, testing the associated logic here:

```java
protected int nextPlayer(int i, Card lastCardPlayed) {
  if (lastCardPlayed != null) {
    step = lastCardPlayed.nextStep(step);
  }
  return (i + players.length + step) % players.length;
}
```

Note that those tests didn't change at all.

> Skip – When a player places this card, the next player has to skip their turn.

Tis should now be easy to implement. The tests are almost identical to the ReverseCard tests with a few minor differences which wash out directly from the tests. The `nextPlayer()` function now looks like this:

```java
protected int nextPlayer(int i, Card lastCardPlayed) {
  step = (step > 0) ? +1 : -1;
  if (lastCardPlayed != null) {
    step = lastCardPlayed.nextStep(step);
  }
  return (i + players.length + step) % players.length;
}
```

I see some immediate improvements to be made to make this more flexible but I'll wait for the need to arise. Patience.

Now I've been thinking for a while that I should add validation to the Pile class; we can't rely on players to abide by the rules! It's easy to state and test.

> An invalid card cannot be placed on the pile.

```java
@Test(expected=RuntimeException.class)
public void testPileDoesNotAcceptInvalidCard() {
  Pile pile = new Pile();
  pile.addCard(new Card(1, Colour.GREEN));
  pile.addCard(new Card(2, Colour.GREEN));
  pile.addCard(new Card(3, Colour.BLUE));
}
```

At this point I did a major refactor of the tests. I was able to simplify them substantially by using separate test classes for different units and setting up standard test data for each class. Then I was able to remove the ugly getters from the game class by accessing the dependent classes directly through the test setup. Well worth the time and the tests give me some confidence that everything is still as it should be.

Next test.

> Draw Two – When a person places this card, the next player will have to pick up two cards and forfeit his/her turn.

```java
@Test
public void testNextPlayerDrawTwoLogic() {
  assertThat(game.nextPlayer(0, new DrawTwoCard(Colour.BLUE))).isEqualTo(2);
  assertThat(players[1].numCards()).isEqualTo(2);
}
```

A test that would have been tricky to write before the refactor is now just 2 easy lines! The setting up of test data and classes is in the common `@Before` method.

The test, of course, fails. The first assertion is easy to fix, it's basically the same as the skip card case. The second is harder and I can't find an elegant solution with the code and it stands. Which class has the responsibility of drawing the two cards? Certainly not the card in this case, maybe the game itself? Or maybe the `Player` should do that. In the end I decided that it should be the game and the test was split into two:

```java
@Test
public void testNextPlayerDrawTwoLogic() {
  assertThat(game.nextPlayer(new DrawTwoCard(Colour.BLUE))).isEqualTo(2);
}

@Test
public void testNextTurnDrawTwoLogic() {
  pile.addCard(new Card(1, Colour.BLUE));
  Player player = new MockPlayer(new DrawTwoCard(Colour.BLUE));
  game.nextTurn(player);
  assertThat(players[1].numCards()).isEqualTo(2);
}
```

More tests.

> Wild Draw Four – This acts just like the wild card except that the next player also has to draw four cards as well as forfeit his/her turn.

Very similar tests to WildCard and DrawTwoCard and very similar implementation.

One last thing for today. I've noticed that sometimes the pack runs out before anyone wins. Also someone could run out of cards while drawing from the pile. The official rules say:

> At any time, if the pack becomes depleted and no one has yet won the round, take the discard pile, shuffle it, and turn it over to regenerate a new pack.

Easy to implement but how to test? [Tomorrow](notes-on-art-of-tdd-uno-part-4.html).