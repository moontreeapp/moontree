# Streaming Joins

A "streaming join" is similar to a regular SQL table join, but instead of having all of the data in the tables at once, the data is slowly "streaming" in and we need to join "on the fly."

The key idea in a streaming join is that although we must have a "pair" of joined records (i.e. one from each stream being joined) we don't know what order they will come in. (In fact, we don't know if any particular record will ever be joined--but let's assume for the moment that each record will find a mate and make a pair.)

In order to reliably join records with an unreliable order, we need to store a "backlog" of records from one table so that unmatched records from the other table can find their match, even if they arrived "too early" to have previously been given a match.

For example, suppose we have two streams, Users and Clicks. At first, both streams are empty. Let's say that we receive a Click:

> clickStream.sink.add(Click(id: 1, userId: 2));

At this point, we don't have any such "userId: 2", so at the point we receive the click, we can't transmit a joined pair of (User, Click) objects. Instead, we store the Click in a backlog and wait.

The opposite might also happen: we might receive a User before any of the user's clicks are recorded:

> userStream.sink.add(User(id: 1, name: 'Duane'));

In this case, we store the User in a map and also wait. Any subsequent Click objects with `userId: 1` will now be satisfied.

## Un-Abstract Code

The `streamingLeftJoin` code is a generalized (abstract) version of the following:

```dart
  var users = [
    User(3, 'Duane'),
    User(4, 'Jordan'),
    User(2, 'Brock'),
    User(1, 'Mystery')
  ];
  var clicks = [
    Click(1, 1, 160, 100), // pretend "x, y" coordinates from user 1
    Click(2, 3, 10, 50), // pretend "x, Y" coordinates from user 3
    Click(3, 1, 162, 103), // etc.
    Click(4, 2, 50, 50),
    Click(5, 4, 0, 0)
  ];

  var userStream = Stream.fromIterable(users);
  var clickStream = Stream.fromIterable(clicks);

  var clicksWaitingForUserId = <int, Set<Click>>{};
  var userIdMap = <int, User>{};

  var clickStreams = clickStream
      .partition((Click click) => userIdMap.containsKey(click.userId));

  clickStreams.falseStream.listen((click) {
    clicksWaitingForUserId.putIfAbsent(click.userId, () => {});
    clicksWaitingForUserId[click.userId]!.add(click);
  });

  var clickBacklog = StreamController<Click>();
  userStream.listen((User user) {
    userIdMap[user.userId] = user;
    clicksWaitingForUserId[user.userId]?.forEach((Click click) {
      clickBacklog.sink.add(click);
    });
  });

  var getPair = (Click click) => Join(userIdMap[click.userId]!, click);
  var trueJoinStream = clickStreams.trueStream.map(getPair);
  var backlogJoinStream = clickBacklog.stream.map(getPair);

  var finalStream = trueJoinStream.mergeWith([backlogJoinStream]);
  finalStream.listen((click) {
    print(click);
    /* prints:
      Join<User, Click>(User(3, Duane), Click(2, 3, 10, 50))
      Join<User, Click>(User(2, Brock), Click(4, 2, 50, 50))
      Join<User, Click>(User(4, Jordan), Click(5, 4, 0, 0))
      Join<User, Click>(User(1, Mystery), Click(1, 1, 160, 100))
      Join<User, Click>(User(1, Mystery), Click(3, 1, 162, 103))
    */
  });
```