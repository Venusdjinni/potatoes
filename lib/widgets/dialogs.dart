import 'dart:async';

import 'package:flutter/material.dart';

mixin CompletableMixin {
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

      return WillPopScope(
        onWillPop: () async => false,
        child: decoration
          ? AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 32.0),
                  Expanded(
                    child: Text(
                      text ?? "Chargement...",
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

Completer<BuildContext> showSimpleLoadingBarrier({
  required BuildContext context
}) {
  return _showLoadingBarrier(
    context: context,
    decoration: false,
  );
}
