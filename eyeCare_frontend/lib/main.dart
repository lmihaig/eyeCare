import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? image;

  Future chooseImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print("Failed to choose image: $e");
    }
  }

  Widget fancyButton(
          {required String title,
          required IconData icon,
          required VoidCallback onPressed}) =>
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          maximumSize: const Size.fromHeight(56),
          primary: Colors.white,
          onPrimary: Colors.black,
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Text(title)
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 60, 175, 195),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            image != null
                ? Image.file(
                    image!,
                    // width: 300,
                    // height: 300,
                    fit: BoxFit.cover,
                  )
                : const FlutterLogo(size: 300),
            const SizedBox(
              height: 24,
            ),
            const Text(
              'AI CANCER LA OCHI',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            fancyButton(
                title: "Take picture",
                icon: Icons.camera_alt_outlined,
                onPressed: () => chooseImage(ImageSource.camera)),
            fancyButton(
                title: "Upload from gallery",
                icon: Icons.image_outlined,
                onPressed: () => chooseImage(ImageSource.gallery))
          ],
        ),
      ),
    );
  }
}
