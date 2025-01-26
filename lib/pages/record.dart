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
import 'package:web_socket_channel/io.dart';


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
  final videoChannel = IOWebSocketChannel.connect('ws://echo.websocket.org');

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
        setState(() {});


        // return;
        cameraController?.startImageStream((CameraImage availableImage) async {
          print(counter);
          counter++;
          print(availableImage.format.group.name);
          // imglib.Image? bitmap = imglib.decodeImage(availableImage.planes[0].bytes);
          // final bitmap = imglib.Image.fromBytes(
          //   height: availableImage.height,
          //   width: availableImage.width,
          //   bytes: (availableImage.planes[0].bytes).buffer,
          //   format: imglib.Format.uint8,
          //   order: ChannelOrder.bgra
          // );
          final encodedString = base64Encode(availableImage.planes[0].bytes);
          print(encodedString);
          // videoChannel.sink.add(encodedString);
          // if (bitmap != null) {
          //   File("${directory.path}/img.png").writeAsBytesSync(imglib.encodeJpg(bitmap));
          //   // Gal.putImage("${directory.path}/img.png");
          // } else {
          //   print("bitmap is null");
          // }
        });

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Tracking", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraPreview(cameraController!),
              ),
            ),
            StreamBuilder(
              stream: videoChannel.stream,
              builder: (context, snapshot) {
                return Center(
                  child: Text(snapshot.hasData ? '${snapshot.data}' : 'Nada', style: TextStyle(color: Colors.white)),
                );
              },
            ),
            // ElevatedButton(
            //   child: Text("erm"),
            //   onPressed: () {
            //     videoChannel.sink.add("Hello world");
            //   }
            // )
            // SizedBox(
            //   height: 70,
            //   child: Row(
            //     children: [
            //       Expanded(child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           Text("Bicep Curl", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            //           Text("Current Exercise", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white))
            //         ],
            //       )),
            //       Container(color: Colors.white, width: 2),
            //       Expanded(child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         children: [
            //           Text("120", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            //           Text("Pace", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white))
            //         ],
            //       ))
            //     ],
            //   )
            // )
          ]
        ),
      )
    );
  }


}