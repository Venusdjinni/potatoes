import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CubitManager<C extends Cubit, T, I> {
  final Map<I, C> _cubits = {};

  C create(T object);

  I buildId(T object);

  void updateCubit(C cubit, T object);

  void add(T object) {
    final id = buildId(object);
    final cubit = _cubits[id];

    if (cubit == null) {
      // l'objet n'existe pas encore, on l'ajoute
      _cubits[id] = create(object);
    } else {
      // la collection contient déjà cet identifiant, on le remplace
      updateCubit(cubit, object);
    }
  }

  void addAll(Iterable<T> objects) {
    for (T object in objects) {
      add(object);
    }
  }

  void remove(T object) {
    _cubits.remove(buildId(object))?.close();
  }

  void removeAll(Iterable<T> objects) {
    for (T object in objects) {
      remove(object);
    }
  }

  C get(T object) {
    final id = buildId(object);
    final cubit = _cubits[id];
    if (cubit == null) {
      throw UnsupportedError("$C not found for $T id $id");
    }
    return cubit;
  }

  void clear() {
    for (C cubit in _cubits.values) {
      cubit.close();
    }
    _cubits.clear();
  }
}