import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/bloc/cubit_state.dart';
import 'package:potatoes/models/paginated_list.dart';

part 'list_state.dart';

typedef DataProvider<T> = Future<PaginatedList<T>> Function({int page});

class AutoLoadCubit<T> extends Cubit<AutoLoadState<T>> {
  final DataProvider<T> baseProvider;

  AutoLoadCubit({required DataProvider<T> provider})
    : baseProvider = provider,
    super(const AutoLoadingState())
  {
    initialize();
  }

  @protected
  DataProvider<T> get provider {
    return baseProvider;
  }

  @protected
  void initialize() {
    provider().then(
      (result) => emit(AutoLoadedState(result)),
      onError: (e, t) => emit(AutoLoadErrorState(e, t))
    );
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

      provider(page: stateBefore.items.page + 1).then(
        (result) => emit(stateBefore.addAll(result.items)),
        onError: (e, t) {
          emit(AutoLoadErrorState(e, t));
          emit(stateBefore);
        }
      );
    }
  }

  void reset() {
    emit(const AutoLoadingState());
    initialize();
  }
}