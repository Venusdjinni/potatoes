import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/autoload.dart';

class AutoLoadContent<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T value) builder;
  final Widget Function(BuildContext context, SingleLoadState<T> state)? defaultBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;

  static Widget get<T>({
    required SingleLoadCubit<T> cubit,
    bool autoManage = true,
    required Widget Function(BuildContext context, T value) builder,
    Widget Function(BuildContext context, SingleLoadState<T> state)? defaultBuilder,
    WidgetBuilder? loadingBuilder,
    Widget Function(BuildContext context, VoidCallback retry)? errorBuilder
  }) {
    final listView = AutoLoadContent._(
      builder: builder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      defaultBuilder: defaultBuilder,
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
    this.defaultBuilder
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
          if (state is SingleLoadingState) {
            return widget.loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
          }
          if (state is SingleLoadErrorState) {
            return widget.errorBuilder?.call(context, cubit.reset) ?? const Text('error occured');
          }
          if (state is SingleLoadedState<T>) {
            return widget.builder(context, state.value);
          }
          return widget.defaultBuilder?.call(context, state) ?? const SizedBox();
        }
    );
  }
}
