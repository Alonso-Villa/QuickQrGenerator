import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton(
      {super.key,
      required this.color,
      required this.textColor,
      required this.title,
      required this.width,
      required this.pressed});

  Color color;
  Color textColor;
  double width;
  String title;
  VoidCallback pressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          minWidth: width,
          height: 60.0,
          onPressed: pressed,
          child: Text(
            title,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.normal, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
