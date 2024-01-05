import 'package:flutter/material.dart';
import 'package:qrgenerator/Utils/constants.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 20.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(greenLogo),
      backgroundColor: Colors.black,
    ),
  );
}

linearProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 1.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(greenLogo),
      backgroundColor: Colors.black,
    ),
  );
}
