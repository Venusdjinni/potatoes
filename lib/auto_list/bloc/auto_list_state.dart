part of 'auto_list_cubit.dart';

mixin AutoListState<T> on Equatable {}

class AutoListLoadingState<T> extends CubitLoadingState with AutoListState<T> {
  const AutoListLoadingState();
}

class AutoListReadyState<T> extends CubitSuccessState with AutoListState<T> {
  final PaginatedList<T> items;

  const AutoListReadyState(this.items);

  AutoListReadyState<T> addAll(List<T> others, {int? page, int? total}) {
    return AutoListReadyState(items.add(others: others, page: page, total: total));
  }

  AutoListReadyState<T> prependAll(List<T> others, {int? page, int? total}) {
    return AutoListReadyState(items.prepend(others: others, page: page, total: total));
  }

  AutoListReadyState<T> remove(T item, {bool update = false}) {
    return AutoListReadyState(items.remove(item, update: update));
  }

  @override
  List<Object?> get props => [items];
}

class AutoListLoadingMoreState<T> extends AutoListReadyState<T> {
  const AutoListLoadingMoreState(super.items);
}

class AutoListErrorState<T> extends CubitErrorState with AutoListState<T> {
  AutoListErrorState(super.error, [super.trace]);
}