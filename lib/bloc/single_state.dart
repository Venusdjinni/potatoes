part of 'single_cubit.dart';

mixin SingleLoadState<T> on Equatable {}

class SingleLoadingState<T> extends CubitLoadingState with SingleLoadState<T> {
  const SingleLoadingState();
}

class SingleLoadedState<T> extends CubitSuccessState with SingleLoadState<T> {
  final T value;

  const SingleLoadedState(this.value);

  @override
  List<Object?> get props => [value];
}

class SingleLoadErrorState<T> extends CubitErrorState with SingleLoadState<T> {
  SingleLoadErrorState(super.error, [super.trace]);
}