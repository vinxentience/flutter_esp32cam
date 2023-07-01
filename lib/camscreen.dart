import 'package:esp32cam_sample/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CamScreen extends StatefulWidget {
  final WebSocketChannel channel;
  const CamScreen({super.key, required this.channel});

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  final double videoWidth = 640;
  final double videoHeight = 480;

  double newVideoSizeWidth = 640;
  double newVideoSizeHeight = 480;

  late bool isLandscape;

  var _globalKey = new GlobalKey();

  //FLUTTER VISION
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;
  bool isLoaded = false;
  bool isDetecting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vision = FlutterVision();
    // loadYoloModel().then((value) {
    //   if (mounted) {
    //     setState(() {
    //       isLoaded = true;
    //       isDetecting = false;
    //       yoloResults = [];
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        var screenWidth = MediaQuery.of(context).size.width;
        var screenHeight = MediaQuery.of(context).size.height;

        if (orientation == Orientation.portrait) {
          isLandscape = false;
          newVideoSizeWidth = screenWidth;
          //newVideoSizeHeight = videoHeight * newVideoSizeWidth / videoWidth;
        } else {
          isLandscape = true;
          newVideoSizeHeight = screenHeight;
          //newVideoSizeWidth = videoWidth * newVideoSizeHeight / videoHeight;
        }

        return Container(
          color: Colors.white,
          child: StreamBuilder(
            stream: widget.channel.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                        "Make sure that this device is connected to 'ESP32-CAM-EBISEEKLETA'"),
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: isLandscape ? 0 : 30,
                        ),
                        Stack(
                          children: <Widget>[
                            RepaintBoundary(
                              key: _globalKey,
                              child: GestureZoomBox(
                                maxScale: 5.0,
                                doubleTapScale: 2.0,
                                duration: Duration(milliseconds: 200),
                                child:
                                    // yoloOnStream(
                                    //     snapshot.data,
                                    //     newVideoSizeHeight,
                                    //     newVideoSizeWidth) as Widget,
                                    Image.memory(
                                  snapshot.data as Uint8List,
                                  gaplessPlayback: true,
                                  width: newVideoSizeWidth,
                                  height: newVideoSizeHeight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.black,
                            width: MediaQuery.of(context).size.width,
                          ),
                        )
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        );
      }),
    );
  }

  // Future<void> loadYoloModel() async {
  //   await vision.loadYoloModel(
  //       labels: 'assets/trafficlabels.txt',
  //       modelPath: 'assets/traffic-yolov8n.tflite',
  //       modelVersion: "yolov8",
  //       numThreads: 2,
  //       useGpu: true);
  //   setState(() {
  //     isLoaded = true;
  //   });
  // }

  // Future<void> yoloOnFrame(AsyncSnapshot<dynamic> cameraImage, int cameraHeight,
  //     int cameraWidth) async {
  //   final result = await vision.yoloOnFrame(
  //       bytesList: cameraImage as List<Uint8List>,
  //       imageHeight: cameraHeight,
  //       imageWidth: cameraWidth,
  //       iouThreshold: 0.5,
  //       confThreshold: 0.5,
  //       classThreshold: 0.5);
  //   if (result.isNotEmpty) {
  //     if (mounted) {
  //       setState(() {
  //         yoloResults = result;
  //         print(result);
  //       });
  //     }
  //   }
  // }

  // Future<Image> yoloOnStream(AsyncSnapshot<dynamic> cameraImage,
  //     double cameraHeight, double cameraWidth) async {
  //   final result = await vision.yoloOnFrame(
  //       bytesList: cameraImage as List<Uint8List>,
  //       imageHeight: cameraHeight as int,
  //       imageWidth: cameraWidth as int,
  //       iouThreshold: 0.5,
  //       confThreshold: 0.5,
  //       classThreshold: 0.5);
  //   if (result.isNotEmpty) {
  //     if (mounted) {
  //       setState(() {
  //         yoloResults = result;
  //         print(result);
  //       });
  //     }
  //   }
  //   return Image.memory(
  //     cameraImage as Uint8List,
  //     gaplessPlayback: true,
  //     width: cameraWidth,
  //     height: cameraHeight,
  //   );
  // }

  // Future<void> startDetection(Image image) async {
  //   setState(() {
  //     isDetecting = true;
  //   });
  //   // await controller.startImageStream((image) async {
  //   //   if (isDetecting) {
  //   //     cameraImage = image;
  //   //     yoloOnFrame(image);
  //   //   }
  //   yoloOnFrame(cameraImage, cameraHeight, cameraWidth)
  // }

  // Future<void> stopDetection() async {
  //   setState(() {
  //     isTitled = false;
  //     isDetecting = false;
  //     isMessageSent = false;
  //     _start = 10;
  //     yoloResults.clear();
  //   });
  // }
}
