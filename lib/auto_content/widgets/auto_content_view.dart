import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/auto_content/bloc/auto_content_cubit.dart';

/// A widget to display a data obtain from an [AutoContentCubit]. Its meant to
/// display something at each stage of the completion of the Future
class AutoContentView<T> extends StatefulWidget {
  /// Default builder. Displays the data once obtained
  final Widget Function(BuildContext context, T value) builder;
  /// This builder renders whenever a new state type is created for the
  /// [AutoContentCubit]. New state types are created by overriding [AutoContentState].
  /// You may not use this if you only use [AutoContentCubit] in its regular cases.
  final Widget Function(BuildContext context, AutoContentState<T> state)? defaultBuilder;
  /// Overrides the default loader
  final WidgetBuilder? loadingBuilder;
  /// Overrides the default error display
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;

  static Widget get<T>({
    /// The [AutoContentCubit] tracked to display loading states
    required AutoContentCubit<T> cubit,
    /// whether or not the [AutoContentCubit] should be disposed with this widget
    bool autoManage = true,
    required Widget Function(BuildContext context, T value) builder,
    Widget Function(BuildContext context, AutoContentState<T> state)? defaultBuilder,
    WidgetBuilder? loadingBuilder,
    Widget Function(BuildContext context, VoidCallback retry)? errorBuilder
  }) {
    final listView = AutoContentView._(
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

  const AutoContentView._({
    super.key,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.defaultBuilder
  });

  @override
  State<AutoContentView> createState() => _AutoContentViewState<T>();
}

class _AutoContentViewState<T> extends State<AutoContentView<T>> {
  late final AutoContentCubit<T> cubit = context.read();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoContentCubit<T>, AutoContentState<T>>(
        buildWhen: (_, state) {
          return state is AutoContentLoadingState ||
              state is AutoContentReadyState ||
              state is AutoContentErrorState;
        },
        builder: (context, state) {
          if (state is AutoContentLoadingState) {
            return widget.loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
          }
          if (state is AutoContentErrorState) {
            return widget.errorBuilder?.call(context, cubit.reset) ?? const Text('error occurred');
          }
          if (state is AutoContentReadyState<T>) {
            return widget.builder(context, state.value);
          }
          return widget.defaultBuilder?.call(context, state) ?? const SizedBox();
        }
    );
  }
}
