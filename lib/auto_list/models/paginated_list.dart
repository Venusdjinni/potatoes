import 'dart:collection';

import 'package:equatable/equatable.dart';

/// [PaginatedList] is a representation of a portion of a bigger list at
/// a given time. This is used to track a remote list while locally supporting
/// only a small portion of data.
/// - [items] is the current list of fetched data. [items]'s length is lesser
/// or equals to [total]
/// - [page] is the last tracked page of the remote list
/// - [total] is the length of the remote list
class PaginatedList<T> extends Equatable {
  final List<T> _items;
  final int page;
  final int total;

  List<T> get items => UnmodifiableListView(_items);

  /// whether the local list is the same length as the remote list
  bool get hasReachedMax => items.length >= total;

  PaginatedList({
    required Iterable<T> items,
    required this.page,
    required this.total
  }) : _items = List.of(items);

  /// adds items at the end of the current list. You can set the current page
  /// or total according to the data source
  PaginatedList<T> add({
    required Iterable<T> others,
    int? page,
    int? total,
  }) {
    return PaginatedList(
      items: [..._items, ...others],
      page: page ?? this.page,
      total: total ?? (this.total)
    );
  }

  /// adds items at the beginning of the current list. You can set the current page
  /// or total according to the data source
  PaginatedList<T> prepend({
    required Iterable<T> others,
    int? page,
    int? total,
  }) {
    return PaginatedList(
      items: [...others, ..._items],
      page: page ?? this.page,
      total: total ?? (this.total)
    );
  }

  /// removes an item from the list. Set [update] to true in order to remove
  /// one to the [total] value. Keep in mind that [total] tracks the length of
  /// the remote list, so you might get inconsistencies when editing it
  PaginatedList<T> remove(
    T item,
    {bool update = false}
  ) {
    return PaginatedList(
      items: List.of(items)..remove(item),
      page: page,
      total: total - (update ? 1 : 0)
    );
  }

  @override
  List<Object?> get props => [_items, page, total];
}