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
class CubitFailureState extends Equatable {
  final dynamic error;
  final StackTrace? trace;

  static void record(dynamic error, [StackTrace? trace]) {
    CubitFailureState(error, trace).recordError();
  }

  CubitFailureState(this.error, [this.trace]) {
    recordError();
  }

  @mustCallSuper
  void recordError() {
    log(error.toString(), stackTrace: trace);
    /// add error recording behavior
  }

  @override
  List<Object?> get props => [error, trace];
}
