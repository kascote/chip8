class Stack<E> {
  final _list = List<E>.empty(growable: true);

  void push(E value) => _list.add(value);

  E? pop() => (isEmpty) ? null : _list.removeLast();

  E? get peek => (isEmpty) ? null : _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  String toString() => _list.toString();
}
