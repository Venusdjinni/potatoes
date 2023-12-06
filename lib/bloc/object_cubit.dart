import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ObjectCubit<O, S> extends Cubit<S> {
  @protected
  O? object;

  ObjectCubit(super.initialState) {
    object = getObject(state);
    stream.listen((state) {
      object = getObject(state) ?? object;
    });
  }

  @protected
  O? getObject(S state);

  void update(O object);
}