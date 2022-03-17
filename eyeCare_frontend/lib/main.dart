import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
  Map<String, dynamic>? responseBody;

  Future chooseImage(ImageSource source) async {
    try {
      final image = await ImagePicker()
          .pickImage(source: source, preferredCameraDevice: CameraDevice.front);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      uploadImage(this.image);
    } on PlatformException catch (e) {
      print("Failed to choose image: $e");
    }
  }

  Future uploadImage(File? image) async {
    var uri = Uri.parse('http://date.jsontest.com/');
    var request = http.MultipartRequest("POST", uri);

    // Map<String, String> headers = {"user": "muie_sima"};
    // request.headers.addAll(headers);
    // request.fields["parola"] = "sima_muie";

    request.files.add(http.MultipartFile.fromBytes(
        "file", image!.readAsBytesSync(),
        filename: "Photo.jpg", contentType: MediaType("image", "jpg")));

    http.Response response =
        await http.Response.fromStream(await request.send());
    print("Result: ${response.statusCode}");
    print("Body: ${response.body}");

    setState(() => responseBody = jsonDecode(response.body));
    print(responseBody);
  }

  Future<String> parseResponse() async {
    if (responseBody == null) return "lmao";
    String parsedResponse = "";
    for (String key in responseBody!.keys) {
      parsedResponse +=
          // key + " Confidence: " + responseBody![key].toString() + "\n";
          key + responseBody![key].toString();
      // "Boala" + "\tConfidence: " + "numar\n";
    }
    return parsedResponse;
  }

  Widget displayResponse({required String responseText}) => Text(
        responseText,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          // background: Paint()
          //   ..strokeWidth = 17
          //   ..color = Colors.blue
          //   ..strokeJoin = StrokeJoin.round
          //   ..strokeCap = StrokeCap.round
          //   ..style = PaintingStyle.stroke,
        ),
      );

  Widget fancyButton(
          {required String title,
          required IconData icon,
          required VoidCallback onPressed}) =>
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          maximumSize: const Size.fromHeight(64),
          primary: Colors.white,
          onPrimary: Colors.black,
          textStyle: const TextStyle(fontSize: 24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 18),
            Text(title)
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 60, 175, 195),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            if (image != null) ...[
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(image!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  border: Border.all(
                    color: const Color.fromARGB(255, 25, 80, 80),
                    width: 4.0,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              FutureBuilder(
                  future: parseResponse(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data as String != "lmao") {
                      return displayResponse(
                          responseText: snapshot.data as String);
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
            ] else ...[
              const FlutterLogo(size: 300),
            ],
            const Spacer(),
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
