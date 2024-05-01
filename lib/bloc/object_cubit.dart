import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ObjectCubit<O, S> extends Cubit<S> {
  late final StreamSubscription<S> _subscription;

  @protected
  O? object;

  ObjectCubit(super.initialState) {
    object = getObject(state);
    _subscription = stream.listen((state) {
      object = getObject(state) ?? object;
    });
  }

  @protected
  O? getObject(S state);

  void update(O object);

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}