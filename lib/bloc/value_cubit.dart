import 'package:flutter_bloc/flutter_bloc.dart';

class ValueCubit<T> extends Cubit<T> {
  ValueCubit(T value) : super(value);

  void set(T value) {
    emit(value);
  }
}

class InitialValueCubit<T> extends ValueCubit<T> {
  final T _initialValue;

  T get initialValue => _initialValue;

  InitialValueCubit(T value) : _initialValue = value, super(value);

  void reset() {
    emit(_initialValue);
  }
}