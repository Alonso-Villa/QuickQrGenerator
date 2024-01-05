import 'package:flutter/material.dart';

class ResponsiveWidget extends StatefulWidget {
  final Widget largeScreen;
  final Widget smallScreen;

  const ResponsiveWidget(
      {required this.largeScreen, required this.smallScreen});

  @override
  State<ResponsiveWidget> createState() =>
      _ResponsiveWidgetState(this.largeScreen, this.smallScreen);
}

class _ResponsiveWidgetState extends State<ResponsiveWidget> {
  final Widget largeScreen;
  final Widget smallScreen;

  _ResponsiveWidgetState(this.largeScreen, this.smallScreen);

  @override
  Widget build(BuildContext context) {
    //Returns the widget which is more appropriate for the screen size
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return largeScreen;
      } else {
        //if small screen implementation not available, then return large screen
        return smallScreen ?? largeScreen;
      }
    });
  }

  //Making these methods static, so that they can be used as accessed from other widgets

  //Large screen is any screen whose width is more than 1200 pixels
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }

  //Small screen is any screen whose width is less than 800 pixels
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 800;
  }
}
