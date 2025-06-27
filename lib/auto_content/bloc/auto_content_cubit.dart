import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/auto_content/widgets/auto_content_view.dart';
import 'package:potatoes/common/bloc/cubit_state.dart';

part 'auto_content_state.dart';

/// A [Cubit] used to load a single value from a future. You may want to use it
/// in conjunction with [AutoContentView]
class AutoContentCubit<T> extends Cubit<AutoContentState<T>> {
  /// the function to execute in order to get the desired data. Unlike a regular
  /// [Future], a function returning a provider can be called multiple times,
  /// forcing the reset of the computation
  final Future<T> Function() provider;

  AutoContentCubit({required this.provider}) : super(const AutoContentLoadingState()) {
    initialize();
  }

  @protected
  void initialize() async {
    try {
      final result = await provider();
      emit(AutoContentReadyState(result));
    } catch (e, t) {
      emit(AutoContentErrorState(e, t));
    }
  }

  /// reloads the cubit to its initial state
  void reset() {
    emit(const AutoContentLoadingState());
    initialize();
  }
}