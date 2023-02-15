import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(builder: (context) {
        if (hasPermission) {
          // show compass
          return buildCompass();
        } else {
          // request permission
          return buildPermissionSheet();
        }
      }),
    );
  }

  void fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => hasPermission = status == PermissionStatus.granted);
      }
    });
  }

  Widget buildCompass() {
    return Center(
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: ((context, snapshot) {
          //error
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          // waiting / loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          double? direction = snapshot.data!.heading;

          // device doesn't support these sensors
          if (direction == null) {
            return const Text(
                'Your device doesn\'t support this functionality');
          }

          // everything is fine
          // show compass
          return Transform.rotate(
            angle: (direction * (math.pi / 180) * -1),
            child: Image.asset('assets/images/compass.webp'),
          );
        }),
      ),
    );
  }

  Widget buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Location permission needed'),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: (() {
              Permission.locationWhenInUse.request().then((ignored) {
                fetchPermissionStatus();
              });
            }),
            child: const Text('Request Permission'),
          ),
        ],
      ),
    );
  }
}
