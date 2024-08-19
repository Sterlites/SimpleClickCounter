import 'package:flutter/material.dart';
import 'dart:math' as math;

// Customizable parameters
const double ANIMATION_SPEED = 100.0; // Pixels per second
const Color BUTTON_COLOR = Colors.blue; // Color of the floating button
const double EDGE_BOUNCE_RANDOMNESS = 0.2; // 0.0 to 1.0, adds randomness to bounce angle

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClickThe button, if you can! 🤓',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 49, 255)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ClickThe button, if you can! 🤓'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;
  late AnimationController _controller;
  late ValueNotifier<Offset> _position;
  late ValueNotifier<Offset> _velocity;

  @override
  void initState() {
    super.initState();
    _position = ValueNotifier(Offset.zero);
    _velocity = ValueNotifier(_getRandomVelocity());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updatePosition);
  }

  Offset _getRandomVelocity() {
    final angle = math.Random().nextDouble() * 2 * math.pi;
    return Offset(math.cos(angle), math.sin(angle));
  }

  void _updatePosition() {
    final size = MediaQuery.of(context).size;
    final buttonSize = 156.0;
    final maxX = size.width - buttonSize;
    final maxY = size.height - buttonSize - kToolbarHeight;

    var newX = _position.value.dx + _velocity.value.dx * ANIMATION_SPEED * _controller.value;
    var newY = _position.value.dy + _velocity.value.dy * ANIMATION_SPEED * _controller.value;

    var newVelocityX = _velocity.value.dx;
    var newVelocityY = _velocity.value.dy;

    bool bounced = false;

    if (newX < 0 || newX > maxX) {
      newVelocityX *= -1;
      newX = newX < 0 ? 0 : maxX;
      bounced = true;
    }

    if (newY < 0 || newY > maxY) {
      newVelocityY *= -1;
      newY = newY < 0 ? 0 : maxY;
      bounced = true;
    }

    if (bounced) {
      // Add some randomness to the bounce angle
      final currentAngle = math.atan2(newVelocityY, newVelocityX);
      final randomAngleChange = (math.Random().nextDouble() - 0.5) * EDGE_BOUNCE_RANDOMNESS * math.pi;
      final newAngle = currentAngle + randomAngleChange;
      final speed = math.sqrt(newVelocityX * newVelocityX + newVelocityY * newVelocityY);
      newVelocityX = speed * math.cos(newAngle);
      newVelocityY = speed * math.sin(newAngle);
    }

    _position.value = Offset(newX, newY);
    _velocity.value = Offset(newVelocityX, newVelocityY);
  }

  @override
  void dispose() {
    _controller.dispose();
    _position.dispose();
    _velocity.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'You have pushed the button this many times:',
                  style: TextStyle(
                    fontFamily: 'Verdana',
                    fontSize: 20,
                    color: Colors.black87,
                    shadows: [
                      Shadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$_counter',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    fontFamily: 'Roboto',
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<Offset>(
            valueListenable: _position,
            builder: (context, position, child) {
              return Positioned(
                left: position.dx,
                top: position.dy + kToolbarHeight,
                child: FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  backgroundColor: BUTTON_COLOR,
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}