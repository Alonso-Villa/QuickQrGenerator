import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qrgenerator/Utils/alertDialog.dart';
import 'package:qrgenerator/Utils/constants.dart';
import 'package:qrgenerator/Utils/rounded_button.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
        apiKey: "AIzaSyBfmvwE_om32sQLB8EgBpfBwfBRTRSBNko",
        authDomain: "softwarelab-by-encorange.firebaseapp.com",
        projectId: "softwarelab-by-encorange",
        storageBucket: "softwarelab-by-encorange.appspot.com",
        messagingSenderId: "182804209799",
        appId: "1:182804209799:web:384dd4de2413aa8e951822",
        measurementId: "G-WG6K1686BX"),
  );
  runApp(const MyApp());
}

const Color backgroundBlue = Color(0xFF90B7D1); //purple
const Color darkBlue = Color(0xFF032137);
const Color lightBlue = Color(0xFF0282C7);
const Color flashGreen = Color(0xFF1FD1B9);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Futura'),
      title: 'Generador rápido de codigos QR',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = GlobalKey();
  String data = '';
  bool toggleLanguage = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Detect platform and handle saving differently
      if (kIsWeb) {
        // Create a blob URL and download the file in web
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "screenshot.png")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Future: Implement mobile storage saving logic here if needed
      }

      print("Image processed.");
    } catch (e) {
      print(e.toString());
    }
  }

  TextEditingController textController = TextEditingController();

  void handleSubmit(String value) {
    setState(() {
      data = value;
    });
  }

// Declare your state variables
  Color pickerColor = const Color(0xFF0282C7);
  Color currentColor = darkBlue;
  Color codeBackground = Colors.white;
  bool roundedCorners = false;
  bool outline = false;
  double outlineWidth = 1;
  String codeText = '';
  double codeTextSize = 20;

  // variable to hold image to be displayed
  late Uint8List imageFile;
  bool imageAvailable = false;

// This method is called when a new color is picked in the picker
  void changeColor(Color color) {
    setState(() {
      pickerColor = color; // Update the picker color
      currentColor = color; // Update the current color which is used in your UI
    });
  }

  void changeBackColor(Color color) {
    setState(() {
      pickerColor = color; // Update the picker color
      codeBackground =
          color; // Update the current color which is used in your UI
    });
  }

// This method is triggered when the 'Select' button is pressed in the dialog
  void updateColor() {
    setState(() {
      currentColor =
          pickerColor; // Update the current color to the picked color
    });
    Navigator.of(context).pop(); // Close the dialog
  }

  void updateBackfroundColor() {
    setState(() {
      codeBackground =
          pickerColor; // Update the current color to the picked color
    });
    Navigator.of(context).pop(); // Close the dialog
  }

// Method to show the color picker dialog
  showPopup(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(toggleLanguage ? 'Elegir color' : 'Choose a color',
          style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
          child: MaterialPicker(
        pickerColor: pickerColor, // Use the pickerColor as the initial value
        onColorChanged: changeColor, // Call changeColor when a color is picked
      )),
      actions: [
        ElevatedButton(
          child: Text(toggleLanguage ? 'Seleccionar' : 'Select'),
          onPressed: updateColor, // Call updateColor when the button is pressed
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showBackPopup(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(toggleLanguage ? 'Elegir color' : 'Choose a color',
          style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
          child: MaterialPicker(
        pickerColor: pickerColor, // Use the pickerColor as the initial value
        onColorChanged:
            changeBackColor, // Call changeColor when a color is picked
      )),
      actions: [
        ElevatedButton(
          child: Text(toggleLanguage ? 'Seleccionar' : 'Select'),
          onPressed:
              updateBackfroundColor, // Call updateColor when the button is pressed
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      extendBodyBehindAppBar: true,
      appBar: data.isNotEmpty
          ? AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 100,
              leading: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: data.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                tooltip: toggleLanguage
                                    ? 'Volver a emepezar'
                                    : 'Start over',
                                onPressed: () {
                                  showAlertPopup(
                                      context,
                                      toggleLanguage
                                          ? 'Volver al paso 1'
                                          : 'Go back step 1',
                                      toggleLanguage
                                          ? 'Se tendrá que volver a generar un nuevo código QR'
                                          : 'A new QR Code will have to be generated',
                                      'OK',
                                      toggleLanguage ? 'Cancelar' : 'Cancel',
                                      () {
                                    setState(() {
                                      data = '';
                                      Navigator.pop(context);
                                    });
                                  });
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: darkBlue,
                                  size: 30,
                                )),
                            Image.asset(
                              'images/Logo_generator.png',
                              height: 80,
                              width: 80,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('QuickQR',
                                    style: TextStyle(
                                        color: darkBlue,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700)),
                                Image.asset(
                                  'images/Tagline.png',
                                  width: 80,
                                  color: lightBlue,
                                ),
                              ],
                            ),
                          ],
                        )
                      : Container()),
              leadingWidth: 300,
              elevation: 0.0,
              bottomOpacity: 0.0,
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
                  child: IconButton(
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          toggleLanguage ? 'EN' : 'ES',
                          style: const TextStyle(
                              color: lightBlue, fontWeight: FontWeight.bold),
                        ),
                        toggleLanguage
                            ? const Text('English',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue))
                            : const Text('Españól',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue)),
                      ],
                    ),
                    hoverColor: Colors.grey.withOpacity(0.8),
                    //iconSize: 20.0,
                    tooltip: toggleLanguage == true
                        ? 'Change language to English'
                        : 'Cambiar idioma a Españól',
                    onPressed: () {
                      setState(() {
                        toggleLanguage == false
                            ? toggleLanguage = true
                            : toggleLanguage = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: RoundIconButton(
                //       icon: Icons.info_outline, onPressed: () {}),
                // ),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          toggleLanguage ? 'EN' : 'ES',
                          style: const TextStyle(
                              color: lightBlue, fontWeight: FontWeight.bold),
                        ),
                        toggleLanguage
                            ? const Text('English',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue))
                            : const Text('Españól',
                                style:
                                    TextStyle(fontSize: 6.0, color: darkBlue)),
                      ],
                    ),
                    hoverColor: Colors.grey.withOpacity(0.8),
                    //iconSize: 20.0,
                    tooltip: toggleLanguage == true
                        ? 'Change language to English'
                        : 'Cambiar idioma a Españól',
                    onPressed: () {
                      setState(() {
                        toggleLanguage == false
                            ? toggleLanguage = true
                            : toggleLanguage = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 30),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
                //   child: RoundIconButton(
                //       icon: Icons.info_outline, onPressed: () {}),
                // ),
              ],
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///Generator container:
            ///Textfield:
            data.isNotEmpty
                ? Container()
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/Logo_generator.png',
                          height: 150,
                          width: 150,
                        ),
                        const Text('QuickQR',
                            style: TextStyle(
                                color: darkBlue,
                                fontSize: 35,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 50),

                        //instructions:  step 1.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 1' : 'Step 1',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 50,
                                width: 3,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Insertar texto para convertirlo en código QR'
                                    : 'Insert text to convert it to QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Data Textfield:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 300,
                              child: TextField(
                                controller: textController,
                                obscureText: false,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                onSubmitted: handleSubmit,
                                onChanged: (value) {
                                  print(value);
                                },
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: toggleLanguage
                                      ? 'Vinculo, texto, etc...'
                                      : 'Link, text, etc...', //as a placeholder text.
                                  hintStyle: const TextStyle(color: darkBlue),
                                  //prefixText: 'Prefix Text', // Appears while editing as a placeholder.
                                  // counterText:
                                  //     'Correo electronico', //below to the right.
                                  //helperText: 'helper text', //below to the left
                                  labelText: toggleLanguage
                                      ? 'Insertar texto aqui...'
                                      : 'Insert data here...', //normal text inside
                                  errorStyle:
                                      const TextStyle(color: flashGreen),
                                  labelStyle: const TextStyle(
                                      color: Colors.grey, fontFamily: 'Futura'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: darkBlue, width: 1.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: lightBlue, width: 2.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32.0)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            RoundedButton(
                                color: darkBlue,
                                textColor: Colors.white,
                                title: toggleLanguage
                                    ? 'Generar código'
                                    : 'Generate code',
                                width: 200,
                                pressed: () {
                                  handleSubmit(textController.text);
                                }),
                          ],
                        ),
                        const SizedBox(height: 50),
                        //Tagline:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Powered by',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 10)),
                            //button logo
                            IconButton(
                              onPressed: () {
                                final Uri link =
                                    Uri.parse('https://encorangelab.com/');
                                launchURL(link);
                              },
                              icon: Image.asset(
                                'images/Tagline.png',
                                width: 150,
                                color: lightBlue,
                              ),
                              iconSize: 75,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

            ///QR Code:
            data.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: 150, bottom: 50, right: 100, left: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Instructions:  step 2.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 2' : 'Step 2',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 50,
                                width: 3,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Personaliza tu código QR'
                                    : 'Personalize your QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Editor end view
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///QR Code
                              Column(
                                children: [
                                  RepaintBoundary(
                                    key: _globalKey,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Set the border radius
                                        color: codeBackground,
                                        border: Border.all(
                                          color: outline
                                              ? currentColor
                                              : Colors
                                                  .transparent, // Set the border color
                                          width:
                                              outlineWidth, // Set the border width
                                        ),
                                        // Set the background color
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: Column(
                                          children: [
                                            PrettyQr(
                                              image: imageAvailable
                                                  ? MemoryImage(imageFile)
                                                  : null, //const AssetImage('images/Logo_iago.png'),
                                              typeNumber: null,
                                              size: 400,
                                              data: data,
                                              errorCorrectLevel:
                                                  QrErrorCorrectLevel.H,
                                              roundEdges: roundedCorners,
                                              elementColor: currentColor,
                                            ),
                                            codeText.isEmpty
                                                ? Container()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 15),
                                                    child: Text(codeText,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: currentColor,
                                                            fontSize:
                                                                codeTextSize,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                      toggleLanguage
                                          ? 'Vista previa'
                                          : 'Preview',
                                      style: TextStyle(
                                          color: currentColor.withOpacity(0.5),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),

                              ///tools
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Set the border radius
                                  color:
                                      codeBackground, // Set the background color
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ///buttons :
                                      RoundedButton(
                                          color: currentColor,
                                          textColor: Colors.white,
                                          title: toggleLanguage
                                              ? 'Color del código'
                                              : 'QR Code\'s color',
                                          width: 250,
                                          pressed: () {
                                            showPopup(context);
                                          }),
                                      Row(
                                        children: [
                                          RoundedButton(
                                              color: codeBackground,
                                              textColor: currentColor,
                                              title: toggleLanguage
                                                  ? 'Color del fondo'
                                                  : 'Background color',
                                              width: 200,
                                              pressed: () {
                                                showBackPopup(context);
                                              }),
                                          IconButton(
                                              tooltip: toggleLanguage
                                                  ? 'Eliminar fondo'
                                                  : 'Delete background',
                                              icon: const Icon(
                                                  Icons.highlight_remove,
                                                  color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  codeBackground =
                                                      Colors.transparent;
                                                });
                                              }),
                                        ],
                                      ),

                                      ///rounded switch
                                      const Divider(),
                                      Row(
                                        children: [
                                          Text(
                                            toggleLanguage
                                                ? 'Redondear'
                                                : 'Rounded corners',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: currentColor),
                                          ),
                                          const SizedBox(width: 20.0),
                                          Switch(
                                            activeColor: currentColor,
                                            inactiveTrackColor: Colors.grey,
                                            value: roundedCorners,
                                            onChanged: (value) {
                                              setState(() {
                                                roundedCorners = value;
                                                data = data + ' ';
                                                // Update the boolean variable
                                              });
                                            },
                                          ),
                                        ],
                                      ),

                                      ///outline switch
                                      const Divider(),
                                      Row(
                                        children: [
                                          Text(
                                            toggleLanguage
                                                ? 'Contorno'
                                                : 'Outline',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: currentColor),
                                          ),
                                          const SizedBox(width: 20.0),
                                          Switch(
                                            activeColor: currentColor,
                                            inactiveTrackColor: Colors.grey,
                                            value: outline,
                                            onChanged: (value) {
                                              setState(() {
                                                outline = value;
                                                data = data + ' ';
                                                // Update the boolean variable
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        toggleLanguage
                                            ? 'Tamaño del contorno'
                                            : 'Outline size',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      Slider(
                                        activeColor: currentColor,
                                        inactiveColor: Colors.grey,
                                        value: outlineWidth,
                                        min: 1.0,
                                        max: 20.0,
                                        onChanged: (value) {
                                          setState(() {
                                            outlineWidth =
                                                value; // Update the border width
                                          });
                                        },
                                      ),

                                      const Divider(),

                                      ///ImagePicker
                                      GestureDetector(
                                        child: imageAvailable
                                            ? Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Container(
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    20.0)),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              offset:
                                                                  const Offset(
                                                                      2.0, 2.0),
                                                              blurRadius: 5.0,
                                                              spreadRadius:
                                                                  0.5),
                                                        ],
                                                      ),
                                                      child: Image.memory(
                                                          imageFile,
                                                          height: 250,
                                                          width: 250,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: -0,
                                                    right: -0,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          imageAvailable =
                                                              false;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.red,
                                                        ),
                                                        child: const Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                            size: 15),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                height: 250.0,
                                                width: 250.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              20.0)),
                                                  color: currentColor
                                                      .withOpacity(0.5),
                                                  shape: BoxShape.rectangle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .grey.shade200,
                                                        offset: const Offset(
                                                            2.0, 2.0),
                                                        blurRadius: 5.0,
                                                        spreadRadius: 0.5),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .add_photo_alternate_outlined,
                                                        size: 30,
                                                        color: Colors.white),
                                                    Text(
                                                        toggleLanguage
                                                            ? 'Agregar imagen al centro del QR'
                                                            : 'Add image to the center of the code',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                        onTap: () async {
                                          final image = await ImagePickerWeb
                                              .getImageAsBytes();
                                          setState(() {
                                            imageFile = image!;
                                            imageAvailable = true;
                                          });
                                        },
                                      ),
                                      const Divider(),

                                      ///Code text
                                      SizedBox(
                                        height: 50,
                                        width: 250,
                                        child: TextField(
                                          //controller: textController,
                                          obscureText: false,
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.name,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          onChanged: (value) {
                                            setState(() {
                                              codeText = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: toggleLanguage
                                                ? 'Escaneame!...'
                                                : 'Scan me!...', //as a placeholder text.
                                            hintStyle: const TextStyle(
                                                color: darkBlue),
                                            //prefixText: 'Prefix Text', // Appears while editing as a placeholder.
                                            // counterText:
                                            //     'Correo electronico', //below to the right.
                                            //helperText: 'helper text', //below to the left
                                            labelText: toggleLanguage
                                                ? 'Agregar texto...'
                                                : 'Add text here...', //normal text inside
                                            errorStyle: const TextStyle(
                                                color: flashGreen),
                                            labelStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontFamily: 'Futura'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 20.0),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0)),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: darkBlue, width: 1.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0)),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: lightBlue, width: 2.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(32.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        toggleLanguage
                                            ? 'Tamaño del texto'
                                            : 'Text size',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                      Slider(
                                        activeColor: currentColor,
                                        inactiveColor: Colors.grey,
                                        value: codeTextSize,
                                        min: 10.0,
                                        max: 50.0,
                                        onChanged: (value) {
                                          setState(() {
                                            codeTextSize =
                                                value; // Update the border width
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),

                        ///Instructions:  step 3.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(toggleLanguage ? 'Paso 3' : 'Step 3',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700)),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 30.0, left: 30.0),
                              child: Container(
                                height: 50,
                                width: 3,
                                color: lightBlue,
                              ),
                            ),
                            Text(
                                toggleLanguage
                                    ? 'Descarga tu código QR'
                                    : 'Download your QR code',
                                style: const TextStyle(
                                    color: lightBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        ///Download button
                        RoundedButton(
                            color: darkBlue,
                            textColor: Colors.white,
                            title: toggleLanguage ? 'Descargar' : 'Download',
                            width: 200,
                            pressed: _capturePng),

                        ///Tagline:
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              toggleLanguage
                                  ? const Text('Web app construida por',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: darkBlue,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 10))
                                  : const Text('Powered by',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: darkBlue,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 10)),
                              //tagline
                              IconButton(
                                onPressed: () {
                                  final Uri link =
                                      Uri.parse('https://encorangelab.com/');
                                  launchURL(link);
                                },
                                icon: Image.asset(
                                  'images/Tagline.png',
                                  width: 150,
                                  color: lightBlue,
                                ),
                                iconSize: 75,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),

            ///Bottom container
            Container(
              height: 200.0,
              width: double.infinity,
              color: darkBlue,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 100.0, vertical: 20.0),
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Social Media, profile and legal Links:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.pushNamed(context, ProfileScreen.id);
                        //   },
                        //   child: const Text(
                        //     'My Account Information',
                        //     textAlign: TextAlign.start,
                        //     style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        //Email contact
                        Row(children: [
                          const Icon(
                            Icons.local_post_office,
                            color: Colors.white,
                            size: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                String? encodeQueryParameters(
                                    Map<String, String> params) {
                                  return params.entries
                                      .map((MapEntry<String, String> e) =>
                                          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                      .join('&');
                                }

                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'hello@Encorangelab.com',
                                  query: encodeQueryParameters(<String, String>{
                                    'subject': 'Hello SoftwareLab!',
                                    'body':
                                        'I\'d Just checked out the QR generator...',
                                  }),
                                );
                                launchUrl(emailLaunchUri);
                              },
                              child: const Text(
                                'Hello@EncorangeLab.com',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              )),
                        ]),
                        //location info
                        Row(children: [
                          const Icon(
                            Icons.edit_location,
                            color: Colors.white,
                            size: 15,
                          ),
                          TextButton(
                              onPressed: () {
                                final Uri link = Uri.parse(
                                    'https://goo.gl/maps/wpm2LhGHeiw9LqXB7');
                                launchURL(link);
                              },
                              child: const Text(
                                '900 Biscayne Blvd, Miami, FL 33132',
                                style: TextStyle(color: Colors.white),
                              )),
                        ]),
                        const SizedBox(height: 15),
                        toggleLanguage
                            ? const Text('Siguenos en',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                            : const Text('Follow us on',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                        //Social media outlets
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.asset('images/youtube.png',
                                  height: 25,
                                  color: Colors
                                      .white), // Replace 'assets/icon.png' with your image asset
                              onPressed: () {
                                final Uri link = Uri.parse(YouTube);
                                launchURL(link);
                              },
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              onPressed: () {
                                final Uri link = Uri.parse(Instagram);
                                launchURL(link);
                              },
                              icon: Image.asset('images/instagram.png',
                                  height: 25, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    //Logo
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'images/logo.png',
                            width: 100,
                          ),
                          onPressed: () {
                            final Uri link =
                                Uri.parse('https://encorangelab.com/');
                            launchURL(link);
                          },
                        ),
                        toggleLanguage
                            ? const Text(
                                'Todos los derechos reservados © 2023',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              )
                            : const Text(
                                'All rights reserved © 2023',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
