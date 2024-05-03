import 'package:flutter/material.dart';

/// A simple widget to rebuild the whole app tree from a [BuildContext].
/// Wrap your main widget (typically "MyApp") with this and simply call
/// Phoenix.rebirth(context) to rebuild the whole app.
class Phoenix extends StatefulWidget {
  final Widget child;

  const Phoenix({super.key, required this.child});

  /// rebuild the whole app from any point
  static void rebirth(BuildContext context) {
    final _PhoenixState? state = context.findAncestorStateOfType<_PhoenixState>();

    if (state == null) {
      throw UnsupportedError("context does not contain Phoenix in subtree");
    } else {
      state.restartApp();
    }
  }

  @override
  State<Phoenix> createState() => _PhoenixState();
}

class _PhoenixState extends State<Phoenix> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}