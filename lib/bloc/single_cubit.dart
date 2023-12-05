import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/bloc/cubit_state.dart';

part 'single_state.dart';

class SingleLoadCubit<T> extends Cubit<SingleLoadState<T>> {
  final Future<T> provider;

  SingleLoadCubit({required this.provider}) : super(const SingleLoadingState()) {
    initialize();
  }

  @protected
  void initialize() {
    provider.then(
      (result) => emit(SingleLoadedState(result)),
      onError: (e, t) => emit(SingleLoadErrorState(e, t))
    );
  }

  void reset() {
    emit(const SingleLoadingState());
    initialize();
  }
}