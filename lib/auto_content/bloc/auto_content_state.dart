part of 'auto_content_cubit.dart';

mixin AutoContentState<T> on Equatable {}

class AutoContentLoadingState<T> extends CubitLoadingState with AutoContentState<T> {
  const AutoContentLoadingState();
}

class AutoContentReadyState<T> extends CubitSuccessState with AutoContentState<T> {
  final T value;

  const AutoContentReadyState(this.value);

  @override
  List<Object?> get props => [value];
}

class AutoContentErrorState<T> extends CubitErrorState with AutoContentState<T> {
  AutoContentErrorState(super.error, [super.trace]);
}