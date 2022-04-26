import 'dart:async';

//gatherFutures(Iterable<Functions> functions) {
//  var futures = <Future<Tx>>[];
//  futures.add(functions);
//  return futures;
//}

Timer doLater<T>(
  T Function() callback, {
  Duration? wait,
  int? waitInSeconds,
  int? waitInMilliseconds,
}) {
  wait = wait ??
      (waitInSeconds != null
          ? Duration(seconds: waitInSeconds)
          : Duration(milliseconds: waitInMilliseconds!));
  return Timer(wait, callback);
}
