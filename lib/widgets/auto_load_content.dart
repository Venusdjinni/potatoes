import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/autoload.dart';

class AutoLoadContent<T> extends StatefulWidget {
  final Widget Function(BuildContext context, Widget child)? wrapper;
  final Widget Function(BuildContext context, T value) builder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;

  static Widget get<T>({
    required SingleLoadCubit<T> cubit,
    bool autoManage = true,
    required Widget Function(BuildContext context, T value) builder,
    Widget Function(BuildContext context, Widget child)? wrapper,
    WidgetBuilder? loadingBuilder,
    Widget Function(BuildContext context, VoidCallback retry)? errorBuilder
  }) {
    final listView = AutoLoadContent._(
      builder: builder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      wrapper: wrapper,
    );

    if (autoManage) {
      return BlocProvider(
        create: (_) => cubit,
        child: listView,
      );
    } else {
      return BlocProvider.value(
        value: cubit,
        child: listView,
      );
    }
  }

  const AutoLoadContent._({
    super.key,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.wrapper
  });

  @override
  State<AutoLoadContent> createState() => _AutoLoadContentState<T>();
}

class _AutoLoadContentState<T> extends State<AutoLoadContent<T>> {
  late final SingleLoadCubit<T> cubit = context.read();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SingleLoadCubit<T>, SingleLoadState<T>>(
        buildWhen: (_, state) {
          return state is SingleLoadingState ||
              state is SingleLoadedState ||
              state is SingleLoadErrorState;
        },
        builder: (context, state) {
          final Widget child;
          if (state is SingleLoadingState) {
            child = widget.loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
          } else if (state is SingleLoadErrorState) {
            child = widget.errorBuilder?.call(context, cubit.reset) ?? const Text('error occured');
          } else if (state is SingleLoadedState<T>) {
            child = widget.builder(context, state.value);
          } else {
            child = const SizedBox();
          }

          return widget.wrapper?.call(context, child) ?? child;
        }
    );
  }
}
