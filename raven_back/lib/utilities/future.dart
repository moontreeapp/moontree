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
}) async {
  wait = wait ??
      (waitInSeconds != null
          ? Duration(seconds: waitInSeconds)
          : Duration(milliseconds: waitInMilliseconds!));
  Timer x = Timer(wait, callback);
  return x;
}

 //if (_timer != null) {
 //   _timer.cancel();
 // }
 
//Future<T> scope<T>(Future<T> Function() callback) async {
//  var x;
//  try {
//    x = await callback();
//  } catch (e) {
//    // reconnect on any error, not just server disconnected } on StateError {
//    streams.client.client.add(null);
//    while (streams.client.client.value == null) {
//      await Future.delayed(Duration(milliseconds: 100));
//    }
//
//    /// making this two layers deep because we got an error here too...
//    /// saw the error gain in catch, so ... we need to either make it recursive, or something.
//    try {
//      x = await callback();
//    } catch (e) {
//      // reconnect on any error, not just server disconnected } on StateError {
//      streams.client.client.add(null);
//      while (streams.client.client.value == null) {
//        await Future.delayed(Duration(milliseconds: 100));
//      }
//      x = await callback();
//    }
//  }
//  return x;
//}
//