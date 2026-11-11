import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small floating message that stays compact on wide screens.
void showToast(BuildContext context, String message) {
  final w = math.min(380.0, MediaQuery.of(context).size.width - 32);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      width: w,
      duration: const Duration(seconds: 2),
    ));
}
