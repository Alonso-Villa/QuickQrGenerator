import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

//Social Media Links>
const String Instagram = 'https://www.instagram.com/encorange_softwarelab/';
const String YouTube = 'https://www.youtube.com/@SoftwareLabEncorange';
const String Website = 'encorangelab.com';

const Color darkGreen = Color(0xFF189592); //purple
const Color lightGreen = Color(0xFF26D9C4);
//const Color greenLogo = Color(0xFF68CE4C);
const Color greenLogo = Color(0xFF26D9C4);
const Color backgroundGrey = Color(0xFFF8F8F8);
const Color backgroundBlack = Color(0xFF0C1D1D);

//URL Launcher.
Future<void> launchURL(_url) async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
