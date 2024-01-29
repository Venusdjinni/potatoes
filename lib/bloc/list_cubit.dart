import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/bloc/cubit_state.dart';
import 'package:potatoes/models/paginated_list.dart';

part 'list_state.dart';

typedef DataProvider<T> = Future<PaginatedList<T>> Function({int page});

typedef StreamDataProvider<T> = Stream<PaginatedList<T>> Function({int page});

class AutoLoadCubit<T> extends Cubit<AutoLoadState<T>> {
  /// [dataProvider] is either a regular [DataProvider] or a [StreamDataProvider]
  final dynamic baseProvider;

  AutoLoadCubit({required DataProvider<T> provider})
    : baseProvider = provider,
    super(const AutoLoadingState())
  {
    initialize();
  }

  AutoLoadCubit.stream({required StreamDataProvider<T> provider})
    : baseProvider = provider,
    super(const AutoLoadingState())
  {
    initialize();
  }

  @protected
  dynamic get provider {
    return baseProvider;
  }

  @protected
  void initialize() {
    void onSuccess(result) => emit(AutoLoadedState(result));
    void onError(e, t) => emit(AutoLoadErrorState(e, t));

    if (provider is DataProvider<T>) {
      (provider as DataProvider).call().then(onSuccess, onError: onError);
    } else if (provider is StreamDataProvider) {
      (provider as StreamDataProvider).call().listen(onSuccess, onError: onError);
    }
  }

  void loadMore() {
    if (state is AutoLoadingMoreState) return;

    if (state is AutoLoadedState<T>) {
      final stateBefore = (state as AutoLoadedState<T>);
      if (stateBefore.items.hasReachedMax) {
        // plus de page à charger
        return;
      }
      emit(AutoLoadingMoreState(stateBefore.items));

      void onSuccess(result) => emit(stateBefore.addAll(result.items));
      void onError(e, t) => emit(AutoLoadErrorState(e, t));

      if (provider is DataProvider) {
        (provider as DataProvider)
          .call(page: stateBefore.items.page + 1)
          .then(onSuccess, onError: onError);
      } else if (provider is StreamDataProvider) {
        (provider as StreamDataProvider)
          .call(page: stateBefore.items.page + 1)
          .listen(onSuccess, onError: onError);
      }
    }
  }

  void reset() {
    emit(const AutoLoadingState());
    initialize();
  }
}