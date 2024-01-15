import 'dart:collection';

import 'package:equatable/equatable.dart';

class PaginatedList<T> extends Equatable {
  final List<T> _items;
  final int page;
  final int total;

  List<T> get items => UnmodifiableListView(_items);

  bool get hasReachedMax => items.length == total;

  PaginatedList({
    required Iterable<T> items,
    required this.page,
    required this.total
  }) : _items = List.of(items);

  static PaginatedList<T> fromJson<T>({
    required Map<String, dynamic> map,
    required T Function(Map<String, dynamic>) itemMapper,
    int? page,
  }) {
    return PaginatedList(
      items: (map["datas"] as Iterable).map((d) => itemMapper(d)),
      page: page ?? 0,
      total: map["totalElements"]
    );
  }

  PaginatedList<T> add({
    required Iterable<T> others,
    int? page
  }) {
    return PaginatedList(
      items: [..._items, ...others],
      page: page ?? (this.page + 1),
      total: total
    );
  }

  PaginatedList<T> prepend({
    required Iterable<T> others,
    int? page
  }) {
    return PaginatedList(
      items: [...others, ..._items],
      page: page ?? (this.page + 1),
      total: total
    );
  }

  @override
  List<Object?> get props => [_items, page, total];
}