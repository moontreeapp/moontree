/// the point of the steward is to be a singleton that holds all long running objects
/// I know this sounds crazy but. lets just give it a try. it's a singleton.
///
/// alternative to this is: we can create waiters in the same way we create
/// the services and reservoirs at the beginning, and then pass the reservoirs
/// into the waiters that need them in the beginning, and pass the aiters into
/// the services that need them too.

class Steward {
  //static final Steward _singleton = Steward._();
  //static Steward get instance => _singleton;
  //Steward._();

  Steward._();
  static final Steward _instance = Steward._();
  factory Steward() {
    return _instance;
  }
}
