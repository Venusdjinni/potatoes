import 'dart:async';

import 'package:flutter/material.dart';

/// [CompletableMixin] is an extension allowing you to seamlessly add a whole
/// screen loader on your page. Assign a value to [loadingDialogCompleter] to
/// display your loader, then call [waitForDialog] in order to dismiss it.
mixin CompletableMixin<T extends StatefulWidget> on State<T> {
  Completer<BuildContext>? loadingDialogCompleter;

  Future<void> waitForDialog() async {
    if (loadingDialogCompleter != null) {
      final loadingDialogContext = await loadingDialogCompleter!.future;
      // ignore: use_build_context_synchronously
      Navigator.pop(loadingDialogContext);
      loadingDialogCompleter = null;
    }
  }
}

Completer<BuildContext> _showLoadingBarrier({
  required BuildContext context,
  bool decoration = false,
  String? text
}) {
  final Completer<BuildContext> completer = Completer();

  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (context) {
      if (!completer.isCompleted) {
        completer.complete(context);
      }

      return PopScope(
        canPop: false,
        child: decoration
          ? AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 32.0),
                  Expanded(
                    child: Text(
                      text ?? "Loading…",
                      style: Theme.of(context).textTheme.titleSmall
                    )
                  )
                ],
              ),
            )
          : const SizedBox(),
      );
    },
  );

  return completer;
}

/// A simple loader that can be used in conjunction with [CompletableMixin].
/// Displays a simple [AlertDialog] that covers the whole screen until dismissed.
/// User cannot dismiss it from screen touch or back press.
Completer<BuildContext> showLoadingBarrier({
  required BuildContext context,
  String? text
}) {
  return _showLoadingBarrier(
    context: context,
    decoration: true,
    text: text
  );
}

/// A simple loader that can be used in conjunction with [CompletableMixin].
/// Displays a translucent barrier that covers the whole screen until dismissed.
/// User cannot dismiss it from screen touch or back press.
Completer<BuildContext> showSimpleLoadingBarrier({
  required BuildContext context
}) {
  return _showLoadingBarrier(
    context: context,
    decoration: false,
  );
}
