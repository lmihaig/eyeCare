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
  NetworkImage? imageprocessed;
  Map<String, dynamic>? responseBody;
  Map<String, dynamic>? jobInfo;
  Map<String, dynamic>? jobStatus;

  Future chooseImage(ImageSource source) async {
    try {
      final image = await ImagePicker()
          .pickImage(source: source, preferredCameraDevice: CameraDevice.front);
      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() {
        responseBody = null;
        jobInfo = null;
        jobStatus = null;
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

    // Map<String, String> headers = {"max-age": "1"};
    // request.headers.addAll(headers);
    // request.fields["parola"] = "sima_muie";

    request.files.add(http.MultipartFile.fromBytes(
        "file", image!.readAsBytesSync(),
        filename: "Photo.jpg", contentType: MediaType("image", "jpg")));

    http.Response response =
        await http.Response.fromStream(await request.send());
    print("Result: ${response.statusCode}");
    print("Body: ${response.body}");

    jobInfo = jsonDecode(response.body);
    print(jobInfo);

    uri = Uri.parse('http://sima.zapto.org:8081/api/get_job/' +
        jobInfo!['job_id'].toString());

    dynamic jsonBody;
    do {
      await Future.delayed(const Duration(milliseconds: 50));
      response = await client.get(uri);
      jsonBody = jsonDecode(response.body);
    } while (jsonBody!['status'] != 'DONE');

    // uri = Uri.parse('http://sima.zapto.org:8081/api/get_result/' +
    //     jobInfo!['job_id'].toString());

    // Map<String, String> headers = {"max-age": "1"};

    // JEGMANEALA V2.0, NU MA BATE PLZ  -Sima(CristiSima@git)
    bool getOk;
    print("A");
    NetworkImage? localNetImg;
    do {
      try {
        localNetImg = NetworkImage(
            'http://sima.zapto.org:8008/api/get_result/' +
                jobInfo!['job_id'].toString());
        // local_net_img.resolve(createLocalImageConfiguration(context));
        getOk = true;
      } catch (e) {
        print("Fail 1");
        getOk = false;
      }
    } while (!getOk);
    print("B");

    // print(response.bodyBytes);
    // image = MemoryFileSystem().file('test.dart');
    // image.writeAsBytesSync(response.bodyBytes);

    setState(() {
      jobStatus = jsonBody;
      imageprocessed = localNetImg;
    });
  }

  Future<String> parseResponse() async {
    while (jobInfo == null) {
      await Future.delayed(const Duration(seconds: 1));
    }
    String parsedResponse = "";
    for (String key in jobInfo!.keys) {
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

  ImageProvider showImage() {
    if (imageprocessed != null) {
      return imageprocessed!;
    } else {
      return FileImage(image!);
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
          maximumSize: Size(MediaQuery.of(context).size.width * 0.77,
              MediaQuery.of(context).size.height * 0.1),
          primary: const Color.fromARGB(255, 0, 53, 84),
          onPrimary: Colors.white,
          textStyle: const TextStyle(fontSize: 24),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Row contents vertically,
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
      backgroundColor: const Color.fromARGB(255, 0, 200, 255),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (image != null) ...[
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.05,
              // ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: showImage(),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 53, 84),
                    width: 4.0,
                  ),
                ),
              ),
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
            Column(
              children: [
                fancyButton(
                    title: "Take picture",
                    icon: Icons.camera_alt_outlined,
                    onPressed: () => chooseImage(ImageSource.camera)),
                fancyButton(
                    title: "Upload from gallery",
                    icon: Icons.image_outlined,
                    onPressed: () => chooseImage(ImageSource.gallery)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
