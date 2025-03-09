extension OrderedPairs<T> on List<T> {
  List<(T, T)> orderedPairs() => List.generate(length - 1, (i) => (this[i], this[i + 1]));

  List<E> mapOrderedPairs<E>(E Function((T, T)) toElement) => this.orderedPairs().map<E>(toElement).toList();

  List<(E, E)> orderedPairMap<E>(E Function(T) toElement) => this.map<E>(toElement).toList().orderedPairs();

  void forEachOrderedPair(void Function((T, T)) action) => this.orderedPairs().forEach(action);

  void forEachMappedOrderedPair<E>(E Function(T) toElement, void Function((E, E)) action) =>
      this.map<E>(toElement).toList().forEachOrderedPair(action);
}
