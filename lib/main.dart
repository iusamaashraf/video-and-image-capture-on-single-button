import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_project/preview_video_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import 'preview_image_page.dart';
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> _cameras;
List<CameraDescription> getCameras() {
  return _cameras;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void> initCamera({required bool frontcamera}) async {
    _cameraController =
        CameraController(_cameras[(frontcamera) ? 0 : 1], ResolutionPreset.max);
    _cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  // Future<void> Function({required bool frontCamera}) initCamera2;
  @override
  void initState() {
    super.initState();
    if (_cameras.isNotEmpty) {
      initCamera(frontcamera: true);
    }
  }

  @override
  void dispose() {
    if (_cameraController != null) {
      _cameraController!.dispose();
    }

    super.dispose();
  }

  var image;
  var videoPath;
  bool _isFrontCamera = false;
  bool isRecording = false;
  String? video;
  String? path;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _cameraController == null
                  ? Container(
                      height: size.height,
                      width: size.width,
                      color: Colors.red,
                    )
                  : SizedBox(
                      height: size.height,
                      width: size.width,
                      child: GestureDetector(
                        onDoubleTap: () {
                          _isFrontCamera = !_isFrontCamera;
                          initCamera(frontcamera: _isFrontCamera);
                          print("position is: ${_isFrontCamera}");
                        },
                        child: Builder(
                          builder: (BuildContext context) {
                            var camera = _cameraController!.value;
                            final fullSize = MediaQuery.of(context).size;
                            final size = Size(fullSize.width,
                                fullSize.height - (Platform.isIOS ? 90 : 60));
                            double scale;
                            try {
                              scale = size.aspectRatio * camera.aspectRatio;
                            } catch (_) {
                              scale = 1;
                            }
                            if (scale < 1) scale = 1 / scale;
                            return Transform.scale(
                              scale: scale,
                              child: CameraPreview(
                                _cameraController!,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
              // Positioned(
              //   right: 10,
              //   top: 30,
              //   child: Column(
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.symmetric(vertical: 16),
              //         width: 47,
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(100),
              //           color: Colors.black.withOpacity(0.4),
              //         ),
              //         child: Column(
              //           children: const [
              //             SizedBox(
              //               height: 10,
              //             ),
              //             Icon(
              //               Icons.flip_camera_android,
              //               color: Colors.white,
              //             ),
              //             SizedBox(
              //               height: 10,
              //             ),
              //             Icon(
              //               Icons.flash_off,
              //               color: Colors.white,
              //             ),
              //             SizedBox(
              //               height: 10,
              //             ),
              //             Icon(
              //               CupertinoIcons.moon,
              //               color: Colors.white,
              //             ),
              //             SizedBox(
              //               height: 10,
              //             ),
              //             Icon(
              //               CupertinoIcons.play_rectangle,
              //               color: Colors.white,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Positioned(
                right: 0,
                // right: size.width * 0.1,
                left: 0,
                bottom: 0,
                child: SizedBox(
                  height: size.height * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black12),
                        child: GestureDetector(
                          onTap: () {
                            print('object');
                          },
                          child: const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // const SizedBox(width: 20),
                      Container(
                        height: 60,
                        width: 60,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.transparent),
                        child: GestureDetector(
                          onLongPress: () async {
                            // final path = join(
                            //     (await getTemporaryDirectory()).path,
                            //     "${DateTime.now()}.mp4");

                            await _cameraController!.startVideoRecording();
                            setState(() {
                              isRecording = true;
                            });
                          },
                          onLongPressUp: () async {
                            videoPath =
                                await _cameraController!.stopVideoRecording();
                            // videoSelect = File(videoPath.path);
                            // video = File(videoPath.path)as String;
                            path = (videoPath.path);
                            setState(() {
                              isRecording = false;
                              // path = path1;
                              print("video path is :$videoPath");
                            });
                            Get.to(() => PreviewVideoPage(
                                  videoPath: path!,
                                ));
                          },
                          onTap: () async {
                            if (!isRecording) {
                              image = await _cameraController!.takePicture();

                              File selectedImage = File(image.path);
                              Get.to(() => PreviewImagePage(
                                    path: selectedImage,
                                  ));
                            }
                          },
                          child: isRecording
                              ? const Icon(
                                  Icons.radio_button_on,
                                  size: 70,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.circle_outlined,
                                  size: 70,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      // const SizedBox(width: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black12),
                          child: GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              CupertinoIcons.share,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(
                      //     Icons.circle_outlined,
                      //     size: size.height * 0.1,
                      //     color: Colors.black,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
