extension ListExt<E> on List<E> {
  void addBasedOnCondition(E? element, {required bool condition}) {
    if (condition && element != null) add(element);
  }
}
