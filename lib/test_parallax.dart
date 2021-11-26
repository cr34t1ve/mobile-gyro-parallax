import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_gyro_parallax/sizeconfig.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TestParallax extends StatefulWidget {
  TestParallax({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _TestParallaxState createState() => _TestParallaxState();
}

class _TestParallaxState extends State<TestParallax> {
  // color of the circle
  Color color = Colors.greenAccent;

  // event returned from accelerometer stream
  AccelerometerEvent? event;

  // hold a refernce to these, so that they can be disposed
  Timer? timer;
  StreamSubscription? accel;

  // positions and count
  double secondTop = 150;
  double top = 125;
  double? skyTop;
  double? upperLeftTop;
  double? bottomRightTop;
  double? bottomLeftTop;
  double? upperRightTop;
  double? skyLeft;
  double? upperLeftLeft;
  double? bottomRightLeft;
  double? bottomLeftLeft;
  double? upperRightLeft;
  double? left;
  int count = 0;

  // variables for screen size
  double? width;
  double? height;

  setColor(AccelerometerEvent event) {
    // Calculate Left
    double x = ((event.x * 12) + ((width! - 100) / 2));
    // Calculate Top
    double y = event.y * 12 + 125;

    // find the difference from the target position
    var xDiff = x.abs() - ((width! - 100) / 2);
    var yDiff = y.abs() - 125;

    // check if the circle is centered, currently allowing a buffer of 3 to make centering easier
    if (xDiff.abs() < 3 && yDiff.abs() < 3) {
      // set the color and increment count
      // setState(() {
      //   color = Colors.greenAccent;
      //   count += 1;
      // });
    } else {
      // set the color and restart count
      setState(() {
        color = Colors.red;
        count = 0;
      });
    }
  }

  setPosition(AccelerometerEvent event) {
    if (event == null) {
      return;
    }

    // When x = 0 it should be centered horizontally
    // The left positin should equal (width - 100) / 2
    // The greatest absolute value of x is 10, multipling it by 12 allows the left position to move a total of 120 in either direction.
    setState(() {
      skyLeft = ((event.x * 2.3));
      left =
          ((event.x * 3.2) + ((width! - getProportionateScreenWidth(250)) / 2));
      upperLeftLeft =
          ((event.x * -6) + ((width! - getProportionateScreenWidth(380)) / 2));
      bottomRightLeft =
          ((event.x * -6) + ((width! - getProportionateScreenWidth(70)) / 2));
      bottomLeftLeft =
          ((event.x * 1) + ((width! - getProportionateScreenWidth(380)) / 2));
      upperRightLeft =
          ((event.x * 1) + ((width! - getProportionateScreenWidth(-70)) / 2));
    });

    // When y = 0 it should have a top position matching the target, which we set at 125
    setState(() {
      top = event.y * 14 + height! / 2.3;
      secondTop = event.y * -14 + height! / 2.3;
      upperLeftTop = event.y * 10 + height! / 3.8;
      bottomRightTop = event.y * 10 + height! / 11;
      bottomLeftTop = event.y * 4 + height! / 60;
      upperRightTop = event.y * 4 + height! / 3.31;
    });
  }

  startTimer() {
    // if the accelerometer subscription hasn't been created, go ahead and create it
    if (accel == null) {
      accel = accelerometerEvents.listen((AccelerometerEvent eve) {
        setState(() {
          event = eve;
        });
      });
    } else {
      // it has already ben created so just resume it
      accel!.resume();
    }

    // Accelerometer events come faster than we need them so a timer is used to only proccess them every 200 milliseconds
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 0), (_) {
        // if count has increased greater than 3 call pause timer to handle success
        if (count > 3) {
          // pauseTimer();
        } else {
          // proccess the current event
          // setColor(event!);
          setPosition(event!);
        }
      });
    }
  }

  pauseTimer() {
    // stop the timer and pause the accelerometer stream
    timer!.cancel();
    accel!.pause();

    // set the success color and reset the count
    setState(() {
      count = 0;
      color = Colors.green;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    accel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get the width and height of the screen
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0.0,
        backgroundColor: Color(0x44000000),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0.0,
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Image.asset(
              'assets/stars.png',
              fit: BoxFit.fitHeight,
            ),
          ),
          Stack(
            children: [
              //
              // bottom left
              //
              Positioned(
                  bottom: getProportionateScreenHeight(bottomLeftTop!),
                  left: getProportionateScreenWidth(bottomLeftLeft!),
                  child: Image.asset(
                    'assets/CLOUDSbottomleft.png',
                    height: getProportionateScreenHeight(84.7)
                  )),
              //
              // upper right
              //
              Positioned(
                  bottom: getProportionateScreenHeight(upperRightTop!),
                  left: getProportionateScreenWidth(upperRightLeft!),
                  child: Image.asset(
                    'assets/CLOUDSupperleft.png',
                    height: 64.88,
                  )),
              //
              // head
              //
              Positioned(
                  bottom: 0.0,
                  left: left,
                  child: Image.asset(
                    'assets/IMG_9398 1head.png',
                    height: 315.39,
                  )),
              //
              // upper left
              //
              Positioned(
                  bottom: getProportionateScreenHeight(upperLeftTop!),
                  left: getProportionateScreenHeight(upperLeftLeft!),
                  child: Image.asset(
                    'assets/CLOUDStopleft.png',
                    height: 62.18,
                  )),
              //
              // bottom right
              //
              Positioned(
                  bottom: getProportionateScreenHeight(bottomRightTop!),
                  left: getProportionateScreenWidth(bottomRightLeft!),
                  child: Image.asset(
                    'assets/CLOUDStopleft.png',
                    height: 63.98,
                  )),
            ],
          ),
        ],
      ),
      //
      // measurements for web
      //
      // WebHomePage(width: width),
      //
      //
      //
      //
      //
      //
      //
      // Stack(
      //   children: [
      //     Positioned(
      //       top: double.parse(secondTop.toStringAsFixed(1)),
      //       left: double.parse(secondLeft!.toStringAsFixed(1)),
      //       // the container has a color and is wrappeed in a ClipOval to make it round
      //       child: ClipOval(
      //         child: Container(
      //           width: 100,
      //           height: 100,
      //           color: Colors.yellow,
      //         ),
      //       ),
      //     ),
      //     Positioned(
      //       top: double.parse(top.toStringAsFixed(1)),
      //       left: double.parse(left!.toStringAsFixed(1)),
      //       // the container has a color and is wrappeed in a ClipOval to make it round
      //       child: ClipOval(
      //         child: Container(
      //           width: 100,
      //           height: 100,
      //           color: color,
      //         ),
      //       ),
      //     ),
      //     Align(
      //       alignment: Alignment.center,
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text('x: ${(event?.x ?? 0).toStringAsFixed(3)}'),
      //           Text('y: ${(event?.y ?? 0).toStringAsFixed(3)}'),
      //         ],
      //       ),
      //     )
      //   ],
      // )
    );
  }
}

class WebHomePage extends StatelessWidget {
  const WebHomePage({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0.0,
          bottom: 0.0,
          right: 0.0,
          left: 0.0,
          child: Image.asset(
            'assets/stars.png',
            fit: BoxFit.fitHeight,
          ),
        ),
        Stack(
          children: [
            //
            // bottom left
            //
            Positioned(
                bottom: getProportionateScreenHeight(14.2),
                left: getProportionateScreenWidth(612),
                child: Image.asset(
                  'assets/CLOUDSbottomleft.png',
                  height: 84.7,
                )),
            //
            // upper right
            //
            Positioned(
                bottom: 247.81,
                left: 866,
                child: Image.asset(
                  'assets/CLOUDSupperleft.png',
                  height: 64.88,
                )),
            //
            // head
            //
            Positioned(
                bottom: 0.0,
                left: (width! - 270) / 2,
                child: Image.asset(
                  'assets/IMG_9398 1head.png',
                  height: 315.39,
                )),
            //
            // upper left
            //
            Positioned(
                bottom: 214.46,
                left: 645,
                child: Image.asset(
                  'assets/CLOUDStopleft.png',
                  height: 62.18,
                )),
            //
            // bottom right
            //
            Positioned(
                bottom: 74.79,
                left: 795,
                child: Image.asset(
                  'assets/CLOUDStopleft.png',
                  height: 63.98,
                )),
          ],
        ),
      ],
    );
  }
}

// This is the colored circle that will be moved by the accelerometer
              // the top and left are variables that will be set
              

