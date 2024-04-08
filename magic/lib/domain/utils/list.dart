extension ListToEnumeratedMapExtension<T> on List<T> {
  Map<int, T> get enumerated =>
      <int, T>{for (int i = 0; i < this.length; i += 1) i: this[i]};
}

Map<int, T> enumerated<T>(List<T> items) =>
    <int, T>{for (int i = 0; i < items.length; i += 1) i: items[i]};
