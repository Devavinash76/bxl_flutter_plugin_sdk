import 'package:flutter/material.dart';

class CustomGradientButton extends StatelessWidget {
  const CustomGradientButton({
    Key? key,
    required this.buttonLabel,
    this.onPressed,
  }) : super(key: key);

  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final kButtonStyle = TextButton.styleFrom(
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    );

    final buttonColor = (onPressed != null)
        ? [Colors.orange, Colors.deepOrange]
        : [Colors.grey, Colors.grey.shade300];

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            colors: buttonColor,
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: TextButton(
          onPressed: onPressed ?? () {},
          style: kButtonStyle,
          child: Text(buttonLabel, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
