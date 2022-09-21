class SecretWord {
  String word;
  int order;
  int? chosenOrder;
  SecretWord(this.word, this.order);

  void set chosen(int? value) => chosenOrder = value;
  int? get chosen => chosenOrder;
  bool get correct => order + 1 == chosenOrder;

  @override
  String toString() => 'SecretWord($word, $order, $chosenOrder)';
}
