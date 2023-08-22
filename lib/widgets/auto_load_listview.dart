import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:potatoes/bloc/list_cubit.dart';

enum ViewType {
  list,
  grid,
  custom
}

class AutoLoadListView<T> extends StatefulWidget {
  final ViewType viewType;
  final Widget Function(BuildContext context, Widget child)? wrapper;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final Widget Function(BuildContext context, List<T> items)? customBuilder;
  final double loadRatio;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? errorBuilder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final SliverGridDelegate? gridDelegate;

  static Widget get<T>({
    ViewType viewType = ViewType.list,
    required AutoLoadCubit<T> cubit,
    bool autoManage = true,
    Widget Function(BuildContext context, T item)? itemBuilder,
    Widget Function(BuildContext context, Widget child)? wrapper,
    Widget Function(BuildContext context, List<T> items)? customBuilder,
    SliverGridDelegate? gridDelegate,
    double loadRatio = 0.8,
    WidgetBuilder? emptyBuilder,
    WidgetBuilder? errorBuilder,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    final listView = AutoLoadListView._(
      viewType: viewType,
      itemBuilder: itemBuilder,
      wrapper: wrapper,
      customBuilder: customBuilder,
      loadRatio: loadRatio,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
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

  AutoLoadListView._({
    super.key,
    this.viewType = ViewType.list,
    required this.itemBuilder,
    this.wrapper,
    this.customBuilder,
    this.loadRatio = 0.8,
    this.emptyBuilder,
    this.errorBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.gridDelegate
  }) {
    assert(0 < loadRatio && loadRatio <= 1);
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
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final maxScroll = controller.position.maxScrollExtent;
      if (controller.hasClients && controller.offset >= (maxScroll * widget.loadRatio)) {
        // chargement d'élements supplémentaires
        cubit.loadMore();
      }
    });
  }

  Widget contentView(List<T> items) {
    switch (widget.viewType) {
      case ViewType.list:
        return ListView.builder(
            itemBuilder: (c, i) => widget.itemBuilder!(c, items[i]),
            itemCount: items.length,
            physics: const PageScrollPhysics(),
            shrinkWrap: true
        );
      case ViewType.grid:
        return GridView.builder(
            gridDelegate: widget.gridDelegate!,
            itemBuilder: (c, i) => widget.itemBuilder!(c, items[i]),
            itemCount: items.length,
            physics: const PageScrollPhysics(),
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
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AutoLoadErrorState) {
            return widget.errorBuilder?.call(context) ?? const Text('error occured');
          }
          if (state is AutoLoadedState<T>) {
            final items = state.items;

            if (items.items.isEmpty) {
              final child = widget.emptyBuilder?.call(context) ?? const SizedBox();
              return widget.wrapper?.call(context, child) ?? child;
            }
            final child = ListView(
              controller: controller,
              padding: widget.padding,
              physics: widget.physics,
              shrinkWrap: widget.shrinkWrap,
              children: [
                contentView(items.items),
                if (state is AutoLoadingMoreState)
                  const Center(child: CircularProgressIndicator()),
              ],
            );

            return widget.wrapper?.call(context, child) ?? child;
          }

          return const SizedBox();
        }
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
