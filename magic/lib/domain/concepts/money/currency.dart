enum Currency {
  usd,
  eur,
  yen,
  gbp,
  btc;

  bool get isFiat => [
        Currency.usd,
        Currency.eur,
        Currency.yen,
        Currency.gbp,
      ].contains(this);

  bool get isCrypto => this == btc;
}
