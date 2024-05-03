import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A Cubit state representing a lasting success/idle state. Extend this class
/// and add all the relevant attributes you need to be in a success state
@immutable
abstract class CubitSuccessState extends Equatable {
  const CubitSuccessState();
}

/// A cubit state representing a timely information, for example the confirmation
/// of the execution of a process
@immutable
abstract class CubitInformationState extends Equatable {
  const CubitInformationState();

  @override
  List<Object?> get props => [identityHashCode(this)];
}

/// A cubit state representing a loading state. Cubit is fetching data and so
/// is not in a ready state
@immutable
abstract class CubitLoadingState extends Equatable {
  const CubitLoadingState();

  @override
  List<Object?> get props => [];
}

/// A cubit state representing an error. [CubitErrorState] can track the
/// originating error as well the stack trace. Each time a new [CubitErrorState]
/// is created, it is streamed into [CubitErrorState.stream] so that you could
/// implement a global error tracker/logger.
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
