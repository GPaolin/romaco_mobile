import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_drive_demo_app/qrpage/qrviewer.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRPageWidget extends StatefulWidget {
  const QRPageWidget({Key? key}) : super(key: key);

  @override
  _QRPageWidgetState createState() => _QRPageWidgetState();
}

class _QRPageWidgetState extends State<QRPageWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      // controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Romaco App Scan Code'),
      ),
      body: Stack(
        // alignment: Alignment.center,
        // fit: StackFit.passthrough,
        children: [
          QRView(
            cameraFacing: CameraFacing.back,
            key: qrKey,
            onQRViewCreated: _downloadDriveQR,
            overlay: QrScannerOverlayShape(
              borderRadius: 10,
              borderWidth: 5,
              borderColor: Colors.white,
            ),
          ),
          // Container(
          //   color: Colors.white,
          // ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 4,
              width: double.maxFinite,
              color: Colors.cyan.withOpacity(0.2),
              child: Center(
                child: Text(
                  'Scan the group code on the machine',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline5,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _downloadDriveQR(QRViewController controller)  {
    //TO DO
    this.controller = controller;
    controller.pauseCamera();
    controller.scannedDataStream.listen((scanData) {
      QRCodeRead qrCodeRead = QRCodeRead();
      //PARSE STRING -> TO DO
      qrCodeRead.code = scanData.code;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => QRViewerWidget(
              qrcode: qrCodeRead)));
    });
  }
}

class QRCodeRead  {
  String? serial;
  String? code;
}