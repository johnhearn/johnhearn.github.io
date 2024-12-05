---
layout: post
asset-type: notes
title: Notes on the Art of TDD - Uno (Part 4)
date: '2017-06-04T10:46:00.003+02:00'
author: John
tags:
- ood series
- tdd
modified_time: '2017-06-19T18:05:33.404+02:00'
blogger_id: tag:blogger.com,1999:blog-525051364647796957.post-8476599929090284071
blogger_orig_url: http://john-hearn.blogspot.com/2017/06/notes-on-art-of-tdd-uno-part-4.html
category: notes-on-uno
---

[Continued from [Part 3](notes-on-art-of-tdd-uno-part-3.html)]

Let's get on to the final important part of the game - scoring.

> At the end of the game all opponents’ cards are given to the winner and points are counted. All number cards are the same value as the number on the card (e.g. a 9 is 9 points). “Draw Two" – 20 Points, “Reverse" – 20 Points, “Skip" – 20 Points, “Wild" – 50 Points, and “Wild Draw Four" – 50 Points. The first player to attain 500 points wins the game.

This should be straightforward to test, hopefully. As always, we test bit by bit. First card scores. The best place for this is in the cards themselves. Here's a test for the Draw Two card.

> All number cards are the same value as the number on the card

```java
@Test
public void testCardPoints() {
  Card card = new Card(5, Colour.BLUE);
  assertThat(card.points()).isEqualTo(5);
}
```

Likewise the action cards:

> “Draw Two" – 20 Points

```java
@Test
public void testDrawTwoCardPoints() {
  DrawTwoCard drawTwoCard = new DrawTwoCard(Colour.BLUE);
  assertThat(drawTwoCard.points()).isEqualTo(20);
}
```

That's trivial to implement. The others are similar. One interesting point though is how to ensure we've covered all the cards? We have used a hierarchy to model the different card types (I'm happy with that because `WildFourCard` **_is a_** `WildCard`, etc.) so the superclass may have a default implementation which may not necessarily be tested. The only way to ensure we cover all cases is to add tests systematically for each card type which is error prone.

> All opponents’ cards are given to the winner and points are counted

```java
@Test
public void testAddUpScores() {
  Player winner = game.play();
  for (Player player : players) {
    if (player == winner) {
      assertThat(player.score()).isGreaterThan(0);
    } else {
      assertThat(player.score()).isEqualTo(0);
    }
  }
}
```

Now the last point.

> The first player to attain 500 points wins the game.

Notice that the word "game" is being used in a different way - now to represent the entire game and earlier to represent a single round. We're going to use the word "round" to represent a single hand and the word "game" for all the rounds until we get a final winner. Rename with the IDE and the tests still work. TDD gives you some confidence after a big refactor like this which is nice.  I also notice an unused method (originally created for testing, it seems). Delete that too. And the tests are still green.

Now a test for the whole game.

```java
@Test
public void testGame() {
  Game game = new Game(players);
  Player winner = game.play();

  for (Player player : players) {
    if (player == winner) {
      assertThat(player.score()).isGreaterThanOrEqualTo(500);
    } else {
      assertThat(player.score()).isLessThan(500);
    }
  }
}
```

The IDE generates the skeleton `Game` class. The play method is simple.

```java
public Player play() {
  while (true) {
    Round game = new Round(players);
    Player winner = game.play();
    if (winner.score() > 500) {
      return winner;
    }
  }
}
```

That's elegant and works great however a similar situation as before has occurred. I have found a bug not covered by the tests. This time, because we're reusing the player objects, their hands are not being reset after each round. How can we ensure these oversights don't happen? Once again the test is harder than the fix. One idea is to avoid creating a pack instance every time and reuse the same one. In that case the number of cards in the pack must always be the same at the start of a game. It also means the pack can be reused. At the end of a round, cards are replaced in the pack from the pile and each player's hand, just as in a real game. We extract another protected method, `playRound()` which just plays the round. The outer `play()` method will put all cards back into the pack at the end of the round. The test is essentially the same as the existing `play()` test case.

```java
@Test
public void testPlayRound() {
  Player winner = round.playRound();
  for (Player player : players) {
    if (player == winner) {
      assertThat(player.numCards()).isEqualTo(0);
    } else {
      assertThat(player.numCards()).isNotEqualTo(0);
    }
  }
}
```

After refactoring, the play() method becomes.

```java
public Player play() {
  Player winner = playRound();
  return winner;
}
```

Then we add a new test to make sure all the cards are put back in the pack

```java
public void testPlay() {
  int numCards = pack.numCards();
  round.play();
  for (Player player : players) {
    assertThat(player.numCards()).isEqualTo(0);
  }
  assertThat(pile.numCards()).isEqualTo(0);
  assertThat(pack.numCards()).isEqualTo(numCards);
}
```

Luckily we already have a method in pack that does nearly exactly what we want: `resetPack(pile)`. We rename it to `putCards()` and, by letting it take a `CardHolder` instead of a `Pile`, we can use it to make this latest test pass. 

```java
public Player play() {
  Player winner = playRound();
  for(Player player : players) {
    pack.putCards(player);
  }
  pack.putCards(pile);
  return winner;
}
```

One last thing. Let's take advantage of the reusable the `Pack` class to avoid creating a new one for every round. An improvement in memory use and nicer OO. A single `Pack` object is passed into the `Game` class and is reused for every round. `Pack` therefore becomes a dependency of `Game` and suddenly we have the possibility of playing a game with a different pack implementation, one with a reduced set of cards, for instance, or an alternative variant. Nice things like that happen when OO is done right :)

Our Uno game model is now nearly complete. Out of interest we now have 48 tests and they run in milliseconds. That's good. Taking a look at the overall design it's quite good with a nice distribution of logic throughout the domain. There are a couple of `instanceof`s which I could probably refactor away. Overall a good design seems to have been driven out.

To complete the Uno project we need an application to run it (we have got this far basically with only unit tests!) preferably with the option of using human players. We'll do that now. As always we start with a test.

> Run a game of Uno with 4 of our random card players and print the result.

This is very similar to the actual `Game` tests but I guess in reality this class does little more that the test harness. We should be testing the main() method which is the entry point to the actual app. Our test should look something like this:

```java
@Test
public void testPlayUnoGame() {
  PlayUno.main(new String[0]);
}
```

But we have no assertions and since this is a static call to a fixed method we can't override any methods or pass any parameters. We'll have to capture the stdout. For that I use a little utility called Capture. Here's the test:

```java
@Test
public void testPlayUnoGame() throws IOException {
  try (Capture capture = new Capture()) {
    PlayUno.main(new String[0]);
    BufferedReader reader = capture.readBack();
    assertThat(reader.readLine()).matches("Player 0 scored \\d+ points.");
    assertThat(reader.readLine()).matches("Player 1 scored \\d+ points.");
    assertThat(reader.readLine()).matches("Player 2 scored \\d+ points.");
    assertThat(reader.readLine()).matches("Player 3 scored \\d+ points.");
    assertThat(reader.readLine()).matches("Player \\d is the winner.");
  }
}
```

This constitutes an acceptance test. Maybe we should have started with this right back at the beginning.

That's the model done. Some takeaways:

1. **Incremental testing is hard**, especially when adding functionality that necessarily spans several classes. In a rich domain model, functional tests will inevitably span domain objects and so will have to be broken down into multiple unit tests. That was the case, for example, in this post when scoring was introduced - the `Round` class and every card class had to be changed, test first.

2. Even having developed the model from the beginning using pure TDD, I discovered **several flaws** that were not detected by the tests. I don't think these particular bugs would have happened (or lasted long) in a traditional code->test scenario because the failure would have been obvious. For example, reusing player instances introduced initialisation errors that somehow got past the tests, probably in a way related to the previous point. This is the main problem that I have with TDD at the moment. 

3. I expected to need a `Hand` class but in the end that has not been necessary. It would separate logic (the player) from data (the hand). TTD in this sense has had a positive impact on the design in the sense that an unnecessary class hasn't been created. On the other hand, it has driven out the `CardHolder` class, something that I would have probably designed anyway.

4. Making the code testable has lead to a couple of **test artifacts in the code**. First the protected `numCards()` method in the end was necessary but earlier in the development it was added purely for test convenience. It doesn't really constitute breaking encapsulation but it isn't hiding as much information as it could. On the other hand the OOness of the design has been improved. Pushing logic out of the `Round`/`Game` classes into `Pack` and `Pile` made testing easier. I don't think that the `Pile` and `Pack` classes would have been such rich domain abstractions if I had designed it without TDD.

5. On the other hand, having a rich domain means that game logic too is distributed around the model. That's OK until we want to play by different rules. For example my daughter (who introduced me to this game) doesn't play by the "official" rules on which I have based this model. According to her, you can play a Draw Two card on top of another Draw Two card to force the next player to pick up 4 cards. Making these kinds of changes to the rules with the current domain objects could be tricky. If I had designed the classes with this in mind would have made this easier.

6. It should also be said that it took me **much longer** to implement this model with TDD than it would have taken me in the traditional way. Having said that we have a solid code base and confidence when refactoring. That trade off exists and deciding whether it's worth it should also be part of the TDD skill set.

It's not exactly state-of-the-art but it's been a good exercise in TDD and that was the objective.

To complete the Uno game it is missing some important ingredients.

First we should supply better `Player` implementations with more intelligent game strategies, at the moment the random selection of a valid card is just enough to get a valid game. We'll leave to creation of better players for another post where we'll consider better strategies and even use machine learning techniques to improve the game play.

Secondly we should add a human UI, even if it's just a console based one for now. I'll write that post one day ;)