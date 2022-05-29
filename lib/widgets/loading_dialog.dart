import 'package:flutter/material.dart';

class LoadingDialog {
  LoadingDialog._i();

  static bool _isLoading = false;

  static show(BuildContext context) {
    if (!_isLoading) {
      _isLoading = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }
  }

  static close(BuildContext context) {
    if (_isLoading) {
      Navigator.of(context).pop();
      _isLoading = false;
    }
  }

  static doSomething(BuildContext context, {Function? call, Function(dynamic)? onDone}) async {
    LoadingDialog.show(context);
    var response = await call?.call();
    LoadingDialog.close(context);
    onDone?.call(response);
  }
}