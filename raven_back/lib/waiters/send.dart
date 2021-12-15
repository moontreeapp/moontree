import 'waiter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';

class SendWaiter extends Waiter {
  void init() {
    // may want to avoid sending the same transaction twice (in a row, not distinctUnique), in case they double click:
    /// we need to build a sendRequest object htat contains all the info about what we want to send (data we send to build transaction)
    streams.run.send.listen((SendRequest sendRequest) async {
      // build the transaction
      //// if failed to build send message to snackbar or alert message
      //// return
      // confirm the tranaction (send it)
      //// if failed to build send message to snackbar or alert message
      //// return
      // tell snackbar waiter to tell them result
      print('sendRequest: $sendRequest');
      var tuple = services.transaction.make.transactionBy(sendRequest);
      print('tuple ${tuple.item1}, ${tuple.item2}');
      // snackbar message - we should have a snack bar stream all that a widget on all pages listens to I guess...
      //confirmMessage(tx: tuple.item1, estimate: tuple.item2);
    });
  }
}
