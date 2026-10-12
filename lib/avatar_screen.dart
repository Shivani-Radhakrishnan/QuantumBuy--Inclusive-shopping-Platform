import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class MovingAvatarScreen extends StatefulWidget {
  const MovingAvatarScreen({super.key});

  @override
  _MovingAvatarScreenState createState() => _MovingAvatarScreenState();
}

class _MovingAvatarScreenState extends State<MovingAvatarScreen> with SingleTickerProviderStateMixin {
  Object? _avatar;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _avatar?.position.x = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Conditional Background
          isDarkMode
              ? Container(color: Colors.black) // Solid color for dark mode
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/background.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.2),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
          Center(
            child: GestureDetector(
              onTap: _activateVoiceAssistant, // Handle tap to activate the voice assistant
              child: Cube(
                onSceneCreated: (Scene scene) {
                  _avatar = Object(
                    scale: vector.Vector3(5.0, 5.0, 5.0),
                    position: vector.Vector3(0, 0, 0),
                    fileName: 'assets/avatar.obj',
                  );
                  scene.world.add(_avatar!);
                  scene.camera.zoom = 10;
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Icon(
                Icons.settings,
                size: 40,
                color: Colors.white.withOpacity(0.8), // Increased opacity for better contrast
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _activateVoiceAssistant() {
    // Implement the functionality to activate your voice assistant here.
    print("Voice Assistant Activated");
  }
}
