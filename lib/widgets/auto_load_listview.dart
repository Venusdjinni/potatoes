import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/bloc/list_cubit.dart';

enum ViewType {
  list,
  grid,
  custom
}

enum DisplayMode {
  auto,
  manual
}

class AutoLoadListView<T> extends StatefulWidget {
  final ViewType viewType;
  final Widget Function(BuildContext context, Widget child)? wrapper;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget Function(BuildContext context, List<T> items)? customBuilder;
  final DisplayMode displayMode;
  final Widget Function(BuildContext context, VoidCallback load)? manualLoadMoreBuilder;
  final double loadRatio;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? loadingMoreBuilder;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;
  final Widget Function(BuildContext context, AutoLoadState<T> state)? defaultBuilder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool reverse;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final SliverGridDelegate? gridDelegate;

  static Widget _init<T>(bool autoManage, AutoLoadCubit<T> cubit, Widget child) {
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

  static Widget get<T>({
    ViewType viewType = ViewType.list,
    required AutoLoadCubit<T> cubit,
    bool autoManage = true,
    Widget Function(BuildContext context, T item)? itemBuilder,
    Widget Function(BuildContext context, int index)? separatorBuilder,
    Widget Function(BuildContext context, Widget child)? wrapper,
    Widget Function(BuildContext context, List<T> items)? customBuilder,
    SliverGridDelegate? gridDelegate,
    double loadRatio = 0.8,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? loadingMoreBuilder,
    WidgetBuilder? emptyBuilder,
    Widget Function(BuildContext context, VoidCallback retry)? errorBuilder,
    Widget Function(BuildContext context, AutoLoadState<T> state)? defaultBuilder,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false
  }) {
    final listView = AutoLoadListView._(
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

  static Widget manual<T>({
    ViewType viewType = ViewType.list,
    required AutoLoadCubit<T> cubit,
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
    Widget Function(BuildContext context, AutoLoadState<T> state)? defaultBuilder,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false
  }) {
    final listView = AutoLoadListView._(
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

  AutoLoadListView._({
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
  State<AutoLoadListView> createState() => _AutoLoadListViewState<T>();
}

class _AutoLoadListViewState<T> extends State<AutoLoadListView<T>> {
  late final AutoLoadCubit<T> cubit = context.read();

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
    return BlocBuilder<AutoLoadCubit<T>, AutoLoadState<T>>(
        buildWhen: (_, state) {
          return state is AutoLoadingState ||
              state is AutoLoadedState ||
              state is AutoLoadErrorState;
        },
        builder: (context, state) {
          if (state is AutoLoadingState) {
            return widget.loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
          }
          if (state is AutoLoadErrorState) {
            return widget.errorBuilder?.call(context, cubit.reset) ?? const Text('error occured');
          }
          if (state is AutoLoadedState<T>) {
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
                    if (widget.reverse) {
                      if (n.metrics.pixels <= (maxScroll * (1 - widget.loadRatio))) {
                        // chargement d'élements supplémentaires
                        cubit.loadMore();
                      }
                    } else {
                      if (n.metrics.pixels >= (maxScroll * widget.loadRatio)) {
                        // chargement d'élements supplémentaires
                        cubit.loadMore();
                      }
                    }
                    // we don't want to cancel notification bubbling, since
                    // upper widgets may want to listen to them
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
                      if (state is AutoLoadingMoreState)
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
                    if (!state.items.hasReachedMax && state is! AutoLoadingMoreState)
                      widget.manualLoadMoreBuilder!.call(context, cubit.loadMore),
                    if (state is AutoLoadingMoreState)
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
