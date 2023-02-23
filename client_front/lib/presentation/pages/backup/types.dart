class SecretWord {
  String word;
  int order;
  int? chosenOrder;
  SecretWord({required this.word, required this.order});

  set chosen(int? value) => chosenOrder = value;
  int? get chosen => chosenOrder;
  bool get correct => order + 1 == chosenOrder;

  @override
  String toString() => 'SecretWord($word, $order, $chosenOrder)';
}
