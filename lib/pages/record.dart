import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as imglib;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';


import '../utils/functions.dart';
import '../utils/providers.dart';
import '../utils/variables.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> with WidgetsBindingObserver {
  final convertNative = ConvertNativeImgStream();
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  late Timer videoFeedTimer;
  bool isStreaming = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null || cameraController?.value.isInitialized == false) return;
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state  == AppLifecycleState.resumed) {
      _setupCameraController();
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
    // videoFeedTimer = Timer.periodic(Duration(milliseconds: 42 /*Approx 24 fps*/), (timer) async {
    //   print("kuan is gay");
    //   XFile picture = await cameraController!.takePicture();
    //   Gal.putImage(
    //       picture.path
    //   );
    // });
  }

  @override
  void dispose() {
    super.dispose();
    // videoFeedTimer.cancel();
    // cameraController?.stopImageStream();
    // print("stream stopped");
    cameraController?.dispose();
  }

  void encodeToJpegFunction(imglib.Image bitmap) {
    // List<int> jpegBytes = imglib.encodeJpg(bitmap);
    // String base64String = base64Encode(jpegBytes);
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        final selectedCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
        print(_cameras);
        cameraController = CameraController(selectedCamera, ResolutionPreset.medium, enableAudio: false, videoBitrate: 20);
      });
      final Directory directory = await getApplicationDocumentsDirectory();
      cameraController?.initialize().then((_) {
        cameraController?.setFlashMode(FlashMode.off);
        // _startVideoStream();


        // return;
        cameraController?.startImageStream((CameraImage availableImage) async {
          // print("hi world");
          // print(availableImage);
          print(counter);
          counter++;
          print(availableImage.format.group.name);
          print(availableImage.width);
          // print(availableImage.height);
          // print(availableImage.planes);
          // print(availableImage.planes[0]);
          // print(availableImage.planes[0].bytes);
          // imglib.Image? bitmap = imglib.decodeImage(availableImage.planes[0].bytes);
          // final bitmap = imglib.Image.fromBytes(
          //   height: availableImage.height,
          //   width: availableImage.width,
          //   bytes: (availableImage.planes[0].bytes).buffer,
          //   format: imglib.Format.uint8,
          //   order: ChannelOrder.bgra
          // );
          print(base64Encode(availableImage.planes[0].bytes));
          // encodeToJpegFunction(bitmap);
          // List<int> jpegBytes = imglib.encodeJpg(bitmap);
          // String base64String = base64Encode(jpegBytes);
          // print(base64String);
          // final bitmap = convertYUV420toImageColor(availableImage);
          // final jpegFile = await convertNative.convertImg(availableImage.planes.first.bytes, availableImage.width, availableImage.height, "/path/to/save");
          // Gal.putImage(jpegFile!.path);
          // if (bitmap != null) {
          //   File("${directory.path}/img.png").writeAsBytesSync(imglib.encodeJpg(bitmap));
          //   // Gal.putImage("${directory.path}/img.png");
          // } else {
          //   print("bitmap is null");
          // }
        });
        setState(() {});
      });
    }
  }

  int counter = 0;

  Future<void> _startVideoStream() async {
    isStreaming = true;

    while (isStreaming) {
      // Capture a frame from the camera
      // print("hi");
      final XFile? file = await cameraController?.takePicture();

      print(counter);
      // if (file != null) {
      //   Gal.putImage(file.path);
      // }
      if (file != null) {
        final Uint8List frameBytes = await file.readAsBytes();
      }
      // print(file);
      counter++;

      // final Uint8List frameBytes = await file.readAsBytes();

      // Send the frame over WebSocket
      // _channel.sink.add(frameBytes); // Send raw bytes (or encoded bytes)

      // Delay to simulate frame rate (e.g., 30fps)
      // await Future.delayed(Duration(milliseconds: 33)); // 30 fps
    }
  }

  @override
  Widget build(BuildContext context) {
    print("start");
    print(DateTime.now().millisecondsSinceEpoch);
    if (cameraController == null || cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator()
      );
    }

    print("begin");
    print(DateTime.now().millisecondsSinceEpoch);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Erm")
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // CameraPreview(cameraController!),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 60),
                color: Colors.white,
                width: 350,
                height: 100,
                child: ElevatedButton(
                  child: Text("Take pic"),
                  onPressed: () async {
                    print("erm");
                    XFile picture = await cameraController!.takePicture();
                    Gal.putImage(
                      picture.path
                    );
                  },
                )
              )
            )
          ],
        )
      )
    );
  }


}