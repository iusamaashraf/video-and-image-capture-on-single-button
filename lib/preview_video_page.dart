import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class PreviewVideoPage extends StatefulWidget {
  PreviewVideoPage({
    Key? key,
    required this.videoPath,
  }) : super(key: key);
  String videoPath;
  @override
  State<PreviewVideoPage> createState() => _PreviewVideoPageState();
}

class _PreviewVideoPageState extends State<PreviewVideoPage> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _controller.play();
        _controller.setVolume(1);
        _controller.setLooping(true);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : Container()),
            Positioned(
              top: size.height * 0.05,
              left: size.width * 0.05,
              child: IconButton(
                  onPressed: () {
                    _controller.dispose();
                    Get.back();
                  },
                  icon: Icon(
                    Icons.adaptive.arrow_back,
                    color: Colors.white,
                  )),
            ),
            Positioned(
              bottom: size.height * 0.05,
              right: size.width * 0.05,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('data'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('data1'),
                  ),
                ],
              ),
            ),

            // GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         _controller.value.isPlaying
            //             ? _controller.play()
            //             : _controller.pause();
            //       });
            //     },
            //     child: _controller.value.isPlaying
            //         ? Icon(Icons.play_arrow)
            //         : Icon(Icons.arrow_back)),
          ],
        ),
      ),
    );
  }
}
