import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
// import 'package:file/file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
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
  Map<String, dynamic>? job_info;
  Map<String, dynamic>? job_status;

  Future chooseImage(ImageSource source) async {
    try {
      final image = await ImagePicker()
          .pickImage(source: source, preferredCameraDevice: CameraDevice.front);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() {
        responseBody = null;
        job_info = null;
        job_status = null;
        this.image = imageTemp;
      });
      // setState(() => this.image = imageTemp);
      uploadImage(this.image);
    } on PlatformException catch (e) {
      print("Failed to choose image: $e");
    }
  }

  Future uploadImage(File? image) async {
    var uri = Uri.parse('http://sima.zapto.org:8081/api/add_job');
    var request = http.MultipartRequest("POST", uri);
    var client = http.Client();

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

    job_info = jsonDecode(response.body);
    print(job_info);

    uri = Uri.parse('http://sima.zapto.org:8081/api/get_job/' +
        job_info!['job_id'].toString());

    print("9");

    dynamic json_body;
    do {
      await Future.delayed(const Duration(milliseconds: 50));
      response = await client.get(uri);
      json_body = jsonDecode(response.body);
    } while (json_body!['status'] != 'DONE');

    print("A");
    uri = Uri.parse('http://sima.zapto.org:8081/api/get_result/' +
        job_info!['job_id'].toString());
    print("B");

    // JEGMANEALA, NU MA BATE PLZ  -Sima(CristiSima@git)
    bool get_ok;
    do {
      try {
        response = await client.get(uri);
        get_ok = true;
      } catch (e) {
        print("Fail 1");
        get_ok = false;
      }
    } while (!get_ok);

    print("C");
    print(this.image);
    print(this.image?.lastAccessedSync().toString());
    image = MemoryFileSystem().file('test.dart');
    image.writeAsBytesSync(response.bodyBytes);
    print("D");
    setState(() {
      job_status = json_body;
      this.image = image;
    });
    print("E");
    print(this.image?.lastAccessedSync().toString());
  }

  Future<String> parseResponse() async {
    while (job_info == null) {
      await Future.delayed(const Duration(seconds: 1));
    }
    String parsedResponse = "";
    for (String key in job_info!.keys) {
      // parsedResponse +=  key + " Confidence: " + responseBody![key].toString() + "\n";
    }
    parsedResponse += "Possible affections:\nNone";
    return parsedResponse;
  }

  // Widget displayResponse({required String responseText}) => Text(
  //       responseText,
  //       textAlign: TextAlign.center,
  //       style: TextStyle(
  //         fontSize: 28,
  //         fontWeight: FontWeight.bold,

  //         // background: Paint()
  //         //   ..strokeWidth = 17
  //         //   ..color = Colors.blue
  //         //   ..strokeJoin = StrokeJoin.round
  //         //   ..strokeCap = StrokeCap.round
  //         //   ..style = PaintingStyle.stroke,
  //       ),
  //     );

  Widget displayResponse({required String responseText}) => RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(children: <TextSpan>[
          TextSpan(
              text: "Possible affections:\n",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 53, 84),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
          TextSpan(
              text: "None",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
        ]),
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
          primary: const Color.fromARGB(255, 0, 53, 84),
          onPrimary: Colors.white,
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
              const SizedBox(
                height: 24,
              ),
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
                    color: const Color.fromARGB(255, 0, 53, 84),
                    width: 4.0,
                  ),
                ),
              ),
              const SizedBox(height: 140),
              FutureBuilder(
                  future: parseResponse(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
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
