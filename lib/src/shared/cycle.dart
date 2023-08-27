class Cycle<E> implements Iterator {
  List<E> items;
  int _pos = -1;
  int? times;

  Cycle(this.items, {this.times});

  E? get cycle {
    return moveNext() ? current : null;
  }

  @override
  get current {
    if (_pos >= 0) return items[_pos % items.length];
  }

  @override
  bool moveNext() {
    _pos++;
    if (times == null) return true;
    times = times! - 1;
    return times! > 0;
  }
}
