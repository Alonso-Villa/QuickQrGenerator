import 'package:flutter/material.dart';
import 'package:qrgenerator/main.dart';

class RoundIconButton extends StatelessWidget {
  RoundIconButton({super.key, required this.icon, required this.onPressed});

  IconData icon;
  VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      elevation: 0.5,
      child: Icon(icon, color: Colors.white),
      onPressed: onPressed,
      constraints: BoxConstraints.tightFor(
        width: 35.0,
        height: 35.0,
      ),
      shape: CircleBorder(),
      fillColor: darkBlue, //Colors.blueAccent.withAlpha(5),
    );
  }
}
