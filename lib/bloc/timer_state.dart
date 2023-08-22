part of 'timer_cubit.dart';

abstract class ATimerState extends Equatable {
  const ATimerState();

  @override
  List<Object> get props => [];
}

class TimerInitializing extends ATimerState {
  const TimerInitializing() : super();
}

class TimerFinished extends ATimerState {
  const TimerFinished() : super();
}

class TimerState extends ATimerState {
  final Duration timer;

  const TimerState(this.timer) : super();

  TimerState increase(Duration duration) {
    return TimerState(timer + duration);
  }

  @override
  List<Object> get props => [timer];
}

typedef ValueChanged<T> = void Function(T value);

class TimerParams {
  final DateTime currentTime;
  final DateTime startTime;
  final DateTime endTime;
  final SendPort sendPort;

  const TimerParams(this.currentTime, this.startTime, this.endTime, this.sendPort);
}

class TimerIsolate {
  late ReceivePort _receivePort;
  Isolate? _isolate;

  void start({
    required DateTime startTime,
    required DateTime endTime,
    ValueChanged<dynamic>? onUpdate
  }) async {
    _receivePort = ReceivePort();
    Isolate.spawn(
      runTimer,
      TimerParams(DateTime.now(), startTime, endTime, _receivePort.sendPort),
    ).then((isolate) {
      _isolate = isolate;
      _receivePort.listen(onUpdate);
    });
  }

  void dispose() {
    _isolate?.kill();
    _isolate = null;
  }
}

void runTimer(TimerParams params) {
  final DateTime currentTime = params.currentTime;
  final DateTime startTime = params.startTime;
  final DateTime endTime = params.endTime;
  final SendPort sendPort = params.sendPort;

  final Duration maxDuration = endTime.difference(startTime);
  Duration timer = currentTime.difference(startTime);
  ATimerState state = const TimerState(Duration.zero);

  void emit(ATimerState newState) {
    state = newState;
    sendPort.send(state);
  }

  void updateTimer() {
    if (state is TimerState) {
      final stateBefore = state as TimerState;
      if (stateBefore.timer < maxDuration) {
        const second = Duration(seconds: 1);
        final newState = stateBefore.increase(second);
        emit(newState.timer < maxDuration ? newState : const TimerFinished());
        Future.delayed(second, updateTimer);
      } else {
        emit(const TimerFinished());
      }
    }
  }

  if (timer >= maxDuration) {
    emit(const TimerFinished());
  } else {
    emit(TimerState(timer));
    updateTimer();
  }
}