import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// An [ObjectCubit] is an implementation of a [Cubit] designed to handle the
/// lifecycle of a single object. This is specifically effective to track
/// business objects as you might want to update them while still tracking the
/// same Cubit.
/// [ObjectCubit] ensures that you can get the last version registered version
/// of the tracked object at anytime, regardless of the current cubit state.
/// [ObjectCubit] uses two generic types:
/// - [O] is the tracked object type
/// - [S] is cubit state type (same as the regular Cubit<S>)
abstract class ObjectCubit<O, S> extends Cubit<S> {
  // subscription used to track cubit state and update [object] to its latest value
  late final StreamSubscription<S> _subscription;

  /// returns the last registered value of the tracked object
  @protected
  O? object;

  ObjectCubit(super.initialState) {
    object = getObject(state);
    _subscription = stream.listen((state) {
      object = getObject(state) ?? object;
    });
  }

  /// get the value of the object from a specific state. If the given state
  /// does not track the object, just return null.
  @protected
  O? getObject(S state);

  /// use this convenience method to update the tracked object from an external
  /// source
  void update(O object);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}