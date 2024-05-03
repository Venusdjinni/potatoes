import 'package:flutter_bloc/flutter_bloc.dart';

/// A [Cubit] to wrap a single type
class ValueCubit<T> extends Cubit<T> {
  ValueCubit(super.value);

  /// change the value tracked by the cubit
  void set(T value) {
    emit(value);
  }
}

/// A [Cubit] to wrap a single type with an initial value. Use
/// [reset] to revert the cubit to its initial value
class InitialValueCubit<T> extends ValueCubit<T> {
  final T _initialValue;

  T get initialValue => _initialValue;

  InitialValueCubit(super.value) : _initialValue = value;

  /// revert to initial value
  void reset() {
    emit(_initialValue);
  }
}