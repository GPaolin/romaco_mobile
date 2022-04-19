import 'dart:io';
import 'package:flutter/material.dart';
import 'package:romaco_mobile/qrpage/qrpage.dart';
import 'package:romaco_mobile/GoogleAuthClient.dart';
import 'package:romaco_mobile/globals.dart' as globals;

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:url_launcher/url_launcher.dart';

class QRViewerWidget extends StatefulWidget {
  final QRCodeRead qrcode;

  const QRViewerWidget({Key? key,
    required this.qrcode,
  }) : super(key: key);

  @override
  _QRViewerWidgetState createState() => _QRViewerWidgetState();
}

class _QRViewerWidgetState extends State<QRViewerWidget> {

  String main_message = "Found code. Click to explore";

  @override
  Widget build(BuildContext context) {

    globals.qr_codescanned = true;
    globals.machine_serial = "P7521003";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: globals.romacoColor,
        title: Text('QR Viewer'),
      ),

      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$main_message',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            IconButton(
              onPressed: _downloadDrive,
              //icon: Image.asset('images/tech_draw.png'),
              icon: Icon(Icons.visibility),
              iconSize: 72,
            ),
          ],),
      ),
    );
  }

  Future<void> _downloadDrive() async {
    final googleSignIn =
    //signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");

    final authHeaders = await account?.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders!);
    final driveApi = drive.DriveApi(authenticateClient);

    try{
      //final drive.Media? file = (await driveApi.files.get("hello_world.txt", downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media?;
      //print(file?.toString());

      String? serial = widget.qrcode.serial;
      serial = "P7521003"; //JUST FOR TEST
      drive.FileList folders = await driveApi.files.list(q:"mimeType = 'application/vnd.google-apps.folder' and name contains '$serial'");
      //TO DO
      var folder_id = "";
      folders.files?.forEach((element) { folder_id = element.id!;});

      String? code_check = widget.qrcode.code;
      if(folder_id != "") {
        drive.FileList textFileList = await driveApi.files.list(q: "name contains '$code_check' and parents in '$folder_id'"); //IT WORKS!!!!
        setState(() {
          main_message = "Table $code_check not found";
        });

        textFileList.files?.forEach((element) async {
          setState(() {
            main_message = "Table $code_check found";
          });

          final url = "https:/drive.google.com/file/d/" + element.id.toString(); //IT WORKS!!!

          print(element.id); //IT WORKS!!!
          print(element.name); //IT WORKS!!!
          print(url); //IT WORKS!!!

          print("OPEN FILE!!!!!");

          final result = await launch(url);
          print(result.toString());

        });
      }
      else{
        setState(() {
          main_message = "Machine serial $serial not found";
        });
      }
    }
    catch(e){
      print(e);
    }
  }
}// TODO Implement this library.