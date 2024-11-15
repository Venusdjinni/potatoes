import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [CubitManager] is a factory for a single Cubit type. It handles the
/// lifecycle of the cubits of a specific type by assigning id to each instance.
/// This is handy when you want to ensure that only one cubit of each id is
/// used across your app.
/// A classic use case could be managing posts cubits inside and app, with posts
/// objects that can be edited as the app runs. [CubitManager] will ensure that
/// only one cubit is associated to a specific post (given a unique post ID).
/// While using [CubitManager], you may not want the cubits to be automatically
/// closed by widgets such as [BlocProvider]. Be sure to always use
/// [BlocProvider.value] instead of the default constructor, as the latest
/// internally handle the created cubit lifecycle.
/// [CubitManager] needs three generic types in order to be instanced:
/// - [C] the cubit type to manage
/// - [T] the type of the object tracked by a cubit [C]
/// - [I] the type of the unique identifier of the [T] object, which will be
/// used to identify the cubits
abstract class CubitManager<C extends Cubit, T, I> {
  final Map<I, C> _cubits = {};

  /// specifies how to create a cubit from one object
  @protected
  C create(T object);

  /// specifies how to get the unique object identifier
  @protected
  I buildId(T object);

  /// When an object with the same ID as one already tracked emerged, this
  /// method is used to decide what to do. You can update the current tracked
  /// cubit or replacing it, for example
  void updateCubit(C cubit, T object);

  /// inserts a new object in the manager. This will initialize a new cubit
  /// bound to this object, or update the current one using [updateCubit].
  /// You can obtain the binded cubit by calling [get]
  void add(T object) {
    final id = buildId(object);
    final cubit = _cubits[id];

    if (cubit == null) {
      // l'objet n'existe pas encore, on l'ajoute
      _cubits[id] = create(object);
    } else {
      // la collection contient déjà cet identifiant
      if (cubit.isClosed) {
        // le cubit n'est plus actif, on le remplace par un nouveau
        remove(object);
        add(object);
      } else {
        updateCubit(cubit, object);
      }
    }
  }

  /// inserts several objects in the manager at once. See [add]
  void addAll(Iterable<T> objects) {
    for (T object in objects) {
      add(object);
    }
  }

  /// closes the cubit bound to this object and removes it from the track list
  void remove(T object) {
    _cubits.remove(buildId(object))?.close();
  }

  /// removes several cubits at once. See [remove]
  void removeAll(Iterable<T> objects) {
    for (T object in objects) {
      remove(object);
    }
  }

  /// returns the cubit bound to the given object.
  /// Throws an [UnsupportedError] if no cubit found. You should register new
  /// objects by using [add] before trying to get them
  C get(T object) {
    final id = buildId(object);
    final cubit = _cubits[id];
    if (cubit == null) {
      throw UnsupportedError("$C not found for $T id $id");
    }
    return cubit;
  }

  /// closes all cubits tracked and releases memory. Use this as a dispose method
  void clear() {
    for (C cubit in _cubits.values) {
      cubit.close();
    }
    _cubits.clear();
  }
}