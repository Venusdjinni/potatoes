import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/auto_list/widgets/auto_list_view.dart';
import 'package:potatoes/common/bloc/cubit_state.dart';
import 'package:potatoes/auto_list/models/paginated_list.dart';

part 'auto_list_state.dart';

typedef DataProvider<T> = Future<PaginatedList<T>> Function({int page});

typedef StreamDataProvider<T> = Stream<PaginatedList<T>> Function({int page});

/// A [Cubit] used to load a paginated list. You may want to use it
/// in conjunction with [AutoListView]
class AutoListCubit<T> extends Cubit<AutoListState<T>> {
  /// The initial provider set from the constructor
  /// is either a [DataProvider] or a [StreamDataProvider]
  final dynamic baseProvider;

  /// A [DataProvider] is a function returning a [PaginatedList] each time being
  /// called. By calling the [DataProvider] multiple times with a different
  /// page parameter, [AutoListCubit] may merge those [PaginatedList] and track
  /// the resulting one.
  /// If you want to listen to a stream of [PaginatedList], see [AutoListCubit.stream]
  AutoListCubit({required DataProvider<T> provider})
    : baseProvider = provider,
    super(const AutoListLoadingState())
  {
    initialize();
  }

  /// TODO
  AutoListCubit.stream({required StreamDataProvider<T> provider})
    : baseProvider = provider,
    super(const AutoListLoadingState())
  {
    initialize();
  }

  /// override this if you want to set a custom behavior to the internal provider.
  /// For example, you may want to track an additional parameter unlike the base provider
  @protected
  dynamic get provider {
    return baseProvider;
  }

  @protected
  void initialize() {
    void onSuccess(result) => emit(AutoListReadyState(result));
    void onError(e, t) => emit(AutoListErrorState(e, t));

    try {
      if (provider is DataProvider<T>) {
        (provider as DataProvider).call().then(onSuccess, onError: onError);
      } else if (provider is StreamDataProvider) {
        (provider as StreamDataProvider).call().listen(onSuccess, onError: onError);
      }
    } catch (error, trace) {
      onError(error, trace);
    }
  }

  /// calls [provider] once again in other to obtain the next page of the
  /// [PaginatedList]. No action will be performed if the [state] meets one of
  /// the following:
  /// - state is already in a "loading more" state
  /// - [PaginatedList] is already fully loaded
  void loadMore() {
    if (state is AutoListLoadingMoreState) return;

    if (state is AutoListReadyState<T>) {
      final stateBefore = (state as AutoListReadyState<T>);
      if (stateBefore.items.hasReachedMax) {
        // plus de page à charger
        return;
      }
      emit(AutoListLoadingMoreState(stateBefore.items));

      void onSuccess(result) => emit(stateBefore.addAll(
        result.items,
        page: result.page,
        total: result.total
      ));
      void onError(e, t) {
        emit(AutoListLoadingMoreErrorState(
          stateBefore.items,
          AutoListErrorState(e, t)
        ));
      }

      try {
        if (provider is DataProvider) {
          (provider as DataProvider)
            .call(page: stateBefore.items.page + 1)
            .then(onSuccess, onError: onError);
        } else if (provider is StreamDataProvider) {
          (provider as StreamDataProvider)
            .call(page: stateBefore.items.page + 1)
            .listen(onSuccess, onError: onError);
        }
      } catch (error, trace) {
        print('>>>>>>');
        onError(error, trace);
      }
    }
  }

  /// reloads the cubit to its initial state, using the current configuration
  void reset() {
    emit(const AutoListLoadingState());
    initialize();
  }
}