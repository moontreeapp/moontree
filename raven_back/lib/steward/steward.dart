/// the point of the steward is to be a singleton that holds all long running objects
/// I know this sounds crazy but. lets just give it a try. it's a singleton.

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
