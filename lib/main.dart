import 'dart:io' as io;
import 'dart:convert';
import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;

import 'package:url_launcher/url_launcher.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'GoogleAuthClient.dart';
import 'qrpage/qrbounce.dart';
import 'qrpage/qrpage.dart';
import 'qrpage/qrviewer.dart';

import 'globals.dart' as globals;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Romaco Tech Drawings',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Romaco App Home'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _homePage = 0;
  final _qrPage = 1;
  String macserial = globals.machine_serial;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  var _selectedIndex = 0;

  Future<void> _upload() async {
    upload();
  }

  Future<void> upload() async {
    _action = "upload file to Google Drive";
    final googleSignIn =
    signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");

    final authHeaders = await account?.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders!);
    final driveApi = drive.DriveApi(authenticateClient);

    final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream();
    var media = new drive.Media(mediaStream, 2);
    var driveFile = new drive.File();
    driveFile.name = "hello_world.txt";
    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");
  }

  void _downloadDriveQR(QRViewController controller) async{
    controller.scannedDataStream.listen((event) {
      print(event.code);
      controller.pauseCamera();
      final response = _downloadDrive();

    });
  }

  void _downloadDriveQR3()  {
    globals.qr_codescanned = true;
    _downloadDriveQR2();
  }


  Future<void> _downloadDriveQR2() async {
    if(globals.qr_codescanned) {
      QRCodeRead qrCodeRead = QRCodeRead();
      //PARSE STRING -> TO DO
      qrCodeRead.code = "ElectricalSheet";
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => QRViewerWidget(
              qrcode: qrCodeRead)));
    }
    setState(() {
      macserial = globals.machine_serial;
    });
  }


  Future<void> _downloadDrive() async {
    setState(() {
      _action = "download file from Google Drive";
    });
    final googleSignIn =
    //signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");

    final authHeaders = await account?.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders!);
    final driveApi = drive.DriveApi(authenticateClient);

    try {
      //final drive.Media? file = (await driveApi.files.get("hello_world.txt", downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media?;
      //print(file?.toString());

      const serial = "P7521003";
      drive.FileList folders = await driveApi.files.list(q:"mimeType = 'application/vnd.google-apps.folder' and name contains '$serial'");
      //TO DO
      var folder_id = "";
      folders.files?.forEach((element) { folder_id = element.id!;});

      if(folder_id == "") {
        drive.FileList textFileList = await driveApi.files.list(q: "name contains '100-9P117528002' and parents in '$folder_id'"); //IT WORKS!!!!

        textFileList.files?.forEach((element) async {
          final url = "https:/drive.google.com/file/d/" + element.id.toString(); //IT WORKS!!!

          print(element.id); //IT WORKS!!!
          print(element.name); //IT WORKS!!!
          print(url); //IT WORKS!!!

          setState(() {
            _action = "file trovato: " + element.name.toString() + "\n\nin folder $serial";
          });

          print("OPEN FILE!!!!!");

          final result = await launch(url);
          print(result.toString());

        });
      }
      else{
        setState(() {
          _action = "machine serial number $serial not found";
        });
      }
    }
    catch(e){
      print(e);
    }
  }

  Future<void> _search() async {
    setState(() {
      _action = "download file from Google Drive";
    });
    final googleSignIn =
    signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveFileScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");

    final Map<String, String> queryParameters = {
      'spaces': 'appDataFolder',
      // more query parameters
    };
    final headers = { 'Autorization': 'Bearer $account' };
    final uri = Uri.https('www.googleapis.com', '/drive/v3/files', queryParameters);
    //final response = await http.get(uri, headers: headers);
  }

  var _action = "Romaco technical drawings";
  var _action2 = "Look for qrcode on the machine to show technical drawings\nof machine groups";

  void _checkLoginAndGo() {
    //TO DO -> check user email and password
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRBounce()));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: globals.generalColor,
      appBar: AppBar(
        backgroundColor: globals.romacoColor,
        title: Text('Home'),
      ),
      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'images/romaco_sustain.png',
              fit: BoxFit.cover,
            ),
            // Text(
            //   '$_action2',
            //   style: Theme.of(context).textTheme.bodyText1,
            //   textAlign: TextAlign.center,
            // ),
            Text(
              'Machine: $macserial',
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            IconButton(
              icon: Image.asset('images/qr_code_button.png'),
              iconSize: 80,
              onPressed: _checkLoginAndGo,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(onPressed: _downloadDriveQR2, child: const Text('Electrical sheet'),
                  ),
                ),
                Expanded(
                  child: TextButton(onPressed: _downloadDriveQR2, child: const Text('HMI manual')),
                ),
                Expanded(
                  child:  TextButton(
                    onPressed: _downloadDriveQR3,
                    child: const Text(
                        'TEST'
                    )
                ),
                )
              ],
            ),
            // Image.asset(
            //   'images/onestop.png',
            //   fit: BoxFit.fitWidth,
            // )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: globals.romacoColor,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset('images/onestop.png', width: 0),  //BAD WORKAROUND!!!
              label: '',
          ),
          BottomNavigationBarItem(
              icon: Image.asset('images/onestop.png', width: 0,), //BAD WORKAROUND!!!
              label: ''
          ),
        ],
      ),
    );
  }
}
