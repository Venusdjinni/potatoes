part of 'list_cubit.dart';

mixin AutoLoadState<T> on Equatable {}

class AutoLoadingState<T> extends CubitLoadingState with AutoLoadState<T> {
  const AutoLoadingState();
}

class AutoLoadedState<T> extends CubitSuccessState with AutoLoadState<T> {
  final PaginatedList<T> items;

  const AutoLoadedState(this.items);

  AutoLoadedState<T> addAll(List<T> others) {
    return AutoLoadedState(items.add(others: others));
  }

  AutoLoadedState<T> prependAll(List<T> others) {
    return AutoLoadedState(items.prepend(others: others));
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