import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mamanike/theme.dart';

class LoadingWidget{
  static void showLoadingDialog(BuildContext context,) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: appTheme.colorScheme.primary,
                size: 40
            ),
          );
        }
    );
  }

  static void hideloadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}