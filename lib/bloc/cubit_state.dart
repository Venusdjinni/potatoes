import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class CubitSuccessState extends Equatable {
  const CubitSuccessState();
}

@immutable
class CubitInformationState extends Equatable {
  const CubitInformationState();

  @override
  List<Object?> get props => [identityHashCode(this)];
}

@immutable
class CubitLoadingState extends Equatable {
  const CubitLoadingState();

  @override
  List<Object?> get props => [];
}

@immutable
class CubitErrorState extends Equatable {
  final dynamic error;
  final StackTrace? trace;

  static final _controller = StreamController<CubitErrorState>.broadcast();

  static Stream<CubitErrorState> stream() => _controller.stream;

  static void record(dynamic error, [StackTrace? trace]) {
    CubitErrorState(error, trace).recordError();
  }

  CubitErrorState(this.error, [this.trace]) {
    recordError();
  }

  @mustCallSuper
  void recordError() {
    log(error.toString(), stackTrace: trace);
    /// add error recording behavior
    _controller.add(this);
  }

  @override
  List<Object?> get props => [error, trace];
}
