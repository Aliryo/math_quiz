import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class MySnackbar {
  static ScaffoldMessengerState success(
    BuildContext context, {
    required String message,
  }) {
    return ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Sukses',
          message: message,
          contentType: ContentType.success,
          inMaterialBanner: true,
        ),
      ));
  }

  static ScaffoldMessengerState failed(
    BuildContext context, {
    required String message,
  }) {
    return ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Oops',
          message: message,
          contentType: ContentType.failure,
          inMaterialBanner: true,
        ),
      ));
  }
}
