---
layout: post
asset-type: notes
title: Notes on the Art of TDD - Uno (Part 1)
date: '2017-05-15T08:08:00.001+02:00'
author: John
tags:
- ood series
- tdd
modified_time: '2017-05-15T13:25:23.410+02:00'
blogger_id: tag:blogger.com,1999:blog-525051364647796957.post-1955770504499029972
blogger_orig_url: http://john-hearn.blogspot.com/2017/05/notes-on-art-of-tdd-uno-part-1.html
category: notes-on-uno
---

Playing Uno with my daughter the other day I was wondering about the best strategies. I thought I'd build a Uno game not only to answer that question but also (and mainly) to improve my OO and TDD skills. These notes were taken during the process of creating the game model using TDD and contain not only good practice but also the mistakes. Some of the mistakes have been labelled as such in the notes. The exercise has taught me a lot. The post became quite long so it's split into various parts. I'll try and summarise the lessons learn in the final installment. All the code in this blog is available on GitHub [here](https://github.com/johnhearn/uno). Anyway this is how I started....

 As always in TDD we start with a test definition. What about this as a starting point?

> Start a game with 4 players. Every player is dealt a hand of seven cards from the pack and the top card in the pack is turned over. Each player in turn decides whether to play a card or to pick up the top card. To play a card they have to match the top card either by the number, color, or the symbol/Action. You can also play a Wild card....... The winner is first player to have no cards. x

This is quickly becoming the entire game. This isn't a test step but rather the final destination, perhaps an acceptance test. It's not giving us a readily testable outcome and it's getting bogged down in detail. Let's make it simpler.

> Player plays a card. x

This is certainly testable but it's not outside-in, it's a step in a test rather than a self-contained test from a user's perspective. This might be closer to a unit test iteration. Compare with this:

> Start a game with 2 players. Every player is dealt a hand of seven cards. Each player in turn plays a card. The winner is first player to have no cards.

This is obviously not a very fun game since the winner is always the first player. There is no top card or matching algorithm. Nonetheless it should flesh out our model quite a bit, and most importantly, it gives us a useful outside-in acceptance test, i.e. the winner has no cards, which will still be valid in future iterations.

{% marginnote "improved-acceptance-test" "I later realised that a better acceptance test would also include something like ""print the name of the winner"". The test above doesn't involve any interface to a user at all making the game model fairly useless." %}

What does the above test look like using JUnit?

```java
@Test
public void testGame() {
  UnoGame game = new UnoGame(2);
  game.deal();
  game.play();
  assertThat(game.winner().numCards()).isEqualTo(0);
}
```

How's that? We create a game with 2 players, exactly as we stated. We deal the cards then play the game, checking that the winner has no cards. Do we know that deal() and play() need to be separate methods on the game class? Would it make sense for play() to be called and not deal()? No, let's get rid of it. Intuition tells us that we may come back to it later but not yet. Patience is a part of TDD. What would happen if we called winner() without playing a game? Probably nothing good so let's try simplifying.

{% marginnote "game-vs-round" "Note: a Uno game actually ends when a player has scored 500 or more points. What we're dealing with here is a _single round_ in a game. That's something I realised later and was able to resolve by renaming it to `Round`." %}

```java
@Test
public void testGame() {
  UnoGame game = new UnoGame(2);
  Player winner = game.play();
  assertThat(winner.numCards()).isEqualTo(0);
}
```

It doesn't get much simpler than that. We've reduced coupling and can now guarantee that a winner won't be available until after the game has been played. We can implement it in about 30 seconds (the IDE does most of the typing for us). But wait, that was too easy. `Player.numCards()` can always return 0. What about dealing and playing cards? What about actual cards? There's something else. The test says "...winner is **first** player to have no cards". We haven't tested that at all. Extend the test.

```java
@Test
public void testGame() {
  UnoGame game = new UnoGame(2);
  Player winner = game.play();
  for(Player player : game.players()) {
    if(player == winner) {
      assertThat(player.numCards()).isEqualTo(0);
    } else {
      assertThat(player.numCards()).isNotEqualTo(0); // We add this to test the whole requirement
    }
  }
}
```

Once compilation errors have been corrected we have the error:

> Expected 0 to be not equal to 0

That's because we've cheated and given all players 0 cards. Now we have to implement some actual logic to get things moving. We write some code to deal some cards. This forces us to flesh out the Game and Player classes. Run the test...

```java
public Player play() {
  deal();
}

private void deal() {
  for (int j = 0; j < 7; j++) {
    for (Player player : players) {
      player.giveCard(new Card());
    }
  }
}
```

Result:

```
> org.junit.ComparisonFailure: expected:<[0]> but was:<[7]>
```

Now we have the opposite error. The players have cards but they're not being played so nobody wins. Write some more code.

```java
public Player play() {
  deal();
  while (true) {
    for (Player player : players) {
      player.playCard();
      if (player.numCards() == 0) {
        return player;
      }
    }
  }
}

private void deal() {
  for (int j = 0; j < 7; j++) {
    for (Player player : players) {
      player.giveCard(new Card());
    }
  }
}
```

That goes green so let's take stock. We have covered the first test case but some comments should be made. In order to test the game we have exposed `Player#numCards()` and `Game#players()`. The `players()` method smells of information leak but let's live with it for now. We're also leaving aside error handling for a moment (we have a risky while(true) loop in there!)

{% marginnote "commit" "Note to self: should have committed to version control here." %}

Let's extend the test some more.

> Every player is dealt a hand of seven cards **_from the pack_**....

Extend our unit test to include a pack abstraction.

```java
@Test
public void testGame() {
  UnoGame game = new UnoGame(2);
  assertThat(game.getPack().numCards()).isEqualTo(20);
  Player winner = game.play();
  assertThat(game.getPack().numCards()).isEqualTo(6);
  for(Player player : game.players()) {
    if(player == winner) {
      assertThat(player.numCards()).isEqualTo(0);
    } else {
      assertThat(player.numCards()).isNotEqualTo(0);
    }
  }
  assertThat(game.getPack().numCards()).isEqualTo(6);
}
```

We generate a `Pack` class and give it a `numCards()` method to make the test compile. It turns out that `numCards()` is also needed by the `Player` class so take note of that. The test fails, obviously. Let's do some coding to make it work. In doing so it becomes necessary for the `Pack` class to have a `takeCard()` method. Makes sense. From now on, within the game all cards should come from the pack (obviously!).

{% marginnote "commit" "Having discovered that `Pack` needed a `takeCard()` method, I didn't consider whether that method should have been tested with it's own test cases. This is something that should be done whenever generating new methods beyond those mentioned in the latest test case." %}

```java
public class Pack {

 private List<Card> cards = new LinkedList<>();

 public Pack(int numCards) {
   for(int i=0;i<numCards;i++) {
  cards.add(new Card());
   }
 }

 public int numCards() {
   return cards.size();
 }

 public Card takeCard() {
   return cards.remove(0);
 }
}
```

Again, this looks similar to the Player class but lets not worry about that for a moment. Run the tests. Hurray they are green!! Now we have green tests we can set about refactoring `Player` and `Pack` to share common code. For example by extending the abstraction of `Pack` to `CardHolder` and making it a super-class of both. The IDE does most of this for us. `Player` is now:

```java
public class Player extends CardHolder {

 public void giveCard(Card card) {
   cards.add(card);
 }

 public void playCard() {
   cards.remove(0);
 }
}
```

Simple and clean and the tests still pass. Of course as a game it is still utterly useless. With TDD that's something we have to live with. Normally we'd plough on and implement the game logic all in one go but TDD forces us to approach the problem bit by bit. Patience. This gets even harder with different types of algorithm but I'll leave that for another post.

Taking stock we have a game with players, a pack and a cards. The cards are dealt and played in turn. Now we don't want just any old pack of cards we want a Uno pack. This is what it eventually should look like.

[![](https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/UNO_cards_deck.svg/220px-UNO_cards_deck.svg.png)](https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/UNO_cards_deck.svg/220px-UNO_cards_deck.svg.png)

For now we'll start with the numbered cards. Lets write another test for Pack.

```java
@Test
public void test() {
  // How many cards? 1->9 * 4 colours
  Pack pack = new Pack();
  assertThat(pack.numCards()).isEqualTo(36);
}
```

In doing so we started fleshing out the `Card` class as well.

```java
public class Card {
 public enum Colour {
   GREEN,
   YELLOW,
   RED,
   BLUE
 }

 private final int number;
 private final Colour colour;

 public Card(int number, Colour colour) {
   super();
   this.number = number;
   this.colour = colour;
 }
}
```

{% marginnote "numbered-card" "I realised much later that I should have named the class `NumberedCard` at this point. Calling it `Card` is too generic and makes refactoring a common base class more tricky later on. TDD is hard. Good OO is hard. They are skills that need to be learned through practice." %}

So we have a game with players and something resembling the beginnings of a Uno pack. Can we add some Uno game play? Not until we have a discard pile. Let's do that next.

> Each player in turn plays a card... **onto the discard pile**. 

At the end of a game the pile should have 1 + 7 + 6 cards but we can go further by adding a check to ensure that the total count of cards (players, pack and pile, hasn't changed).

```java
@Test
public void testGame() {
  UnoGame game = new UnoGame(PLAYERS);
  int cards = game.getPack().numCards();
  Player winner = game.play();

  for(Player player : game.players()) {
    if(player == winner) {
      assertThat(player.numCards()).isEqualTo(0);
    } else {
      assertThat(player.numCards()).isNotEqualTo(0);
    }
  }
  assertThat(countTotalCards(game)).isEqualTo(cards);
}
```

The `countTotalCards()` helper method just adds up all the cards in the pile, the pack and each player. The test is independent of the number of players so I extracted that into a constant to make the code more readable.

Run it and it fails! I'd forgotten to add the player's cards to the pile. That drives out more domain functionality and everything passes again. We have now actually covered the first test case (and a bit more) and we should commit to version control (perhaps we should have done that before?).

We're getting close to being able to add some real Uno game play. So we add a new test.

> Given the top card on the pile, the player plays a card if they match the top card either by the number or color, otherwise they pick up a card from the pack. 

This seems tricky to test. The game test doesn't actually need to change. It seems testGame() is looking more and more like an integration test but we'll come back to that. To test this new functionality we need to inspect the game logic somehow. Where is one place we can put it? In the Card implementation itself. It has all the information about itself and can match itself with another card. Not sure what we'll do about wildcards but lets try it anyway. We have to match by either color or number.

```java
@Test
public void testCardLogic() {
  Card green1 = new Card(1, Colour.GREEN);
  Card red1 = new Card(1, Colour.RED);
  Card red2 = new Card(2, Colour.RED);
  Card blue4 = new Card(4, Colour.BLUE);
  assertThat(green1.canBePlayedOn(red1)).isTrue();
  assertThat(red1.canBePlayedOn(red2)).isTrue();
  assertThat(red2.canBePlayedOn(blue4)).isFalse();
}
```

The IDE adds the method for us and we add some very simple logic.

```java
public boolean canBePlayedOn(Card topCard) {
  return topCard.number == number || topCard.colour == colour;
}
```

Now we need to know what the top card is. Another test.

```java
@Test
public void testPileTopCard() {
  Pile pile = new Pile();
  pile.addCard(new Card(1, Colour.GREEN));
  pile.addCard(new Card(2, Colour.RED));
  pile.addCard(new Card(3, Colour.BLUE));
  assertThat(pile.topCard()).isEqualTo(new Card(3, Colour.BLUE));
}
```

Make that work, including an equals() method. Now how can we link it all up. Well, the player must play a card based on the current top card so presumably we need to pass that in to the Player.play() method. But wait, how can we test that method so deeply inside the game class. I had to go out for a walk to get inspired. I came up with the idea that what we need to test is that the pile is valid. If the pile is valid then the play logic is valid! Beautiful... and easy to test.

{% marginnote "ugly" "Just noticed how ugly this is :/" %}
```java
List pile = game.getPile().cards;
for (int i = 1; i < pile.size(); i++) {
  assertThat(pile.get(i).canBePlayedOn(pile.get(i-1))).isTrue();
}
```

Now that worked beautifully, and with some coding the tests pass but I'm not happy. I noticed a bug in the game logic that was not detected by the tests. Players were picking up from the pile instead of the pack and then discarding back to the pile, in effect skipping a turn without picking a card from the pack. This is worrying especially since the next step is to develop that logic for the rest of the game. This is a weak point of my TDD skills right now. [I'm not alone](https://www.infoq.com/news/2007/05/tdd-sudoku). There are many examples of this kind of incremental algorithm development failing. Intuition tells me that a possible approach would be to extract the logic to a testable state machine. That's a big design jump and not very TDD. I have my doubts. This is one of the main reasons for this post. I'm going to save the code as it stands to version control (I should have been doing that more) and sleep on it.

Continued [here](notes-on-art-of-tdd-uno-part-2.html).