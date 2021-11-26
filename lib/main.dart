import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_gyro_parallax/anothertest.dart';
import 'package:mobile_gyro_parallax/sizeconfig.dart';
import 'package:mobile_gyro_parallax/test_parallax.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(MediaQ());

class MediaQ extends StatelessWidget {
  const MediaQ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatelessWidget {
   int _blackPrimaryValue = 0xFF000000;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
      title: 'Accelerometer',
      theme: ThemeData(
        primarySwatch: MaterialColor(
        _blackPrimaryValue,
        <int, Color>{
          50: Color(0xFF000000),
          100: Color(0xFF000000),
          200: Color(0xFF000000),
          300: Color(0xFF000000),
          400: Color(0xFF000000),
          500: Color(_blackPrimaryValue),
          600: Color(0xFF000000),
          700: Color(0xFF000000),
          800: Color(0xFF000000),
          900: Color(0xFF000000),
        },
      )
      
      ),
      home: TestParallax(title: 'Accelerometer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // color of the circle
  Color color = Colors.greenAccent;

  // event returned from accelerometer stream
  AccelerometerEvent? event;

  // hold a refernce to these, so that they can be disposed
  Timer? timer;
  StreamSubscription? accel;

  // positions and count
  double top = 125;
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
      setState(() {
        color = Colors.greenAccent;
        count += 1;
      });
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
      left = ((event.x * 12) + ((width! - 100) / 2));
    });

    // When y = 0 it should have a top position matching the target, which we set at 125
    setState(() {
      top = event.y * 12 + 125;
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
      timer = Timer.periodic(Duration(milliseconds: 5), (_) {
        // if count has increased greater than 3 call pause timer to handle success
        if (count > 3) {
          pauseTimer();
        } else {
          // proccess the current event
          setColor(event!);
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Keep the circle in the center for 1 second'),
          ),
          Stack(
            children: [
              // This empty container is given a width and height to set the size of the stack
              Container(
                height: height! / 2,
                width: width,
              ),

              // Create the outer target circle wrapped in a Position
              Positioned(
                // positioned 50 from the top of the stack
                // and centered horizontally, left = (ScreenWidth - Container width) / 2
                top: 50,
                left: (width! - 250) / 2,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2.0),
                    borderRadius: BorderRadius.circular(125),
                  ),
                ),
              ),
              // This is the colored circle that will be moved by the accelerometer
              // the top and left are variables that will be set
              Positioned(
                top: top,
                left: left ?? (width! - 100) / 2,
                // the container has a color and is wrappeed in a ClipOval to make it round
                child: ClipOval(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: color,
                  ),
                ),
              ),
              // second colored circle for testing parallax
              Positioned(
                top: top *= -1,
                left: left ?? (width! - 100) / 2,
                // the container has a color and is wrappeed in a ClipOval to make it round
                child: ClipOval(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.yellow,
                  ),
                ),
              ),
              // inner target circle wrapped in a Position
              Positioned(
                top: 125,
                left: (width! - 100) / 2,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ],
          ),
          Text('x: ${(event?.x ?? 0).toStringAsFixed(3)}'),
          Text('y: ${(event?.y ?? 0).toStringAsFixed(3)}'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RaisedButton(
              onPressed: startTimer,
              child: Text('Begin'),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
