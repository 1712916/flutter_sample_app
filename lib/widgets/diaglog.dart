import 'package:flutter/material.dart';

mixin ShowDialog on Widget {
  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => this,
    );
  }
}
