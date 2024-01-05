import 'package:flutter/material.dart';
import 'package:qrgenerator/Utils/constants.dart';
import 'package:qrgenerator/main.dart';

showAlertPopup(BuildContext context, String title, String message,
    String option1, String option2, pressedOption1) {
  AlertDialog alert = AlertDialog(
    title: Text(title,
        style: TextStyle(color: lightBlue, fontWeight: FontWeight.bold)),
    content: Text(message,
        style: TextStyle(color: darkBlue, fontWeight: FontWeight.normal)),
    backgroundColor: backgroundGrey,
    actions: [
      TextButton(
        child: Text(
          option1,
          style: TextStyle(color: lightBlue, fontWeight: FontWeight.bold),
        ),
        onPressed: pressedOption1,
      ),
      TextButton(
        child: Text(
          option2,
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
