import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreviewImagePage extends StatelessWidget {
  PreviewImagePage({
    Key? key,
    required this.path,
  }) : super(key: key);
  var path;
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
              child: Image.file(
                path,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: size.height * 0.05,
              left: size.width * 0.05,
              child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.adaptive.arrow_back,
                    color: Colors.white,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
