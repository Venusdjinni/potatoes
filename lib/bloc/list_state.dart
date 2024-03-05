part of 'list_cubit.dart';

mixin AutoLoadState<T> on Equatable {}

class AutoLoadingState<T> extends CubitLoadingState with AutoLoadState<T> {
  const AutoLoadingState();
}

class AutoLoadedState<T> extends CubitSuccessState with AutoLoadState<T> {
  final PaginatedList<T> items;

  const AutoLoadedState(this.items);

  AutoLoadedState<T> addAll(List<T> others, {int? page, int? total}) {
    return AutoLoadedState(items.add(others: others, page: page, total: total));
  }

  AutoLoadedState<T> prependAll(List<T> others, {int? page, int? total}) {
    return AutoLoadedState(items.prepend(others: others, page: page, total: total));
  }

  AutoLoadedState<T> remove(T item, {bool update = false}) {
    return AutoLoadedState(items.remove(item, update: update));
  }

  @override
  List<Object?> get props => [items];
}

class AutoLoadingMoreState<T> extends AutoLoadedState<T> {
  const AutoLoadingMoreState(super.items);
}

class AutoLoadErrorState<T> extends CubitErrorState with AutoLoadState<T> {
  AutoLoadErrorState(super.error, [super.trace]);
}