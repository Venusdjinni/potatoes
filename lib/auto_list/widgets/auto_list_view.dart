import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/auto_list/bloc/auto_list_cubit.dart';
import 'package:potatoes/common/models/message.dart';

enum ViewType {
  list,
  grid,
  custom
}

enum DisplayMode {
  auto,
  manual
}

class AutoListView<T> extends StatefulWidget {
  final ViewType viewType;
  final Widget Function(BuildContext context, Widget child)? wrapper;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget Function(BuildContext context, List<T> items)? customBuilder;
  final DisplayMode displayMode;
  final Widget Function(BuildContext context, VoidCallback load)? manualLoadMoreBuilder;
  final double loadRatio;
  /// Overrides the default loader
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? loadingMoreBuilder;
  final WidgetBuilder? emptyBuilder;
  /// Overrides the default error display
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;
  /// This builder renders whenever a new state type is created for the
  /// [AutoListCubit]. New state types are created by overriding [AutoListState].
  /// You may not use this if you only use [AutoListCubit] in its regular cases.
  final Widget Function(BuildContext context, AutoListState<T> state)? defaultBuilder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool reverse;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final SliverGridDelegate? gridDelegate;

  static Widget _init<T>(bool autoManage, AutoListCubit<T> cubit, Widget child) {
    if (autoManage) {
      return BlocProvider(
        create: (_) => cubit,
        child: child,
      );
    } else {
      return BlocProvider.value(
        value: cubit,
        child: child,
      );
    }
  }

  /// Shows a [ListView] or a [GridView] displaying the current state of the
  /// data list. When scrolled at more than [loadRatio], [AutoListCubit.loadMore]
  /// is called to fetch the next page of data
  static Widget get<T>({
    ViewType viewType = ViewType.list,
    required AutoListCubit<T> cubit,
    /// whether or not the [AutoListCubit] should be disposed with this widget
    bool autoManage = true,
    Widget Function(BuildContext context, T item)? itemBuilder,
    Widget Function(BuildContext context, int index)? separatorBuilder,
    Widget Function(BuildContext context, Widget child)? wrapper,
    Widget Function(BuildContext context, List<T> items)? customBuilder,
    /// grid delegate to display the list as a grid
    SliverGridDelegate? gridDelegate,
    /// the threshold percentage of the list (of the [ScrollView]'s max extent)
    /// at which the next page of data is loaded
    double loadRatio = 0.8,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? loadingMoreBuilder,
    WidgetBuilder? emptyBuilder,
    Widget Function(BuildContext context, VoidCallback retry)? errorBuilder,
    Widget Function(BuildContext context, AutoListState<T> state)? defaultBuilder,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false
  }) {
    final listView = AutoListView._(
      viewType: viewType,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      wrapper: wrapper,
      customBuilder: customBuilder,
      displayMode: DisplayMode.auto,
      loadRatio: loadRatio,
      loadingBuilder: loadingBuilder,
      loadingMoreBuilder: loadingMoreBuilder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      defaultBuilder: defaultBuilder,
      padding: padding,
      physics: physics,
      reverse: reverse,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
    );

    return _init(autoManage, cubit, listView);
  }

  /// An [AutoListView] that does not automatically fetch next data. Call
  /// [AutoListCubit.loadMore] to do so.
  static Widget manual<T>({
    ViewType viewType = ViewType.list,
    required AutoListCubit<T> cubit,
    bool autoManage = true,
    Widget Function(BuildContext context, T item)? itemBuilder,
    Widget Function(BuildContext context, int index)? separatorBuilder,
    Widget Function(BuildContext context, Widget child)? wrapper,
    Widget Function(BuildContext context, List<T> items)? customBuilder,
    SliverGridDelegate? gridDelegate,
    Widget Function(BuildContext context, VoidCallback retry)? manualLoadMoreBuilder,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? loadingMoreBuilder,
    WidgetBuilder? emptyBuilder,
    Widget Function(BuildContext context, VoidCallback retry)? errorBuilder,
    Widget Function(BuildContext context, AutoListState<T> state)? defaultBuilder,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false
  }) {
    final listView = AutoListView._(
      viewType: viewType,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      wrapper: wrapper,
      customBuilder: customBuilder,
      displayMode: DisplayMode.manual,
      manualLoadMoreBuilder: manualLoadMoreBuilder,
      loadingBuilder: loadingBuilder,
      loadingMoreBuilder: loadingMoreBuilder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      defaultBuilder: defaultBuilder,
      padding: padding,
      physics: physics,
      reverse: reverse,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
    );

    return _init(autoManage, cubit, listView);
  }

  AutoListView._({
    super.key,
    this.viewType = ViewType.list,
    required this.itemBuilder,
    this.separatorBuilder,
    this.wrapper,
    this.customBuilder,
    this.displayMode = DisplayMode.auto,
    this.manualLoadMoreBuilder,
    this.loadRatio = 0.8,
    this.loadingBuilder,
    this.loadingMoreBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.defaultBuilder,
    this.padding,
    this.physics,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.gridDelegate
  }) {
    assert(0 < loadRatio && loadRatio <= 1);
    if (displayMode == DisplayMode.manual) {
      assert(manualLoadMoreBuilder != null);
    }
    if (viewType == ViewType.list) {
      assert(itemBuilder != null);
    } else if (viewType == ViewType.grid) {
      assert(itemBuilder != null && gridDelegate != null);
    } else if (viewType == ViewType.custom) {
      assert(customBuilder != null);
    }
  }

  @override
  State<AutoListView> createState() => _AutoListViewState<T>();
}

class _AutoListViewState<T> extends State<AutoListView<T>> {
  late final AutoListCubit<T> cubit = context.read();

  Widget contentView(List<T> items) {
    switch (widget.viewType) {
      case ViewType.list:
        return ListView.separated(
          itemBuilder: (c, i) => widget.itemBuilder!(c, items[i]),
          separatorBuilder: widget.separatorBuilder ?? (_, i) => const SizedBox(),
          itemCount: items.length,
          padding: EdgeInsets.zero,
          physics: const PageScrollPhysics(),
          scrollDirection: widget.scrollDirection,
          shrinkWrap: true
        );
      case ViewType.grid:
        return GridView.builder(
          gridDelegate: widget.gridDelegate!,
          itemBuilder: (c, i) => widget.itemBuilder!(c, items[i]),
          itemCount: items.length,
          padding: EdgeInsets.zero,
          physics: const PageScrollPhysics(),
          scrollDirection: widget.scrollDirection,
          shrinkWrap: true
        );
      case ViewType.custom:
        return widget.customBuilder!(context, items);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoListCubit<T>, AutoListState<T>>(
        buildWhen: (_, state) {
          return state is AutoListLoadingState ||
              state is AutoListReadyState ||
              state is AutoListErrorState;
        },
        builder: (context, state) {
          if (state is AutoListLoadingState) {
            return widget.loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
          }
          if (state is AutoListErrorState) {
            return widget.errorBuilder?.call(context, cubit.reset)
              ?? Text(PotatoesMessage.errorOccurred(context));
          }
          if (state is AutoListReadyState<T>) {
            final items = state.items;

            if (items.items.isEmpty) {
              final child = widget.emptyBuilder?.call(context) ?? const SizedBox();
              return widget.wrapper?.call(context, child) ?? child;
            }
            final Widget child;

            switch (widget.displayMode) {
              case DisplayMode.auto:
                child = NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    final maxScroll = n.metrics.maxScrollExtent;
                    if (n.metrics.pixels >= (maxScroll * widget.loadRatio)) {
                      // chargement d'élements supplémentaires
                      cubit.loadMore();
                    }
                    // we don't want to cancel notification bubbling, since
                    // upper widgets may want to listen to events
                    return false;
                  },
                  child: ListView(
                    padding: widget.padding,
                    physics: widget.physics,
                    shrinkWrap: widget.shrinkWrap,
                    reverse: widget.reverse,
                    scrollDirection: widget.scrollDirection,
                    children: [
                      contentView(items.items),
                      if (state is AutoListLoadingMoreState)
                        widget.loadingMoreBuilder?.call(context) ?? const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                );
                break;
              case DisplayMode.manual:
                child = ListView(
                  padding: widget.padding,
                  physics: widget.physics,
                  shrinkWrap: widget.shrinkWrap,
                  reverse: widget.reverse,
                  scrollDirection: widget.scrollDirection,
                  children: [
                    contentView(items.items),
                    if (!state.items.hasReachedMax && state is! AutoListLoadingMoreState)
                      widget.manualLoadMoreBuilder!.call(context, cubit.loadMore),
                    if (state is AutoListLoadingMoreState)
                      widget.loadingMoreBuilder?.call(context) ?? const Center(child: CircularProgressIndicator()),
                  ],
                );
                break;
            }

            return widget.wrapper?.call(context, child) ?? child;
          }

          final defaultWidget = widget.defaultBuilder?.call(context, state) ?? const SizedBox();
          return widget.wrapper?.call(context, defaultWidget) ?? defaultWidget;
        }
    );
  }
}
