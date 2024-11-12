extension OrderedPairs<T> on List<T> {
  List<(T, T)> orderedPairs() {
    List<(T, T)> result = List.empty(growable: true);
    for (int i = 0; i < this.length - 1; i++) {
      T t1 = this[i];
      T t2 = this[i + 1];
      result.add((t1, t2));
    }
    return result;
  }

  List<E> mapOrderedPairs<E>(E Function((T, T)) toElement) => this.orderedPairs().map<E>(toElement).toList();

  List<(E, E)> orderedPairMap<E>(E Function(T) toElement) => this.map<E>(toElement).toList().orderedPairs();

  void forEachOrderedPair(void Function((T, T)) action) => this.orderedPairs().forEach(action);

  void forEachMappedOrderedPair<E>(E Function(T) toElement, void Function((E, E)) action) =>
      this.map<E>(toElement).toList().forEachOrderedPair(action);
}
